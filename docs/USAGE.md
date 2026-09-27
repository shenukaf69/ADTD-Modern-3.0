# Using ADTD Modern

[Back to README](../README.md)

## The window

![ADTD Modern window](images/app-window.png)

Open **Start → ADTD Modern** (or the desktop shortcut). The window has a header with **Prerequisites** and **About**, then four numbered steps:

1. **Connect to Active Directory**
   - **Domain or domain controller**: leave it empty to use the domain your computer is in, or type a domain (`contoso.com`) or a DC (`dc01.contoso.com`).
   - **Sign in as**:
     - **My Windows account** (default): the account you are logged on with.
     - **A different account**: for another domain or forest, or a computer that isn't domain-joined. Type the **User name** (`CONTOSO\jane` or `jane@contoso.com`) and **Password** right in the window. The password is used for this run only and never saved.
   - **Test connection** checks that ADTD can reach a DC and read the domain with that account, and shows which DC answered.
2. **Choose what to draw**: tick the pages. **Security and hybrid assessment** turns the security scan on or off. **Select all**, **Recommended** and **Clear** set the ticks quickly.
3. **Save the results**: pick the formats (hover over one to see what it contains): draw.io drawing, HTML report, Tabbed HTML, Markdown, CSV, JSON and Visio (optional). Then:
   - **Save to**: the output folder (default `Documents\ADTD`).
   - **Open in**: Auto (draw.io desktop if installed, else web), draw.io desktop, or draw.io on the web. ADTD remembers your choice.
   - **Open the results when done**, and **No internet on this computer (offline mode)**.
4. **Activity**: progress while ADTD reads and draws.

Click **Draw my Active Directory**. A progress bar and the status bar show what ADTD is doing. **Open output folder** opens the results folder.

### About, desktop shortcut and taskbar

![About ADTD Modern](images/app-about.png)

**About** shows the version, the author (Shenuka Fernando) with links to the project, **where ADTD Modern is installed** (with **Open folder**), and buttons to **add or remove the desktop shortcut** and **pin to the taskbar**. It also lists the copyright and third-party notices.

The first time ADTD Modern opens after an install or upgrade, a welcome screen shows the install location and offers:
- **Add a shortcut to my desktop**
- **Pin to the taskbar**
- **Open ADTD Modern now**

Windows 10 (since 1809) and Windows 11 don't let apps pin themselves. If pinning doesn't work, ADTD shows how to do it: with ADTD Modern open, right-click its icon on the taskbar and choose **Pin to taskbar**. This works because ADTD Modern runs as its own app (`ADTD.exe`) with its own icon, not as PowerShell.

## PowerShell

```powershell
# Everything, all formats, open the results
Invoke-ADTD -All -Format DrawIo, Html, HtmlTabs, Markdown, Csv, Json -Open

# Default run: Summary, Sites, Replication, Domains and Hybrid pages; draw.io, HTML and JSON
Invoke-ADTD

# Another forest
Invoke-ADTD -Server dc01.fabrikam.com -Credential (Get-Credential FABRIKAM\auditor)

# Topology only (no security scan), big OU trees
Invoke-ADTD -Drawings Sites, Replication, Domains, OUs -MaxOUs 2000 -SkipSecurityScan

# Fully offline report (no draw.io web link or viewer)
Invoke-ADTD -Format Html, Markdown -NoDrawIoWeb

# Re-assess a saved inventory on any computer (even Linux or macOS with PowerShell 7)
Invoke-ADTD -InputFile .\ADTD-contoso.com-20260927-1015.json -All -Format DrawIo, HtmlTabs, Markdown

# Open in draw.io on the web instead of desktop
Invoke-ADTD -Open -DrawIoViewer Web
```

The command returns a summary object:

```text
Forest            : contoso.com
Domains           : 2
Sites             : 5
DomainControllers : 6
Findings          : 45
High              : 12
Files             : @{DrawIo=...; DrawIoWebLink=...; Html=...; HtmlTabs=...; Markdown=...; Csv=...; Json=...; Log=...}
```

## Scheduled runs

Run a monthly assessment and keep the history:

```powershell
$action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -Command "Invoke-ADTD -All -Format DrawIo, HtmlTabs, Csv, Json -OutputFolder \\fileserver\ADTD -NoDrawIoWeb"'
$trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Monday -At 6am
Register-ScheduledTask -TaskName 'ADTD Modern monthly' -Action $action -Trigger $trigger -User 'CONTOSO\svc-adtd' -Password (Read-Host 'Password')
```

Use a normal domain user, or a gMSA, for the task. It needs no admin rights.

## Using the findings

- **Work through the report.** In the tabbed report, use the High filter and the category menu. The search box also searches affected objects, so typing an account name shows every finding it appears in.
- **Hand work out.** `-Format Markdown` writes one file per finding, with evidence, steps and references. It is ready to attach to a ticket or commit to a wiki.
- **Track progress.** `findings.csv` has one row per finding, and `finding-evidence.csv` has one row per affected object. Diff two runs, or load them into Excel or Power BI.
- **Plan the upgrade.** The **Hybrid plan** tab, the **Upgrade roadmap** drawing page, `roadmap.csv` and `hybrid-plan.md` all hold the same four-phase plan.

## Other commands

| Command | What it does |
|---|---|
| `Show-ADTD` | Opens the window (`-Welcome` shows the welcome screen first) |
| `Test-AdtdConnection` | Checks that ADTD can read AD: `Test-AdtdConnection -Server contoso.com -Credential (Get-Credential)` |
| `Get-AdtdInventory` | Returns the raw inventory object (topology + security scan) |
| `Get-AdtdFindings -Inventory $inv` | Runs the checks on an inventory |
| `Get-AdtdTopologyPlan -Inventory $inv` | Target topology, gap analysis, roadmap, manual checklist |
| `Get-AdtdDrawIoWebUrl -Path x.drawio` | A link that opens a drawing in draw.io on the web |
| `Open-AdtdDrawing -Path x.drawio -Viewer Web` | Opens a drawing in draw.io desktop or web |
| `Set-AdtdSettings -DrawIoViewer Desktop` | Saves the default viewer |
