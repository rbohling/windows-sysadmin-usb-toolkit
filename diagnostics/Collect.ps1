#requires -Version 5.1
[CmdletBinding()]
param(
 [ValidateSet('Network','Windows','Printers','AD','M365','Storage','Inventory','All')][string]$Area='Inventory',
 [string]$OutputDirectory=(Join-Path $PSScriptRoot '../Reports'),
 [string]$ProbeHost,[int]$ProbePort=443,
 [string]$DomainController,[string]$TenantId,[switch]$ConnectM365,
 [ValidateRange(1,1000)][int]$Limit=100
)
$ErrorActionPreference='Stop'
if($env:OS -ne 'Windows_NT'){throw 'Windows required'}
$run=Join-Path $OutputDirectory ((Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $run -Force | Out-Null
$script:results=New-Object System.Collections.Generic.List[object]
function Capture([string]$Name,[scriptblock]$Action){
 try {
  $data=@(& $Action 2>&1)
  $checkErrors=@($data | Where-Object {$_ -is [Management.Automation.ErrorRecord]})
  if($checkErrors.Count){throw ($checkErrors.Exception.Message -join '; ')}
  ConvertTo-Json -InputObject $data -Depth 8 | Set-Content -LiteralPath (Join-Path $run "$Name.json") -Encoding UTF8
  $script:results.Add(@{check=$Name;status='OK'})
 }
 catch {$script:results.Add(@{check=$Name;status='UnavailableOrFailed';reason=$_.Exception.Message})}
}
$areas=if($Area -eq 'All'){@('Network','Windows','Printers','AD','M365','Storage','Inventory')}else{@($Area)}
foreach($a in $areas){switch($a){
 Network {
  Capture 'network-addresses' {Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv6Address,IPv4DefaultGateway,DNSServer}
  Capture 'network-adapters' {Get-NetAdapter | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress}
  Capture 'network-routes' {Get-NetRoute | Select-Object DestinationPrefix,NextHop,InterfaceAlias,RouteMetric}
  Capture 'network-dns' {Get-DnsClientServerAddress | Select-Object InterfaceAlias,AddressFamily,ServerAddresses}
  Capture 'network-connections' {Get-NetTCPConnection | Select-Object State,LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess}
  if($ProbeHost){Capture 'network-probe' {Resolve-DnsName -Name $ProbeHost; Test-NetConnection -ComputerName $ProbeHost -Port $ProbePort -InformationLevel Detailed}}
 }
 Windows {
  Capture 'windows-os' {Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,LastBootUpTime,FreePhysicalMemory}
  Capture 'windows-services' {Get-Service | Select-Object Name,DisplayName,Status,StartType}
  Capture 'windows-hotfixes' {Get-HotFix | Select-Object HotFixID,Description,InstalledOn}
  Capture 'windows-system-events' {Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2,3;StartTime=(Get-Date).AddDays(-3)} -MaxEvents $Limit | Select-Object TimeCreated,Id,ProviderName,LevelDisplayName,Message}
  Capture 'windows-reboot-pending' {[pscustomobject]@{CBS=(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending');WindowsUpdate=(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')}}
 }
 Printers {
  Capture 'printers' {Get-Printer | Select-Object Name,DriverName,PortName,PrinterStatus,Shared,Published}
  Capture 'printer-ports' {Get-PrinterPort | Select-Object Name,PrinterHostAddress,PortNumber,Protocol,SNMPEnabled}
  Capture 'printer-drivers' {Get-PrinterDriver | Select-Object Name,Manufacturer,MajorVersion,InfPath}
  Capture 'printer-jobs' {Get-Printer | ForEach-Object {Get-PrintJob -PrinterName $_.Name | Select-Object PrinterName,Id,JobStatus,SubmittedTime,Size}}
  Capture 'print-spooler' {Get-Service Spooler | Select-Object Name,Status,StartType}
 }
 AD {
  Capture 'ad-computer-membership' {Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain}
  Capture 'ad-domain' {Import-Module ActiveDirectory -ErrorAction Stop; if(!$DomainController){throw 'Supply -DomainController to select a DC'}; Get-ADDomain -Server $DomainController | Select-Object DNSRoot,NetBIOSName,DomainMode,PDCEmulator,RIDMaster,InfrastructureMaster}
  Capture 'ad-dc' {if(!$DomainController){throw 'Supply -DomainController'}; Get-ADDomainController -Identity $DomainController -Server $DomainController | Select-Object HostName,Site,IPv4Address,IsGlobalCatalog,OperatingSystem}
  Capture 'ad-replication' {if(!$DomainController){throw 'Supply -DomainController'}; Get-ADReplicationFailure -Target $DomainController -Scope Server | Select-Object Server,FirstFailureTime,FailureCount,LastError,Partner}
 }
 M365 {
  Capture 'm365-context' {
   Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
   if($ConnectM365){if(!$TenantId){throw 'Supply -TenantId'}; Connect-MgGraph -TenantId $TenantId -Scopes 'Organization.Read.All' -ContextScope Process -NoWelcome}
   $ctx=Get-MgContext; if(!$ctx){throw 'No Graph session. Use -ConnectM365 -TenantId, or connect in this process first.'}
   if($TenantId -and $ctx.TenantId -ne $TenantId){throw 'Connected tenant does not match requested tenant'}
   $ctx | Select-Object TenantId,AuthType,Scopes,ContextScope
  }
  Capture 'm365-organization' {if(!(Get-Command Get-MgContext -ErrorAction SilentlyContinue)){throw 'Graph authentication module unavailable'}; $ctx=Get-MgContext; if(!$ctx -or ($TenantId -and $ctx.TenantId -ne $TenantId)){throw 'Missing or mismatched tenant session'}; Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/organization?$select=id,displayName,verifiedDomains'}
  Capture 'm365-licenses' {$ctx=Get-MgContext; if(!$ctx -or ($TenantId -and $ctx.TenantId -ne $TenantId)){throw 'Missing or mismatched tenant session'}; Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/subscribedSkus?$select=skuPartNumber,consumedUnits,prepaidUnits,capabilityStatus'}
  if($ConnectM365 -and (Get-Command Disconnect-MgGraph -ErrorAction SilentlyContinue)){Disconnect-MgGraph | Out-Null}
 }
 Storage {
  Capture 'storage-disks' {Get-Disk | Select-Object Number,FriendlyName,SerialNumber,BusType,PartitionStyle,OperationalStatus,HealthStatus,Size,IsBoot,IsSystem}
  Capture 'storage-volumes' {Get-Volume | Select-Object DriveLetter,FileSystemLabel,FileSystem,HealthStatus,Size,SizeRemaining}
  Capture 'storage-physical' {Get-PhysicalDisk | Select-Object FriendlyName,SerialNumber,MediaType,HealthStatus,OperationalStatus,Size}
  Capture 'storage-reliability' {Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId,Temperature,Wear,PowerOnHours,ReadErrorsTotal,WriteErrorsTotal}
  Capture 'storage-bitlocker' {Get-BitLockerVolume | Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionPercentage,EncryptionMethod}
 }
 Inventory {
  Capture 'inventory-system' {Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory,NumberOfLogicalProcessors,Domain}
  Capture 'inventory-bios' {Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,SerialNumber,ReleaseDate}
  Capture 'inventory-cpu' {Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors}
  Capture 'inventory-memory' {Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel,Capacity,Speed,Manufacturer,PartNumber}
  Capture 'inventory-software' {foreach($p in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')){Get-ItemProperty $p -ErrorAction SilentlyContinue | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate}}
 }
}}
@{area=$Area;collectedUtc=[DateTime]::UtcNow.ToString('o');computer=$env:COMPUTERNAME;checks=@($script:results.ToArray())} | ConvertTo-Json -Depth 5 | Set-Content "$run/summary.json" -Encoding UTF8
Write-Output $run
