# Using ADTD Modern

[Back to README](../README.md)

## The window

**Start → ADTD Modern**:

1. **Domain controller or domain**: leave it empty for the forest you are logged on to. Tick **Use other credentials** for another account.
2. **Draw**: pick the pages. **Security and hybrid assessment** turns the security scan on or off.
3. **Save as**: pick the output formats:
   - draw.io
   - HTML report
   - Tabbed HTML
   - Markdown
   - CSV
   - JSON
   - Visio (optional)
4. **Open drawings in**: choose one of:
   - Auto (desktop if installed, otherwise web)
   - draw.io desktop
   - draw.io on the web

   ADTD remembers your choice.
5. **Prerequisites...**: opens the prerequisites installer.
6. Click **Draw**. Progress appears in the log box. With **Open the results when done** ticked, the reports and the drawing open automatically.

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
| `Show-ADTD` | Opens the window |
| `Get-AdtdInventory` | Returns the raw inventory object (topology + security scan) |
| `Get-AdtdFindings -Inventory $inv` | Runs the checks on an inventory |
| `Get-AdtdTopologyPlan -Inventory $inv` | Target topology, gap analysis, roadmap, manual checklist |
| `Get-AdtdDrawIoWebUrl -Path x.drawio` | A link that opens a drawing in draw.io on the web |
| `Open-AdtdDrawing -Path x.drawio -Viewer Web` | Opens a drawing in draw.io desktop or web |
| `Set-AdtdSettings -DrawIoViewer Desktop` | Saves the default viewer |
