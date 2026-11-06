#requires -Version 5.1
[CmdletBinding()]
param([string[]]$Id,[switch]$Download,[switch]$Offline,[switch]$IncludeSpecial)
. "$PSScriptRoot/scripts/Common.ps1"
$root=Get-ToolkitRoot
$lock=Get-Lock
$selected=@($lock.tools | Where-Object {(!$Id -or $_.id -in $Id)})
if($Id){foreach($i in $Id){if($i -notin $lock.tools.id){throw "Unknown id: $i"}}}
if(!$Download -and !$Offline){$selected | Select-Object id,category,class,version,status; Write-Host 'Plan only. Use -Download, or -Offline with a populated Cache.'; return}
if($Download -and $Offline){throw 'Choose Download or Offline'}
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force "$root/Cache","$root/Tools","$root/Reports" | Out-Null
$failures=0
foreach($t in $selected){
 try {
  if($t.status -ne 'Pinned'){Write-Warning "$($t.id): manual review required; see docs/MANUAL.md"; continue}
  if($t.class -match 'Installer|driver|Destructive|Boot-image|Self-extracting' -and !$IncludeSpecial){Write-Warning "$($t.id): skipped special tool; use -IncludeSpecial to stage only"; continue}
  $cache=Join-Path "$root/Cache" ($t.sha256+'-'+$t.file)
  if(!(Test-Path -LiteralPath $cache)){
   if($Offline){throw "Offline cache missing: $($t.file)"}
   $part=$cache+'.'+[guid]::NewGuid().ToString('N')+'.part'
   Invoke-WebRequest -UseBasicParsing -Uri $t.url -OutFile $part -TimeoutSec 900 -UserAgent 'SysAdminUSB/1'
   Assert-Hash $part $t.sha256
   Move-Item -LiteralPath $part -Destination $cache
  }
  Assert-Hash $cache $t.sha256
  $dest=Join-Path "$root/Tools/$($t.id)" $t.sha256
  if(Test-Path -LiteralPath $dest){Write-Host "$($t.id): already staged; launcher checks receipt"; continue}
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  $stage=$dest+'.stage-'+[guid]::NewGuid().ToString('N')
  New-Item -ItemType Directory $stage | Out-Null
  if($t.format -eq 'zip'){Expand-SafeZip $cache $stage}else{Copy-Item -LiteralPath $cache -Destination (Join-Path $stage $t.file)}
  $files=@(Get-ChildItem -LiteralPath $stage -File -Recurse | ForEach-Object { [ordered]@{path=$_.FullName.Substring($stage.Length+1);sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash} })
  @{id=$t.id;archiveSHA256=$t.sha256;files=$files} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$stage/receipt.json" -Encoding UTF8
  Move-Item -LiteralPath $stage -Destination $dest
  Write-Host "$($t.id): verified and staged"
 } catch {$failures++; Write-Warning "$($t.id): $($_.Exception.Message)"}
}
if($failures){throw "$failures tool(s) failed. No failed artifact was installed or executed. Partial files may remain in Cache."}
