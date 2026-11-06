#requires -Version 5.1
[CmdletBinding()]
param([string]$Destination)
. "$PSScriptRoot/Common.ps1"
$root=Get-ToolkitRoot
if(!$Destination){$Destination=Join-Path (Split-Path $root) 'SysAdminUSB.zip'}
$Destination=[IO.Path]::GetFullPath($Destination)
if(Test-Path -LiteralPath $Destination){throw 'Destination already exists; choose a new filename'}
if($Destination.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'ZIP destination must be outside toolkit root'}
$files=@(Get-ChildItem -LiteralPath $root -Recurse -File -Force | Where-Object {
 $rel=$_.FullName.Substring($root.Length+1).Replace('\','/')
 $rel -ne 'PACKAGE-SHA256SUMS.txt' -and ($rel -notmatch '^(Cache|Tools|Reports)/' -or $rel -match '^(Cache|Tools|Reports)/\.gitkeep$') -and $rel -notmatch '^ISO/.*\.(iso|img)$' -and $rel -notmatch '^\.git/'
} | Sort-Object FullName)
$lines=@(foreach($f in $files){(Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()+' *'+$f.FullName.Substring($root.Length+1).Replace('\','/')})
$lines | Set-Content -LiteralPath "$root/PACKAGE-SHA256SUMS.txt" -Encoding ASCII
$files+=Get-Item -LiteralPath "$root/PACKAGE-SHA256SUMS.txt"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::Open($Destination,'Create')
$success=$false
try{
 foreach($f in $files | Sort-Object FullName){
  $relative=$f.FullName.Substring($root.Length+1).Replace('\','/')
  $entry=$zip.CreateEntry(('SysAdminUSB/'+$relative),[IO.Compression.CompressionLevel]::Optimal)
  $entry.LastWriteTime=[DateTimeOffset]::new(2026,11,6,0,0,0,[TimeSpan]::Zero)
  $inputStream=[IO.File]::OpenRead($f.FullName)
  try{$outputStream=$entry.Open();try{$inputStream.CopyTo($outputStream)}finally{$outputStream.Dispose()}}finally{$inputStream.Dispose()}
 }
 $success=$true
}finally{$zip.Dispose();if(!$success){Remove-Item -LiteralPath $Destination}}
((Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash.ToLowerInvariant()+' *'+[IO.Path]::GetFileName($Destination)) | Set-Content -LiteralPath ($Destination+'.sha256') -Encoding ASCII
Write-Output $Destination
