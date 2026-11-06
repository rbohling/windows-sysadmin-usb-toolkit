# Diagnostic collection

Each invocation writes JSON results plus `summary.json` to a unique `Reports/<timestamp>-<random>/` directory. Each check records OK or UnavailableOrFailed; inaccessible features do not prevent other checks. Review the summary: a created report is not proof every check succeeded. These are bounded snapshots, not a monitoring or repair suite.

```powershell
.\diagnostics\Collect.ps1 -Area Network
# Optional explicit DNS lookup and outbound TCP probe to your selected endpoint
.\diagnostics\Collect.ps1 -Area Network -ProbeHost dc01.example.org -ProbePort 389
.\diagnostics\Collect.ps1 -Area Windows -Limit 100
.\diagnostics\Collect.ps1 -Area Printers
.\diagnostics\Collect.ps1 -Area Storage
.\diagnostics\Collect.ps1 -Area Inventory
.\diagnostics\Collect.ps1 -Area AD -DomainController dc01.example.org
.\diagnostics\Collect.ps1 -Area M365 -TenantId '<tenant-guid>' -ConnectM365
.\diagnostics\Collect.ps1 -Area All -DomainController dc01.example.org
```

| Area | Collected | Requirements / limits |
|---|---|---|
| Network | Addresses, adapters, routes, DNS servers, TCP connections, optional DNS/TCP probe | NetTCPIP/DnsClient modules; some details need admin; no scan by default |
| Windows | OS/build/uptime, services, hotfix list, last three days of bounded system errors/warnings, two reboot flags | Event-log access; hotfix list is not full update compliance; no DISM/SFC repairs |
| Printers | Queues, ports, drivers, jobs without document/user names, spooler status | PrintManagement module; spooler access; no clearing or restarting |
| AD | Membership, domain roles, selected DC, replication failure records | RSAT ActiveDirectory module, domain connectivity, authorized credentials; no domain-wide user enumeration; absence of failure records is not a complete AD health check |
| M365 | Tenant context, organization domains, subscribed SKU consumption | Microsoft.Graph.Authentication, interactive login, Organization.Read.All delegated consent, internet; no embedded credentials or tokens in reports; no automatic consent or module installation |
| Storage | Disks/volumes, physical disks, available reliability counters, BitLocker state | Storage module, BitLocker cmdlets and admin for some counters; controllers may omit SMART; never exports recovery keys or runs write benchmarks |
| Inventory | Manufacturer/model, BIOS serial, CPU, memory, uninstall-registry software inventory | CIM/registry access; excludes Win32_Product to avoid MSI repair side effects; no other users' profiles or complete MSIX inventory |

Run initially without elevation. Elevate deliberately when a needed check is denied. For AD, install the appropriate Windows RSAT optional feature through your approved Windows management process; it is host software, not a USB-portable dependency. Graph auth module likewise requires a separately reviewed install or module folder. PowerShell 7 may need Windows PowerShell for some Windows-only modules. Neither prerequisite is silently installed.

M365 uses the process context and disconnects a session it was explicitly asked to connect. `-Area All` never logs in unless `-ConnectM365` is provided. A pre-existing process session can be used when invoking from the same PowerShell process. Do not pass credentials on the command line. Graph responses are limited to tenant and license data; this is not Exchange/Teams/SharePoint service health or a tenant security audit. Organization.Read.All may require administrator consent; consent remains an operator action.

Reports contain hostnames, IP addresses, MACs, serials, software inventory, event messages, and tenant information. Store them on approved encrypted storage and redact before sharing. The collector does not upload reports. Optional TCP/DNS probes and AD/M365 queries do contact their targets. Changing hosts' services, policy, drivers, printer jobs or directory objects is outside this collector.
