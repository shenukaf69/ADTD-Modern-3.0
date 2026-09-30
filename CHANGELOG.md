# Changelog

## Unreleased

- Fixed: on Windows PowerShell 5.1 (and so in `ADTD.exe`), every run that saved a draw.io drawing without `-Offline` stopped with "Exception calling "EscapeDataString" with "1" argument(s): Invalid URI: The Uri string is too long". .NET Framework's `[uri]::EscapeDataString` refuses text longer than about 65,000 characters, and the draw.io web link escapes the whole drawing. The text is now escaped in chunks. New tests round-trip a full-size drawing through the web link and check that chunking keeps emoji and other surrogate pairs whole. Found in lab testing on Windows Server 2022.
- Fixed: every domain controller showed "Unknown Windows version", the Summary said it needed attention, the hybrid topology said it needed replacing, and H03 fired. The global catalog search for DC computer accounts returned the accounts but not `operatingSystem`. ADTD now reads the DC's own computer account in its domain when the global catalog leaves the OS out. The offline tests' global catalog now omits the OS the same way, so this is covered. Found in lab testing on Windows Server 2022.
- The log no longer warns about things that simply aren't deployed. A missing Exchange organization, AD FS container, device registration point or LAPS schema is logged as "Not found" instead of a warning ending in "exception occurred while retrieving member Dispose"; real read errors keep their warning, now with the actual error text.
- **User account summary.** The HTML reports' Inventory has a new **User accounts** table, and there is a new `user-summary.csv`: per domain (plus an all-domains total), the number of accounts in total, enabled, disabled, stale for 90 days, with passwords that never expire or aren't required, without Kerberos pre-authentication, with SPNs, privileged, with SID history, RC4-only, with reversible encryption, trusted for unconstrained delegation, and without a UPN. Counts only: no account names, which stay in the findings. The counts are no longer capped at 200 like the evidence lists. The draw.io **Summary** page has a new **Enabled users** tile.
- **Microsoft references reviewed against current Microsoft Learn (2026-09-30).** All 38 existing links still resolve. Findings now also point to the more specific current articles: RC4 detection and remediation (S17), Defender for Identity's built-in Administrator password (S07), dormant sensitive accounts (S08), operator groups (S09), SID history (S21) and LAPS usage (S24, S26) assessments, domain join permissions (S22), certificate templates with Any Purpose or no EKU, which explains SubCA appearing in S30 (ESC2), and raising functional levels (H04, H05). "Check by hand" items now link to LDAP signing and channel binding, disabling Print Spooler on DCs, the forest recovery guide, and Entra emergency access accounts. The stale accounts link opens its own section. `docs/FINDINGS.md` is regenerated.
- The window now says clearly when a run succeeds: a **"ADTD finished successfully"** message with the summary and the output folder, a green **Finished successfully.** in the status bar, and a matching line in Activity. Before, only the status bar changed, and long summaries were cut off. Errors now show in red in the status bar.

## 3.0.3 (2026-09-27)

- Fixed: the window showed "Cannot convert null to type System.Drawing.Color" errors when it closed, and the Activity box, status bar, **Select all / Recommended / Clear** links and **Test connection** result lost their colours. Two loops reused the name of the window's colour theme variable (PowerShell names ignore case). The theme variable is renamed, and a new test catches variable names that differ only in case.

## 3.0.2 (2026-09-27)

- **ADTD Modern is now an app with its own icon.** `ADTD.exe` opens the window, so the taskbar, Start menu, desktop shortcut and Settings → Apps show the ADTD Modern icon instead of PowerShell's, and you can pin it to the taskbar. It is DPI aware, so text stays sharp on high-resolution screens. Source: `launcher/ADTD.cs`.
- **Redesigned window**: a header banner with the app icon, and four numbered cards (Connect, Choose what to draw, Save the results, Activity) in two columns. There's a **Draw my Active Directory** button, a progress bar, a status bar that shows the signed-in account, format tooltips, **Select all / Recommended / Clear**, and **Open output folder**.
- **Clearer sign-in**: "Use other credentials" is replaced by **Sign in as: My Windows account / A different account**, with user name and password fields in the window. The password is used for that run only. A **Test connection** button shows which DC answered and with which account. New command: `Test-AdtdConnection`.
- **About**: version, author (Shenuka Fernando) and project links, **install location** with **Open folder**, add or remove the **desktop shortcut**, **pin to taskbar**, and copyright and third-party notices.
- **After install, a welcome screen** shows where ADTD Modern is installed and offers a desktop shortcut, a taskbar pin and "Open ADTD Modern now". Windows 10 (1809+) and 11 only let people pin apps by hand, so if pinning isn't possible it shows the two clicks it takes.
- MSI:
  - installs `ADTD.exe` and the icon, and the Start menu shortcut opens `ADTD.exe`
  - Settings → Apps shows the icon, publisher, install location and project links
  - opens the welcome screen after an interactive install (silent installs skip it)
- `Install-ADTD.ps1`: installs `ADTD.exe`, and has new `-DesktopShortcut` and `-NoWelcome` switches. `-Uninstall` also removes the desktop shortcut.
- The cards in the window scroll on small screens, and the Activity log fills its card. The About notices open at the top.
- Reinstalling the same MSI version replaces it instead of adding a second entry in Settings → Apps.
- Releases: pushing a `v*` tag builds the MSI and the offline package and publishes them as a GitHub Release (`.github/workflows/release.yml`, `setup/build-offline-package.ps1`).
- Added a `COPYRIGHT` file and screenshots of the app. Tests: 135 checks.

## 3.0.1 (2026-09-27)

- **Works without internet access.** The HTML reports have a built-in diagram viewer (mxGraph 4.2.2, Apache-2.0, bundled in `src/lib`), so diagrams display offline. `-DrawIoWebViewer` switches back to draw.io's online viewer.
- `-Offline` switch, plus a matching checkbox in the window: no draw.io web links, and drawings open in draw.io desktop.
- `Install-Prerequisites.ps1`:
  - installs draw.io desktop from a local installer (`-DrawIoInstaller`, or a file in the package's `drawio` folder) after checking its signature
  - checks that the current account can read Active Directory
- Offline package with `START-HERE.txt` and [docs/OFFLINE.md](docs/OFFLINE.md).
- **Redesigned diagrams**:
  - title banners
  - coloured site and group headers
  - card-style boxes with icons and shadows
  - softer status colours
  - label chips on connectors
  - curved arrows for replication between sites
  - KPI tiles on the summary page
  - colour-coded roadmap phases
  - a page background
- **Icon set**: 29 flat icons (domain controller, RODC, site, subnet, forest, domain, Exchange, OU, GPO, DFS-R, partition, Entra ID, sync, Defender, LAPS key, certificate, device, app and more). They are embedded in the `.drawio` file, so they look the same in draw.io desktop, draw.io web, the offline report and PNG/SVG/PDF exports, without needing stencil libraries or internet access.
- Fixed: when a search returned exactly one object, it was read incorrectly. This affected the Exchange organization name and the counts of gMSAs, fine-grained password policies and Password Protection agents.
- Fixed: read-only DCs are no longer reported for protocol transition. RODC accounts have that flag by design.
- Fixed: the protocol-transition and RC4 findings no longer appear with empty evidence.

## 3.0.0 (2026-09-27)

First release of ADTD Modern, a rewrite of Microsoft's Active Directory Topology Diagrammer 1.8 (2011).

### Topology
- Supports Windows Server up to 2025: functional level 10 and schema 91. DC operating system names and end-of-support dates.
- Recognises Exchange 2013, 2016, 2019 and Exchange Server Subscription Edition, with DAGs and roles by site.
- Drawings:
  - Sites and site links (including multi-site links and bridges)
  - Replication connections (KCC, manual, disabled)
  - Domains, trusts and FSMO roles
  - Application partitions
  - OUs and GPO links (enforced, disabled, missing, blocked inheritance)
  - DFS-R
  - Exchange
- Reads over LDAP with System.DirectoryServices. No RSAT or ActiveDirectory module needed. Works with Windows PowerShell 5.1 and PowerShell 7.

### Assessment
- 58 checks: 18 health, 32 security and 8 hybrid readiness. Each has severity, risk, steps, Microsoft references and a roadmap phase ([docs/FINDINGS.md](docs/FINDINGS.md)).
- Security scan:
  - Privileged group membership and Protected Users
  - krbtgt age
  - Kerberoastable and AS-REP-roastable accounts
  - Unconstrained delegation and protocol transition
  - DES and RC4-only accounts
  - Stale users and computers
  - LAPS coverage
  - Unsupported Windows versions
  - MachineAccountQuota and password policy
  - Pre-Windows 2000 Compatible Access and Guest
  - AD CS ESC1-style templates
  - Seamless SSO key age
- Hybrid readiness:
  - Detects Entra Connect Sync (and its server), Cloud Sync, the device registration SCP (and tenant name), Seamless SSO, Entra Kerberos, AD FS, Entra Password Protection and UPN suffixes
  - Gap analysis of what on-premises AD is missing
  - Suggested target topology
  - Four-phase upgrade roadmap
  - Check-by-hand list for items LDAP can't see

### Outputs
- draw.io file, including **Target hybrid topology** and **Upgrade roadmap** pages.
- draw.io **desktop or web**: `-Open` and `-DrawIoViewer`, plus a `.url` shortcut that opens the drawing in app.diagrams.net. The drawing travels in the URL fragment and is not uploaded.
- HTML assessment report with a card per finding. **Optional tabbed layout** (`HtmlTabs`): Summary, Findings (filter and search), Diagrams (one sub-tab per page in the draw.io web viewer), Hybrid plan and Inventory.
- **Markdown**: one report per finding, plus an index and `hybrid-plan.md`.
- CSV: findings, evidence, gap analysis, roadmap, security by domain, computer OS, plus inventory tables.
- JSON inventory, which can be re-assessed offline with `-InputFile`.
- Optional Visio `.vsdx` through Visio desktop.

### Setup
- 64-bit MSI with major upgrades and silent install. Start menu shortcuts for the window, PowerShell, prerequisites and read-me.
- `Install-Prerequisites.ps1`:
  - Status report
  - draw.io desktop (winget, or the signed GitHub installer)
  - draw.io web setting
  - PowerShell 7
  - Optional Visio desktop through the Office Deployment Tool (Plan 2, Professional 2024, Standard 2024)
- `Install-ADTD.ps1` for per-user installs without admin rights.
- Offline test suite (119 checks), and CI on PowerShell 5.1 and 7 that builds the MSI.
