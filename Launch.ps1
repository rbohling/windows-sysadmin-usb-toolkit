#requires -Version 5.1
[CmdletBinding()]
param([string]$Id,[switch]$List,[switch]$AllowSpecial,[string[]]$ToolArguments)
. "$PSScriptRoot/scripts/Common.ps1"
$root=Get-ToolkitRoot; $lock=Get-Lock
if($List -or !$Id){$lock.tools | Select-Object id,category,class,status; return}
$t=@($lock.tools | Where-Object id -eq $Id)
if($t.Count -ne 1 -or $t[0].status -ne 'Pinned'){throw 'Select one pinned tool id; use -List'}
$t=$t[0]
if($t.class -match 'Installer|driver|Destructive|Boot-image|Self-extracting'){throw 'Special tool: launch manually after reading docs/MANUAL.md and docs/RECOVERY.md'}
if($t.class -notin @('Portable','CLI') -and !$AllowSpecial){throw "Class $($t.class): read catalogue and pass -AllowSpecial if prerequisites are met"}
$dir=Join-Path "$root/Tools/$Id" $t.sha256
$receipt=Get-Content -LiteralPath "$dir/receipt.json" -Raw | ConvertFrom-Json
if($receipt.archiveSHA256 -ne $t.sha256 -or $receipt.id -ne $Id){throw 'Receipt mismatch'}
foreach($f in $receipt.files){
 $full=[IO.Path]::GetFullPath((Join-Path $dir $f.path))
 if(!$full.StartsWith($dir+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe receipt path'}
 Assert-Hash $full $f.sha256
}
$matches=@(Get-ChildItem -LiteralPath $dir -Recurse -File | Where-Object {
 $_.Name -eq $t.exe -or $_.FullName.Substring($dir.Length+1).Replace('\','/') -eq $t.exe -or ($t.format -eq 'file' -and $_.Name -eq $t.file)
})
if($matches.Count -ne 1){throw "Executable ambiguous or missing ($($t.exe)); inspect tool folder manually"}
if($matches[0].FullName.Substring($dir.Length+1) -notin $receipt.files.path){throw 'Executable absent from receipt'}
if($t.class -eq 'CLI'){
 $cliArguments=@('--help')
 if($ToolArguments){$cliArguments=@($ToolArguments)}
 & $matches[0].FullName @cliArguments
 if($LASTEXITCODE -ne 0){throw "Tool exited with code $LASTEXITCODE"}
}else{
 if($ToolArguments){throw 'ToolArguments is supported only for CLI entries'}
 Start-Process -FilePath $matches[0].FullName -WorkingDirectory $matches[0].DirectoryName
}
