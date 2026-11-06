#requires -Version 5.1
[CmdletBinding()]
param([switch]$IUnderstandDataLoss)
. "$PSScriptRoot/Common.ps1"
if(!$IUnderstandDataLoss){throw 'Ventoy installation may erase an entire disk. Read docs/RECOVERY.md; explicit -IUnderstandDataLoss required to open its GUI.'}
Get-Disk | Select-Object Number,FriendlyName,SerialNumber,BusType,Size,IsBoot,IsSystem | Format-Table -AutoSize
$answer=Read-Host 'Back up the USB. Unplug unrelated removable disks. Type OPEN VENTOY to open its GUI; select and verify the disk there'
if($answer -cne 'OPEN VENTOY'){throw 'Cancelled'}
$root=Get-ToolkitRoot
$t=(Get-Lock).tools | Where-Object id -eq ventoy
if($t.status -ne 'Pinned'){throw 'Ventoy release is not pinned'}
$dir=Join-Path "$root/Tools/ventoy" $t.sha256
# Re-verify original archive and compare extracted executable to its archive entry.
$cache=Join-Path "$root/Cache" ($t.sha256+'-'+$t.file)
Assert-Hash $cache $t.sha256
$exes=@(Get-ChildItem -LiteralPath $dir -Recurse -Filter Ventoy2Disk.exe -File)
if($exes.Count -ne 1){throw 'Run Setup.ps1 -Id ventoy -Download -IncludeSpecial first'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($cache)
try{
 $entry=@($zip.Entries | Where-Object {$_.FullName -match '(^|/)Ventoy2Disk.exe$'})
 if($entry.Count -ne 1){throw 'Archive executable ambiguous'}
 $stream=$entry[0].Open();$sha=[Security.Cryptography.SHA256]::Create()
 try{$expected=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')}finally{$stream.Dispose();$sha.Dispose()}
 Assert-Hash $exes[0].FullName $expected
}finally{$zip.Dispose()}
# No disk number or unattended install arguments are passed. The operator controls the GUI.
Start-Process -FilePath $exes[0].FullName -Verb RunAs -WorkingDirectory $exes[0].DirectoryName
