# Validation record

Snapshot built on 2026-11-06 for Windows x64.

## Completed

* PowerShell 7.6.9: all distributed PowerShell scripts parse and the 10-check offline test suite passes.
* Tool lock: 70 unique IDs, 50 exact-version SHA-256 pins, 20 explicitly manual-review entries. Pinned filenames checked against ARM64/i686/32-bit selection mistakes. Manual entries are skipped rather than downloaded without expected hashes.
* ISO lock: three fixed versions with full publisher SHA-256 values and sidecars; official SystemRescue, Clonezilla and GParted checksum sources recorded.
* Fixtures: valid and corrupted bytes, missing hashes, ordinary ZIP extraction, traversal/rooted/alternate-stream paths, symlink rejection, offline staging and repeat invocation, receipt creation, staged-file tampering, unknown tool IDs, and Ventoy's opt-in guard.
* Collector tests: unavailable AD prerequisites recorded per check; simulated nonterminating printer errors recorded as failures while later checks continue.
* Real upstream download smoke test: jq, ripgrep and Notepad++ archives/assets fetched from the locked URLs, SHA-256 matched, and files staged successfully. jq and ripgrep help commands executed successfully through the launcher. Notepad++ GUI was not opened.
* Additional real downloads: Restic, Hayabusa, WinDirStat and x64 osquery matched locked hashes and staged. Archive inspection confirmed versioned executable names and WinDirStat's explicit x64 executable path. Restic's version command passed through the launcher after fixing single-argument forwarding. Administrative tools and Hayabusa were not executed.
* A local all-area diagnostic smoke run exercised report generation and graceful prerequisite/access failures. Windows management access is restricted in this environment; successful machine health collection is not claimed. No cloud authentication or directory mutation was performed.

## Limits and operator acceptance

Windows PowerShell 5.1 execution remains **unconfirmed**. The initial process was blocked by local script policy, and a process-scoped local-script test could not load built-in commands in the restricted environment. The requested unrestricted 5.1 test was declined. No persistent execution policy was changed. PowerShell 7 is the validated path; use `pwsh -NoProfile -File ./scripts/Test-Toolkit.ps1` first. Syntax targets 5.1, but that is not a runtime compatibility guarantee.

Not every tool was downloaded, executed, malware-scanned or tested with its drivers, runtime dependencies, workloads or update settings. Hash pins do not certify safety or license compliance. AD/RSAT and live M365 authentication/permissions were not tested against an organization. No full ISO download or firmware boot test was performed here. Detached publisher signatures were not independently verified. No Ventoy/Rufus UI was launched, USB was formatted, partition was changed, or recovery image was booted.

Before operational use, run the suite on your intended host; select and stage required tools; check their version/help and prerequisites; collect one report per required area with authorized access; verify copied ISO hashes; and perform a representative USB boot test. Keep production recovery backups independent of this USB.

## Re-run

```powershell
pwsh -NoProfile -File .\scripts\Test-Toolkit.ps1
pwsh -NoProfile -File .\scripts\Verify-Package.ps1
```

Test fixtures are kept under `Reports/SysAdminUSB-test-*` for inspection and excluded from repository/package payloads. `Build-Package.ps1` regenerates file checksums and creates a source ZIP outside the toolkit folder; it excludes downloaded tools, caches, reports and ISO payloads. Existing ZIP destinations are refused.
