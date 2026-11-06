# Integrity, provenance and reproducibility

The tool lock contains fixed release versions, exact asset URLs, SHA-256 and provenance URLs. `Pinned` entries use GitHub release API `digest: sha256:...` metadata from the named upstream repository, unless a different hash source is explicitly recorded. This is repository-hosted release provenance over HTTPS, not independent code-signature or reproducible-build verification. A hash establishes byte identity, not that software is harmless. The snapshot does not use a mutable latest URL during setup. Manual entries never bypass hash checks: they are not downloaded.

Setup checks existing cache too; a successful earlier download does not exempt it. Only a file matching the lock is copied/extracted. ZIP entries are checked for traversal, rooted paths, alternate data streams and symbolic links before extraction; expansion is bounded to 12 GiB. Setup never executes an archive or installer. PowerShell self-extracting assets are staged as files, not invoked. Launcher checks the staged receipt before starting a tool. Receipts detect accidental file changes against extraction-time measurements, but are not signed and do not protect against someone editing both receipt and payload. Keep toolkit scripts, manifests and receipts on trusted storage.

## Verify the deliverable

Run `./scripts/Test-Toolkit.ps1` to parse scripts, validate locks and run isolated fixture tests. `PACKAGE-SHA256SUMS.txt` lists all distributed files except itself. Verify from the root:

```powershell
.\scripts\Verify-Package.ps1
```

Keep the ZIP's adjacent `.sha256` outside the USB as a reference. A hash file distributed with a ZIP is useful against corruption, not against an attacker replacing both. No signing key is provided. Do not replace trust with certificate-validation bypasses.

## Updating

Review new versions and upstream advisories; pins do not update themselves. Resolve the exact Windows x64 asset from the official project, capture its version, URL, full SHA-256 and hashSource, then edit the lock in a reviewed commit. Obtain the expected hash from publisher metadata/checksum or independently authenticated signed list. Never set a hash solely to silence a mismatch. No automatic trust-on-first-use or runtime lock regeneration exists. `manifests/provenance.json` preserves selected upstream asset metadata as build evidence, not an update feed.

After changing a lock, run tests, stage the selected assets on a test machine, run their help/version commands where safe, then regenerate package checksums. Record any manual pin's source and validation in the commit. If a project removes a pinned release, setup fails; investigate an official archive rather than silently downloading a replacement.

Offline reproduction requires the original verified Cache folder, matching scripts/locks, supported Windows and required host modules. Preserve that cache in your own controlled artifact store. Git excludes Cache, Tools, Reports and ISO payloads. Deterministic byte selection is provided; availability of upstream servers, extracted timestamps, runtime dependencies and tool behavior is not guaranteed.
