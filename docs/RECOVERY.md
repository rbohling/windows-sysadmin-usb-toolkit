# Ventoy and recovery images

The toolkit never installs Ventoy, formats disks, alters partitions, or selects a target disk automatically. Installing Ventoy can erase **the entire selected disk**. Back up the USB, unplug unrelated removable storage, and check model, serial, capacity and disk number against Windows Disk Management. A drive letter alone is insufficient. Do not select an OS disk.

1. Stage Ventoy with `./Setup.ps1 -Download -Id ventoy -IncludeSpecial`. This downloads and extracts only.
2. Read the official instructions: https://www.ventoy.net/en/doc_start.html . Verify the pinned archive hash. Either open the verified extracted Ventoy2Disk.exe manually, or use `./scripts/Open-Ventoy.ps1 -IUnderstandDataLoss` and type the requested phrase to open the GUI. This helper passes no unattended installation arguments and selects no disk.
3. In the GUI, independently verify the target disk and select partition style appropriate for your hardware. Click Install only after checking backups and the exact disk. The GUI has its own destructive confirmations. Existing Ventoy Update is a separate operation; still back up first.
4. After installation, copy the whole SysAdminUSB folder to the large Ventoy data partition. Put recovery ISOs under that folder's ISO directory. No autorun or unattended installation configuration is supplied.
5. Safely eject, boot the target's one-time boot menu, select the USB, then select the recovery ISO. Test BIOS/UEFI and Secure Boot on representative hardware. Consult https://www.ventoy.net/en/doc_secure.html for key enrollment; follow organizational firmware policy. Do not disable Secure Boot as an automatic workaround.

## Pinned media

`manifests/iso.lock.json` includes exact versions, HTTPS locations, and publisher SHA-256 values for SystemRescue 13.02, Clonezilla 3.3.3-37, and GParted Live 1.8.1-6, amd64. Fixed URLs and hashes are intentionally not updated at runtime. SourceForge redirects may select a mirror; bytes must still match the embedded SHA-256.

```powershell
.\scripts\Get-RecoveryMedia.ps1                 # plan
.\scripts\Get-RecoveryMedia.ps1 -Download       # several GB, downloads only
.\scripts\Get-RecoveryMedia.ps1 -VerifyOnly     # recheck local copies
```

SHA-256 sidecars are included now and are also generated after verification. Ventoy can read `<image>.iso.sha256` for its checksum feature; see https://www.ventoy.net/en/doc_checksum.html . Verify again after copying to USB. Hash verification is not a successful boot test.

| Image | Role | Operational caution |
|---|---|---|
| SystemRescue | Offline filesystem work, recovery tools, diagnostics | Mount read-only first; preserve a failing disk image before filesystem repair |
| Clonezilla | Image and restore disks or partitions | A restore overwrites its destination; check source/destination serials |
| GParted Live | Inspect and edit partitions | Applying queued edits may destroy data; back up first |
| Memtest86+ (manual) | Boot-time RAM testing | See https://memtest.org/ for the correct image, checksum and firmware compatibility; not pinned for automated download in this snapshot |
| Windows recovery/install ISO (manual) | WinRE / supported Windows repair or installation | Obtain from https://www.microsoft.com/software-download/windows11 or your licensing portal; verify the exact SHA-256 offered by Microsoft for edition/language/version; not redistributed or automatically downloaded |

Official sources: https://www.system-rescue.org/Download/ , https://clonezilla.org/downloads.php , https://gparted.org/download.php . SystemRescue publishes detached signatures; Clonezilla and GParted publish signed checksum lists. For stronger provenance, verify those signatures with signing-key fingerprints independently confirmed from the project before use. This bundle records published hashes but does not claim to have performed GPG verification. There is no persistence, unattended Windows installation, password-reset image, or license-bypassing payload.
