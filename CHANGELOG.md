# Changelog

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
