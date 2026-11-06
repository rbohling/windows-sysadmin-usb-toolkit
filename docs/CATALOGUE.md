# Tool catalogue

70 open-source upstream projects: **50 pinned downloads**, **20 manual-review entries**. Some tools require host installations, proprietary dependencies, administrator access or drivers; these are explicitly labelled. Not all 70 are fully portable. Versions shown are this fixed snapshot, not a promise of newest or vulnerability-free versions.

Pinned means a version, exact asset URL and expected SHA-256 are in the lock. Manual entries are optional references and are never fetched by Setup. See MANUAL.md for prerequisites and INTEGRITY.md for trust limits.

## Backup

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `restic` / [restic](https://github.com/restic/restic) | Encrypted deduplicated backups | CLI | v0.19.1 | Pinned |
| `freefilesync` / [freefilesync](https://freefilesync.org/download.php) | File comparison and synchronization | Manual-installer | manual selection | Manual-review-required |
| `syncthing` / [syncthing](https://github.com/syncthing/syncthing) | Peer-to-peer folder synchronization | Portable-network-service | v2.1.7 | Pinned |
| `kopia` / [kopia](https://github.com/kopia/kopia) | Encrypted snapshot backups | CLI | v0.23.1 | Pinned |

## Data

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `sqlitebrowser` / [DB Browser for SQLite](https://github.com/sqlitebrowser/sqlitebrowser) | SQLite inspection and editing | Portable | v3.13.1 | Pinned |
| `dbeaver` / [dbeaver](https://github.com/dbeaver/dbeaver) | Database client (drivers may need network) | Portable | 26.2.4 | Pinned |
| `jq` / [jq](https://github.com/jqlang/jq) | JSON transformation and inspection | CLI | jq-1.8.2 | Pinned |
| `yq` / [yq](https://github.com/mikefarah/yq) | YAML/JSON transformation | CLI | v4.54.2 | Pinned |

## Editors

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `notepadplusplus` / [notepadplusplus](https://github.com/notepad-plus-plus/notepad-plus-plus) | Text/configuration editing | Portable | v8.9.9 | Pinned |
| `vscodium` / [vscodium](https://github.com/VSCodium/vscodium) | Code/configuration editor | Portable | 1.143.17232 | Pinned |

## Files

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `7zip` / [7-Zip](https://github.com/ip7z/7zip) | Archive management (selected asset is installer) | Installer | 26.05 | Pinned |
| `peazip` / [peazip](https://github.com/peazip/PeaZip) | Portable graphical archive manager | Portable | 11.4.0 | Pinned |
| `rclone` / [rclone](https://github.com/rclone/rclone) | Cloud and filesystem copy/sync | CLI | v1.76.0 | Pinned |
| `duplicates` / [Czkawka CLI](https://github.com/qarmin/czkawka) | Duplicate and redundant file discovery | CLI | 12.0.2 | Pinned |
| `everything-alternative` / [EverythingToolbar](https://github.com/stnkl/EverythingToolbar) | Toolbar for proprietary Everything indexer | Installer-requires-proprietary-Everything | manual selection | Manual-review-required |
| `doublecommander` / [doublecommander](https://github.com/doublecmd/doublecmd) | Dual-pane file manager | Portable | v1.2.10 | Pinned |
| `ripgrep` / [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive text search | CLI | 15.2.0 | Pinned |
| `fd` / [fd](https://github.com/sharkdp/fd) | File path discovery | CLI | v10.5.1 | Pinned |
| `bat` / [bat](https://github.com/sharkdp/bat) | Syntax-highlighted file viewing | CLI | v0.26.1 | Pinned |
| `delta` / [delta](https://github.com/dandavison/delta) | Readable text/Git diffs | CLI | 0.20.1 | Pinned |
| `eza` / [eza](https://github.com/eza-community/eza) | Detailed directory listings | CLI | v0.23.5 | Pinned |
| `yazi` / [yazi](https://github.com/sxyazi/yazi) | Terminal file manager | CLI | v26.9.1 | Pinned |
| `sd` / [sd](https://github.com/chmln/sd) | Text replacement (writes when requested) | CLI | v1.1.0 | Pinned |
| `hexyl` / [hexyl](https://github.com/sharkdp/hexyl) | Hexadecimal file viewer | CLI | v0.17.0 | Pinned |
| `lsd` / [lsd](https://github.com/lsd-rs/lsd) | Readable directory listings | CLI | v1.2.0 | Pinned |

## Hardware

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `hwinfo-alternative` / [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) | Hardware sensor inspection | Admin-driver | v0.9.6 | Pinned |

## Inventory

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `osquery` / [osquery](https://github.com/osquery/osquery) | SQL-based endpoint inventory | Admin-some-tables | 5.24.1 | Pinned |
| `fastfetch` / [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Quick system summary | CLI | 2.71.0 | Pinned |
| `bottom` / [bottom](https://github.com/ClementTsang/bottom) | Terminal process/resource monitor | CLI | 0.15.0 | Pinned |

## Network

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `putty` / [putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) | SSH and serial-console client | Manual | manual selection | Manual-review-required |
| `winscp` / [winscp](https://winscp.net/eng/downloads.php) | SFTP/SCP file transfer | Portable | manual selection | Manual-review-required |
| `rustscan` / [rustscan](https://github.com/bee-san/RustScan) | Port discovery (Windows builds need validation) | CLI | 2.4.1 | Manual-review-required |
| `angryip` / [angryip](https://github.com/angryip/ipscan) | IP address discovery | Requires-Java | 3.12.1 | Pinned |
| `portmaster` / [portmaster](https://safing.io/portmaster/) | Host firewall and connection monitoring | Installer-driver | manual selection | Manual-review-required |
| `wireshark` / [wireshark](https://www.wireshark.org/download.html) | Packet inspection and capture | Installer-driver | manual selection | Manual-review-required |
| `nmap` / [nmap](https://nmap.org/download.html) | Network/service discovery | Installer-driver | manual selection | Manual-review-required |
| `iperf` / [iperf](https://iperf.fr/iperf-download.php) | TCP/UDP throughput testing | Manual | manual selection | Manual-review-required |
| `curl` / [curl](https://curl.se/windows/) | HTTP/TLS transfer diagnostics | Manual | manual selection | Manual-review-required |
| `dnslookup` / [dnslookup](https://github.com/ameshkov/dnslookup) | DNS query command | CLI | v1.12.0 | Pinned |
| `doggo` / [doggo](https://github.com/mr-karan/doggo) | DNS lookup and response inspection | CLI | v1.4.2 | Pinned |
| `trippy` / [trippy](https://github.com/fujiapple852/trippy) | Route and latency tracing | Admin-raw-sockets | 0.13.0 | Manual-review-required |
| `tcping` / [tcping](https://github.com/pouriyajamshidi/tcping) | TCP connectivity timing | CLI | v2.8.0 | Pinned |
| `termshark` / [termshark](https://github.com/gcla/termshark) | Terminal UI over tshark packet captures | Requires-tshark-Npcap | v2.4.0 | Pinned |
| `filezilla` / [filezilla](https://filezilla-project.org/download.php?type=client) | SFTP/FTP file transfer | Manual | manual selection | Manual-review-required |

## Recovery

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `ventoy` / [ventoy](https://github.com/ventoy/Ventoy) | Bootable multi-ISO USB preparation | Destructive-opt-in | v1.1.18 | Pinned |
| `rufus` / [rufus](https://github.com/pbatard/rufus) | Bootable USB media creation | Destructive-opt-in | v4.15 | Pinned |
| `memtest86plus` / [Memtest86+](https://memtest.org/) | Boot-time memory testing | Boot-image | v9.00 | Manual-review-required |

## Remote

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `rustdesk` / [rustdesk](https://github.com/rustdesk/rustdesk) | Remote desktop support | Portable-admin-for-service | 1.5.1 | Pinned |

## Security

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `keepassxc` / [keepassxc](https://github.com/keepassxreboot/keepassxc) | Local password database management | Portable | 2.8.0 | Pinned |
| `veracrypt` / [veracrypt](https://veracrypt.io/en/Downloads.html) | Encrypted container access (driver required) | Admin-driver | manual selection | Manual-review-required |
| `gpg4win` / [gpg4win](https://www.gpg4win.org/download.html) | GPG signature and encryption workflows | Installer | manual selection | Manual-review-required |
| `yara` / [yara](https://github.com/VirusTotal/yara) | Rule-based file matching; rules not bundled | CLI | v4.6.0 | Pinned |
| `hayabusa` / [hayabusa](https://github.com/Yamato-Security/hayabusa) | Windows event-log investigation; check bundled rules | CLI | v4.3.1 | Pinned |
| `chainsaw` / [chainsaw](https://github.com/WithSecureLabs/chainsaw) | Windows event-log hunting; supply reviewed rules/mappings | CLI | v2.17.1 | Pinned |

## Shell

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `powershell` / [powershell](https://github.com/PowerShell/PowerShell) | Cross-platform administrative shell | Portable | v7.6.9 | Pinned |
| `git` / [git](https://github.com/git-for-windows/git) | Portable Git and shell (extract manually) | Self-extracting | v2.56.0.windows.4 | Pinned |
| `fzf` / [fzf](https://github.com/junegunn/fzf) | Interactive fuzzy selection | CLI | v0.74.5 | Pinned |
| `zoxide` / [zoxide](https://github.com/ajeetdsouza/zoxide) | Shell directory navigation database | CLI | v0.10.0 | Pinned |
| `nushell` / [nushell](https://github.com/nushell/nushell) | Structured-data command shell | CLI | 0.116.1 | Pinned |
| `hyperfine` / [hyperfine](https://github.com/sharkdp/hyperfine) | Command runtime benchmarking | CLI | v2.0.0 | Pinned |

## Storage

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `crystaldiskinfo` / [crystaldiskinfo](https://crystalmark.info/en/software/crystaldiskinfo/) | Drive health and SMART inspection | Manual-admin | manual selection | Manual-review-required |
| `crystaldiskmark` / [crystaldiskmark](https://crystalmark.info/en/software/crystaldiskmark/) | Storage write/read benchmarks | Manual-writes-storage | manual selection | Manual-review-required |
| `smartmontools` / [smartmontools](https://www.smartmontools.org/) | Drive SMART/device diagnostics | Installer-admin | manual selection | Manual-review-required |
| `gsmartcontrol` / [gsmartcontrol](https://github.com/ashaduri/gsmartcontrol) | Graphical SMART inspection | Admin | v2.0.2 | Manual-review-required |
| `wiztree-alternative` / [WinDirStat](https://github.com/windirstat/windirstat) | Directory disk-usage visualization | Portable-admin-some-paths | release/v2.9.3 | Pinned |
| `duf` / [duf](https://github.com/muesli/duf) | Filesystem free-space summary | CLI | v0.9.1 | Pinned |
| `dust` / [dust](https://github.com/bootandy/dust) | Directory usage summary | CLI | v1.2.7 | Pinned |

## Windows

| ID / project | Purpose | Class | Version | Download status |
|---|---|---|---|---|
| `processhacker-successor` / [System Informer](https://github.com/winsiderss/systeminformer) | Advanced process and service inspection | Admin-driver | v4.0.26241.138 | Pinned |
| `regshot` / [regshot](https://sourceforge.net/projects/regshot/) | Registry snapshot comparison | Manual | manual selection | Manual-review-required |
| `bleachbit` / [bleachbit](https://github.com/bleachbit/bleachbit) | Cleaning and file deletion (operator-controlled) | Portable-writes-files | v6.0.6 | Pinned |

