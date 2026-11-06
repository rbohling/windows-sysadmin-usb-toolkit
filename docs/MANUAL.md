# Portable versus host-dependent tools

The catalogue's operational class matters more than its folder location. Portable means a runnable distribution without a conventional install; it may still write settings to AppData, contact update servers, require a runtime, or need elevation for particular functions. The collection is x64; ARM64 and 32-bit Windows need separate reviewed locks.

* `Portable`, `CLI`: normally stage without elevation. CLI launcher shows help; invoke the verified executable directly for actual commands. Some apps still need VC++/.NET runtimes on the host.
* `Requires-Java`: Angry IP Scanner's standalone executable needs a compatible Java runtime. No Java is installed by this toolkit.
* `Admin`, `Admin-raw-sockets`, `Admin-some-tables`: elevated privileges may be necessary. Tools are never automatically elevated by the general launcher.
* `Admin-driver`, `Installer-driver`: hardware inspection, System Informer, capture and encryption tools can load/install kernel drivers. They are not strictly portable or zero footprint. Consult organizational driver policy. Wireshark capture and some Nmap scans need Npcap, which is a separately licensed host installation. No Npcap installer is bundled.
* `Installer`: the downloaded file is installation media. Setup never runs it; general launcher refuses it. 7-Zip's selected asset is its x64 installer; PeaZip is the ready-to-extract alternative.
* `Self-extracting`: PortableGit is staged as a self-extracting archive. Extract manually to an approved folder and use Git there; the launcher does not execute the extractor.
* `Portable-network-service`: Syncthing can listen on network interfaces and sync files. Configure folders, bind addresses and authentication deliberately before use.
* `Portable-writes-files` / storage benchmarks: deletion, cleaning, synchronization, restore, encryption, imaging and benchmarks can change data even from portable apps. This toolkit never invokes those operations.
* `Destructive-opt-in`, `Boot-image`: recovery/media tools are never run by the general launcher. See RECOVERY.md.

## Manual-review catalogue entries

Entries marked `Manual-review-required` are a documented optional catalogue, **not** an automated or checksum-approved download. Their official source is in CATALOGUE.md. Some projects publish on non-GitHub hosts; some selected releases lack a repository SHA-256 digest; some have no matching portable asset. This is reported rather than substituted with an unverified package. No blank hash is ever accepted by Setup.

To add one, review its current license and official download, select the exact architecture and distribution type, obtain an authenticated publisher hash, and commit an exact version/URL/SHA-256/hashSource. The automated downloader currently trusts GitHub release URLs only; a non-GitHub source requires a reviewed host-policy change in Common.ps1 as well. You can instead download manually, compare with the publisher's hash and keep it under a clearly separate `ManualTools` folder. The launcher deliberately does not search or execute that folder. Manual tools are not covered by the automatic receipt checks.

PuTTY, WinSCP and FileZilla have official portable/standalone options; select those rather than their installers. curl's official Windows builds include architecture-specific packages. VeraCrypt portable mode still needs an administrative kernel driver. Smartmontools and GSmartControl need administrative device access. CrystalDiskMark writes test data and is not a read-only diagnostic. FreeFileSync can change both sides of a sync. EverythingToolbar depends on proprietary Everything and is not a standalone open-source search engine; omit it if an all-open-source build is required. `ripgrep` and `fd` provide independent file searches.

Read upstream licenses before redistributing populated USBs. Catalogue open-source labels describe upstream projects, not every runtime/driver/transitive component. This source bundle is MIT-licensed; downloaded tools retain their own licenses and notices. Keep upstream notices with extracted files. AD RSAT, Windows, and Microsoft cloud services are proprietary host/service prerequisites and are not bundled.
