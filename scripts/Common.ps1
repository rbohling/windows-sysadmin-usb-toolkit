Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
function Get-ToolkitRoot { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }
function Assert-Hash([string]$Path,[string]$SHA256) {
 if($SHA256 -notmatch '^[a-fA-F0-9]{64}$'){throw 'Missing or invalid pinned SHA-256'}
 if(!(Test-Path -LiteralPath $Path -PathType Leaf)){throw "Missing file: $Path"}
 if((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $SHA256){throw "SHA-256 mismatch: $Path"}
}
function Get-Lock {
 $lock=Get-Content -LiteralPath (Join-Path (Get-ToolkitRoot) 'manifests/tools.lock.json') -Raw | ConvertFrom-Json
 foreach($t in $lock.tools){
  if($t.id -notmatch '^[a-z0-9-]+$'){throw 'Unsafe tool id'}
  if($t.status -ne 'Pinned'){continue}
  $u=[uri]$t.url
  if($u.Scheme -ne 'https' -or $u.Host -ne 'github.com' -or $u.AbsolutePath -notlike '/*/*/releases/download/*'){throw "Untrusted URL: $u"}
  if($t.file -ne [IO.Path]::GetFileName($t.file) -or $t.file -match '[\\/:]'){throw 'Unsafe filename'}
  if($t.sha256 -notmatch '^[a-fA-F0-9]{64}$'){throw "Missing hash: $($t.id)"}
 }
 return $lock
}
function Expand-SafeZip([string]$Archive,[string]$Destination) {
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $base=[IO.Path]::GetFullPath($Destination)+[IO.Path]::DirectorySeparatorChar
 $zip=[IO.Compression.ZipFile]::OpenRead($Archive)
 try {
  [long]$total=0
  foreach($e in $zip.Entries){
   $total+=$e.Length
   if($total -gt 12GB){throw 'Archive expands beyond 12 GiB limit'}
   $name=$e.FullName.Replace('\','/')
   if($name -match '(^/|:|(^|/)\.\.(/|$))' -or (($e.ExternalAttributes -shr 16) -band 0xF000) -eq 0xA000){throw "Unsafe ZIP entry: $name"}
   $target=[IO.Path]::GetFullPath((Join-Path $Destination $name))
   if(!$target.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)){throw 'ZIP escaped extraction directory'}
  }
 } finally {$zip.Dispose()}
 [IO.Compression.ZipFile]::ExtractToDirectory($Archive,$Destination)
}
