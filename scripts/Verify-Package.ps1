#requires -Version 5.1
[CmdletBinding()]
param()
. "$PSScriptRoot/Common.ps1"
$root=Get-ToolkitRoot
foreach($line in (Get-Content -LiteralPath "$root/PACKAGE-SHA256SUMS.txt")){
 if($line -notmatch '^([a-fA-F0-9]{64}) \*(.+)$'){throw 'Invalid package checksum line'}
 $sha=$Matches[1];$relative=$Matches[2]
 $full=[IO.Path]::GetFullPath((Join-Path $root $relative))
 if(!$full.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe checksum path'}
 Assert-Hash $full $sha
}
Write-Output 'All listed package files verified.'
