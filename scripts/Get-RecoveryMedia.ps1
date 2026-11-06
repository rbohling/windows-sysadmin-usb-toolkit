#requires -Version 5.1
[CmdletBinding()]
param([string[]]$Id,[switch]$Download,[switch]$VerifyOnly)
. "$PSScriptRoot/Common.ps1"
$root=Get-ToolkitRoot
$all=@((Get-Content "$root/manifests/iso.lock.json" -Raw | ConvertFrom-Json).images)
if($Id){foreach($i in $Id){if($i -notin $all.id){throw "Unknown image id: $i"}}}
$images=@($all | Where-Object {!$Id -or $_.id -in $Id})
if($Download -and $VerifyOnly){throw 'Choose Download or VerifyOnly'}
if(!$Download -and !$VerifyOnly){$images | Select-Object id,version,file,purpose; return}
New-Item -ItemType Directory -Force "$root/ISO" | Out-Null
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
foreach($i in $images){
 if($i.file -ne [IO.Path]::GetFileName($i.file) -or $i.file -match '[\\/:]'){throw 'Unsafe filename'}
 $u=[uri]$i.url
 if($u.Scheme -ne 'https' -or $u.Host -notin @('fastly-cdn.system-rescue.org','downloads.sourceforge.net')){throw 'Unexpected ISO host'}
 $path=Join-Path "$root/ISO" $i.file
 if(!(Test-Path -LiteralPath $path)){
  if($VerifyOnly){throw "Missing ISO: $path"}
  $temp=$path+'.'+[guid]::NewGuid().ToString('N')+'.part'
  Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $temp -TimeoutSec 3600 -UserAgent 'SysAdminUSB/1'
  Assert-Hash $temp $i.sha256
  Move-Item -LiteralPath $temp -Destination $path
 }
 Assert-Hash $path $i.sha256
 ($i.sha256+' *'+$i.file) | Set-Content -LiteralPath ($path+'.sha256') -Encoding ASCII
 Write-Host "$($i.id): SHA-256 verified"
}
