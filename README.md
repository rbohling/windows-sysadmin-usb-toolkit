# Windows SysAdmin USB toolkit

Repository-ready source bundle, Windows x64. Windows PowerShell 5.1 or PowerShell 7; supported Windows 11 / Windows Server recommended. Read `docs/CATALOGUE.md` for actual pinned/manual counts. Third-party executables and multi-gigabyte ISOs are downloaded separately: this ZIP contains scripts, locks, hash sidecars, and documentation, not a pre-populated USB image.

## Quick start

Extract this folder to a local staging directory. Review scripts and lock files before executing. Open a normal PowerShell window in this folder:

```powershell
# Read-only plan; no network or disk setup
.\Setup.ps1
# Download and SHA-256 verify available ordinary tools
.\Setup.ps1 -Download
# Or select only a few
.\Setup.ps1 -Download -Id jq,ripgrep,notepadplusplus
# Repeat using already downloaded cache, without network
.\Setup.ps1 -Offline
# List and open a staged tool (CLI entries show their help)
.\Launch.ps1 -List
.\Launch.ps1 -Id notepadplusplus
.\Launch.ps1 -Id jq
.\Launch.ps1 -Id jq -ToolArguments @('--version')
# Collect local inventory; outputs a unique report folder
.\diagnostics\Collect.ps1 -Area Inventory
```

If Windows blocks downloaded scripts, inspect them and use `Unblock-File` on the reviewed files as permitted by your organization. No execution-policy changes are made by the toolkit. Scripts are unsigned. Do not disable organizational application controls.

## Layout

```text
SysAdminUSB/
  Setup.ps1                 plan, fetch, hash, stage; never executes downloads
  Launch.ps1 / Start.cmd    catalogue and guarded launches
  manifests/               fixed versions, URLs, SHA-256, provenance
  scripts/                 common helpers, recovery downloader, Ventoy GUI opt-in
  diagnostics/Collect.ps1   seven diagnostic areas
  Tools/<id>/<sha256>/      extracted or copied verified tools + receipts
  Cache/                   verified original distribution files, offline reuse
  ISO/                     recovery images and matching .iso.sha256 sidecars
  Reports/                 diagnostic output; private, excluded from Git
  docs/                    catalogue, prerequisites, recovery, integrity, validation
```

Setup defaults to a plan. `-Download` enables network; `-Offline` requires verified cached files. `-IncludeSpecial` only stages installer, driver, self-extracting and destructive tools; it never runs them. Manual-review entries are skipped and explicitly reported. Failures produce a non-successful script result after other selected tools are attempted. Failed `.part` files remain untrusted and are never staged. Re-running reuses valid downloads. Hash mismatch fails closed; remove the offending cache file only after investigating.

Build on a local disk first. If adding Ventoy, install it manually on a backed-up USB **before** copying this toolkit and ISO folder onto the large data partition. Do not run Ventoy installation against the only copy of your toolkit. Use a 64 GB or larger USB for a useful selection; allow more for backups and ISOs. exFAT supports files over 4 GB. Some software writes configuration to the host even when runnable without installation: portable does not mean zero footprint.

See `docs/DIAGNOSTICS.md`, `docs/RECOVERY.md`, `docs/INTEGRITY.md`, and `docs/VALIDATION.md`. Nothing installs software, changes network configuration, repairs Windows, clears printer jobs, changes AD/M365 objects, or formats disks automatically.
