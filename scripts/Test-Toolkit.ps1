#requires -Version 5.1
[CmdletBinding()]
param()
. "$PSScriptRoot/Common.ps1"
$root=Get-ToolkitRoot
$script:passed=0
function Check([string]$Label,[scriptblock]$Action){& $Action; $script:passed++; Write-Output "PASS $Label"}
function Must-Fail([scriptblock]$Action,[string]$Pattern='.'){
 $failed=$false
 try{& $Action | Out-Null}catch{if($_.Exception.Message -notmatch $Pattern){throw};$failed=$true}
 if(!$failed){throw 'Expected failure did not occur'}
}
Check 'PowerShell parser: all scripts' {
 foreach($f in Get-ChildItem -LiteralPath $root -Recurse -Filter '*.ps1'){
  $tokens=$null;$errors=$null
  [void][Management.Automation.Language.Parser]::ParseFile($f.FullName,[ref]$tokens,[ref]$errors)
  if($errors.Count){throw ($f.Name+': '+($errors.Message -join '; '))}
 }
}
$lock=Get-Lock
Check 'tool lock schema, unique IDs, versions, hashes and fixed URLs' {
 if($lock.schema -ne 1 -or $lock.tools.Count -lt 50 -or $lock.tools.Count -gt 70){throw 'Unexpected catalogue size/schema'}
 if(@($lock.tools.id | Sort-Object -Unique).Count -ne $lock.tools.Count){throw 'Duplicate IDs'}
 foreach($t in $lock.tools | Where-Object status -eq Pinned){
  if(!$t.version -or !$t.hashSource -or $t.url -match '/latest/'){throw "Unpinned $($t.id)"}
  if($t.file -match 'arm64|aarch64|i686|win32\.zip'){throw "Wrong architecture: $($t.id)"}
 }
}
Check 'ISO lock hash shape and fixed versions' {
 $iso=Get-Content "$root/manifests/iso.lock.json" -Raw | ConvertFrom-Json
 if($iso.images.Count -ne 3){throw 'Expected three recovery images'}
 foreach($i in $iso.images){if($i.sha256 -notmatch '^[a-f0-9]{64}$' -or !$i.version -or !$i.hashSource){throw 'ISO pin invalid'}}
}
$fixture=Join-Path "$root/Reports" ('SysAdminUSB-test-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
Check 'SHA-256: valid bytes pass; modified bytes and blank hashes fail' {
 $f=Join-Path $fixture 'bytes.txt';[IO.File]::WriteAllText($f,'known bytes')
 $sha=(Get-FileHash $f -Algorithm SHA256).Hash
 Assert-Hash $f $sha
 [IO.File]::WriteAllText($f,'corrupted bytes')
 Must-Fail {Assert-Hash $f $sha} 'mismatch'
 Must-Fail {Assert-Hash $f ''} 'invalid'
}
Check 'ZIP: valid extraction and traversal/symlink rejection' {
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $zipFile=Join-Path $fixture 'good.zip'
 $z=[IO.Compression.ZipFile]::Open($zipFile,'Create')
 try{$e=$z.CreateEntry('nested/readme.txt');$s=New-Object IO.StreamWriter($e.Open());$s.Write('fixture');$s.Dispose()}finally{$z.Dispose()}
 $out=Join-Path $fixture 'good';Expand-SafeZip $zipFile $out
 if((Get-Content "$out/nested/readme.txt" -Raw) -ne 'fixture'){throw 'Extraction failed'}
 foreach($name in @('../escape.exe','/rooted.exe','bad:stream.exe','dir/../../escape.exe')){
  $bad=Join-Path $fixture ([guid]::NewGuid().ToString('N')+'.zip');$z=[IO.Compression.ZipFile]::Open($bad,'Create')
  try{[void]$z.CreateEntry($name)}finally{$z.Dispose()}
  Must-Fail {Expand-SafeZip $bad (Join-Path $fixture ([guid]::NewGuid().ToString('N')))} 'Unsafe|escaped'
 }
 $bad=Join-Path $fixture 'symlink.zip';$z=[IO.Compression.ZipFile]::Open($bad,'Create')
 try{$e=$z.CreateEntry('link');$e.ExternalAttributes=-1577123840}finally{$z.Dispose()}
 Must-Fail {Expand-SafeZip $bad (Join-Path $fixture 'symlink')} 'Unsafe'
}
Check 'offline setup, repeatability, receipt, tamper and unknown ID rejection' {
 $copy=Join-Path $fixture 'toolkit';New-Item -ItemType Directory -Force "$copy/scripts","$copy/manifests","$copy/Cache" | Out-Null
 Copy-Item "$root/Setup.ps1","$root/Launch.ps1" $copy
 Copy-Item "$root/scripts/Common.ps1" "$copy/scripts/"
 $sha=(Get-FileHash "$fixture/good.zip" -Algorithm SHA256).Hash.ToLowerInvariant()
 $tool=@{id='fixture';category='Tests';class='CLI';openSource=$true;source='https://github.com/example/fixture';version='v1';url='https://github.com/example/fixture/releases/download/v1/good.zip';file='good.zip';sha256=$sha;hashSource='fixture-test';status='Pinned';exe='never-run.exe';format='zip'}
 @{schema=1;tools=@($tool)} | ConvertTo-Json -Depth 5 | Set-Content "$copy/manifests/tools.lock.json" -Encoding UTF8
 Copy-Item "$fixture/good.zip" "$copy/Cache/$sha-good.zip"
 & "$copy/Setup.ps1" -Offline
 & "$copy/Setup.ps1" -Offline
 if(!(Test-Path "$copy/Tools/fixture/$sha/receipt.json")){throw 'Missing receipt'}
 [IO.File]::WriteAllText("$copy/Tools/fixture/$sha/nested/readme.txt",'tamper')
 Must-Fail {& "$copy/Launch.ps1" -Id fixture} 'mismatch'
 Must-Fail {& "$copy/Setup.ps1" -Id nonexistent} 'Unknown id'
 [IO.File]::WriteAllText("$copy/Cache/$sha-good.zip",'corrupt')
 Must-Fail {& "$copy/Setup.ps1" -Offline -WarningAction SilentlyContinue} 'failed'
}
Check 'Ventoy requires explicit opt-in before hardware access' {
 Must-Fail {& "$root/scripts/Open-Ventoy.ps1"} 'explicit.*required'
}
Check 'default setup and recovery commands are plans' {
 & "$root/Setup.ps1" -Id jq | Out-Null
 & "$root/scripts/Get-RecoveryMedia.ps1" -Id systemrescue | Out-Null
}
Check 'diagnostic failure summary with unavailable AD prerequisites' {
 $output=& "$root/diagnostics/Collect.ps1" -Area AD -OutputDirectory (Join-Path $fixture 'diagnostics')
 $summary=Get-Content -LiteralPath (Join-Path $output 'summary.json') -Raw | ConvertFrom-Json
 if(@($summary.checks).Count -ne 4){throw 'AD checks missing'}
 if(@($summary.checks | Where-Object {$_.check -in @('ad-domain','ad-dc','ad-replication') -and $_.status -eq 'UnavailableOrFailed'}).Count -ne 3){throw 'Missing prerequisites incorrectly reported as success'}
}
Check 'diagnostic nonterminating errors are failures, not empty success' {
 function Get-Printer {Write-Error 'Fixture printer access denied' -ErrorAction Continue}
 function Get-PrinterPort {Write-Error 'Fixture port access denied' -ErrorAction Continue}
 function Get-PrinterDriver {Write-Error 'Fixture driver access denied' -ErrorAction Continue}
 function Get-Service {[pscustomobject]@{Name='Spooler';Status='Running';StartType='Automatic'}}
 $output=& "$root/diagnostics/Collect.ps1" -Area Printers -OutputDirectory (Join-Path $fixture 'printer-diagnostics')
 $summary=Get-Content -LiteralPath (Join-Path $output 'summary.json') -Raw | ConvertFrom-Json
 if(@($summary.checks | Where-Object status -eq 'UnavailableOrFailed').Count -ne 4){throw 'Nonterminating errors incorrectly reported as success'}
 if(@($summary.checks | Where-Object {$_.check -eq 'print-spooler' -and $_.status -eq 'OK'}).Count -ne 1){throw 'Later checks did not continue'}
}
Write-Output "Passed $script:passed checks under PowerShell $($PSVersionTable.PSVersion). Fixtures: $fixture"
