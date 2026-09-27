# ADTD Modern - Active Directory Topology Diagrammer for current Windows Server releases.
# A read-only replacement for Microsoft's ADTD 2011 (ADTD.Net_Setup.msi).

$script:AdtdVersion = '3.0.1'
$script:AllDrawings = @('Summary', 'Sites', 'Replication', 'Domains', 'Hybrid', 'AppPartitions', 'OUs', 'Dfsr', 'Exchange')

. (Join-Path $PSScriptRoot 'ADTD.Versions.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Icons.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Collect.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Security.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Assessment.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Render.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Report.ps1')

function Invoke-ADTD {
    <#
    .SYNOPSIS
    Reads the Active Directory topology, assesses health, security and hybrid (Microsoft Entra ID) readiness,
    and draws it in draw.io (desktop or web) with an HTML assessment report.

    .DESCRIPTION
    Read-only: ADTD only runs LDAP searches; it never writes to Active Directory. Any domain user can run it.
    Supports every Windows Server release up to Windows Server 2025 (functional level 10, schema 91),
    read-only domain controllers, DFS-R SYSVOL, and Exchange 2013 to Exchange Server Subscription Edition.

    .PARAMETER Drawings
    Pages to draw: Summary, Sites, Replication, Domains, Hybrid (target hybrid topology + roadmap), AppPartitions, OUs, Dfsr, Exchange.
    Default: Summary, Sites, Replication, Domains, Hybrid.

    .PARAMETER Format
    Outputs: DrawIo (.drawio for draw.io desktop or draw.io on the web), Html (assessment report with a card per finding),
    HtmlTabs (optional: one HTML file with tabs for summary, findings, every diagram page, hybrid plan and inventory),
    Markdown (one report file per finding plus the hybrid plan), Csv, Json (inventory you can re-assess later with -InputFile),
    Visio (.vsdx drawn through Visio desktop; optional, needs Visio installed).

    .PARAMETER DrawIoViewer
    Where -Open shows the drawing: Desktop (draw.io desktop app), Web (app.diagrams.net in your browser) or Auto
    (desktop if installed, otherwise web). The default comes from Install-Prerequisites.ps1 or Set-AdtdSettings.

    .PARAMETER Offline
    For computers without internet access: no draw.io web links. (The reports' diagram viewer is built in and
    works offline by default.)

    .PARAMETER DrawIoWebViewer
    Use draw.io's online viewer (viewer.diagrams.net) in the HTML reports instead of the built-in offline viewer.

    .PARAMETER SkipSecurityScan
    Skip the security and hybrid-readiness scan of users, computers, groups, AD CS and Entra ID objects.

    .EXAMPLE
    Invoke-ADTD
    Draws the current forest to Documents\ADTD.

    .EXAMPLE
    Invoke-ADTD -All -Format DrawIo, Visio, Html -Open
    Draws every page, also in Visio, and opens the results.

    .EXAMPLE
    Invoke-ADTD -Server dc01.contoso.com -Credential (Get-Credential)
    Draws a forest you are not logged on to.

    .EXAMPLE
    Invoke-ADTD -InputFile .\ADTD-contoso.com-20260927-1015.json -Format Visio
    Re-draws an earlier inventory without contacting Active Directory.
    #>
    [CmdletBinding()]
    param(
        [string]$Server,
        [pscredential]$Credential,
        [ValidateSet('Summary', 'Sites', 'Replication', 'Domains', 'Hybrid', 'AppPartitions', 'OUs', 'Dfsr', 'Exchange')]
        [string[]]$Drawings = @('Summary', 'Sites', 'Replication', 'Domains', 'Hybrid'),
        [switch]$All,
        [ValidateSet('DrawIo', 'Html', 'HtmlTabs', 'Markdown', 'Csv', 'Json', 'Visio')]
        [string[]]$Format = @('DrawIo', 'Html', 'Json'),
        [ValidateSet('Auto', 'Desktop', 'Web')]
        [string]$DrawIoViewer,
        [switch]$SkipSecurityScan,
        [switch]$NoDrawIoWeb,
        [switch]$Offline,
        [switch]$DrawIoWebViewer,
        [string]$OutputFolder = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ADTD'),
        [string]$InputFile,
        [int]$MaxOUs = 400,
        [switch]$Open
    )
    if ($All) { $Drawings = $script:AllDrawings }
    if ($Offline) { $NoDrawIoWeb = [switch]$true; $DrawIoWebViewer = [switch]$false }
    $script:AdtdLogLines.Clear()
    if (-not (Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null }

    if ($InputFile) {
        Write-AdtdLog "Loading inventory from $InputFile"
        $inv = Get-Content -Raw -Path $InputFile | ConvertFrom-Json
        foreach ($p in 'Security', 'Plan', 'Findings') { if (-not $inv.PSObject.Properties[$p]) { $inv | Add-Member -NotePropertyName $p -NotePropertyValue $null } }
        $inv.Findings = @(Get-AdtdFindings $inv)
        $inv.Plan = Get-AdtdTopologyPlan $inv
    } else {
        $inv = Get-AdtdInventory -Server $Server -Credential $Credential -MaxOUs $MaxOUs `
            -IncludeOUs:($Drawings -contains 'OUs') -IncludeDfsr:($Drawings -contains 'Dfsr') `
            -IncludeExchange:($Drawings -contains 'Exchange') -IncludeAppPartitions:($Drawings -contains 'AppPartitions') -SkipSecurityScan:$SkipSecurityScan
    }

    $base = Join-Path $OutputFolder ('ADTD-{0}-{1:yyyyMMdd-HHmm}' -f ($inv.Forest.Name -replace '[^A-Za-z0-9.-]', '_'), (Get-Date))
    $out = [ordered]@{}
    $pages = $null
    if ($Format -contains 'DrawIo' -or $Format -contains 'Visio') {
        Write-AdtdLog "Laying out drawings: $($Drawings -join ', ')"
        $pages = @(New-AdtdDiagram -Inventory $inv -Drawings $Drawings)
    }
    if ($Format -contains 'DrawIo') { $out.DrawIo = Export-AdtdDrawIo $pages "$base.drawio"; Write-AdtdLog "Saved $($out.DrawIo)" }
    if ($Format -contains 'Visio') {
        try { $out.Visio = Export-AdtdVisio $pages "$base.vsdx"; Write-AdtdLog "Saved $($out.Visio)" }
        catch { Write-AdtdLog "Visio drawing failed: $($_.Exception.Message)" -Level Warn }
    }
    if ($Format -contains 'DrawIo' -and -not $NoDrawIoWeb) {
        $out.DrawIoWebLink = "$base-open-in-drawio-web.url"
        "[InternetShortcut]`r`nURL=$(Get-AdtdDrawIoWebUrl $out.DrawIo)`r`n" | Set-Content -Path $out.DrawIoWebLink -Encoding ASCII
    }
    if ($Format -contains 'Html') { $out.Html = Export-AdtdHtmlReport $inv "$base.html" $out.DrawIo -NoDrawIoWeb:$NoDrawIoWeb -DrawIoWebViewer:$DrawIoWebViewer; Write-AdtdLog "Saved $($out.Html)" }
    if ($Format -contains 'HtmlTabs') { $out.HtmlTabs = Export-AdtdHtmlReport $inv "$base-tabs.html" $out.DrawIo -NoDrawIoWeb:$NoDrawIoWeb -DrawIoWebViewer:$DrawIoWebViewer -Tabs; Write-AdtdLog "Saved $($out.HtmlTabs)" }
    if ($Format -contains 'Markdown') { $out.Markdown = Export-AdtdMarkdown $inv "$base-findings"; Write-AdtdLog "Saved one Markdown report per finding to $($out.Markdown)" }
    if ($Format -contains 'Json') {
        $inv | ConvertTo-Json -Depth 10 | Set-Content -Path "$base.json" -Encoding UTF8
        $out.Json = "$base.json"; Write-AdtdLog "Saved $($out.Json)"
    }
    if ($Format -contains 'Csv') {
        $csvDir = "$base-csv"; New-Item -ItemType Directory -Path $csvDir -Force | Out-Null
        $out.Csv = @(Export-AdtdCsv $inv $csvDir); Write-AdtdLog "Saved $(@($out.Csv).Count) CSV file(s) to $csvDir"
    }
    $logFile = "$base.log"
    $script:AdtdLogLines | Set-Content -Path $logFile -Encoding UTF8
    $out.Log = $logFile

    if ($Open) {
        foreach ($k in 'HtmlTabs', 'Html', 'Visio') { if ($out[$k] -and (Test-Path $out[$k])) { try { Invoke-Item $out[$k] } catch { } } }
        if ($out.DrawIo) { try { $how = Open-AdtdDrawing -Path $out.DrawIo -Viewer $(if ($Offline) { 'Desktop' } else { $DrawIoViewer }); Write-AdtdLog "Opened the drawing in draw.io ($how)." } catch { Write-AdtdLog "Could not open draw.io: $($_.Exception.Message)" -Level Warn } }
    }
    [pscustomobject]@{
        Forest            = $inv.Forest.Name
        Domains           = @($inv.Domains).Count
        Sites             = @($inv.Sites).Count
        DomainControllers = @($inv.DomainControllers).Count
        Findings          = @($inv.Findings).Count
        High              = @($inv.Findings | Where-Object Severity -eq 'High').Count
        Files             = [pscustomobject]$out
    }
}

function Show-ADTD {
    <# Windows Forms front end, similar to the original ADTD window. #>
    [CmdletBinding()]
    param()
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "ADTD Modern $script:AdtdVersion - Active Directory Topology Diagrammer"
    $form.Size = New-Object System.Drawing.Size(700, 680)
    $form.StartPosition = 'CenterScreen'
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $form.MinimumSize = New-Object System.Drawing.Size(620, 560)

    $y = 14
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = 'Domain controller or domain (leave empty for the domain you are logged on to):'
    $lbl.Location = New-Object System.Drawing.Point(14, $y); $lbl.AutoSize = $true
    $form.Controls.Add($lbl); $y += 22
    $server = New-Object System.Windows.Forms.TextBox
    $server.Location = New-Object System.Drawing.Point(14, $y); $server.Width = 440; $server.Anchor = 'Top,Left,Right'
    $form.Controls.Add($server)
    $useCred = New-Object System.Windows.Forms.CheckBox
    $useCred.Text = 'Use other credentials'; $useCred.Location = New-Object System.Drawing.Point(470, ($y + 1)); $useCred.AutoSize = $true; $useCred.Anchor = 'Top,Right'
    $form.Controls.Add($useCred); $y += 36

    $grp = New-Object System.Windows.Forms.GroupBox
    $grp.Text = 'Draw'; $grp.Location = New-Object System.Drawing.Point(14, $y); $grp.Size = New-Object System.Drawing.Size(656, 124); $grp.Anchor = 'Top,Left,Right'
    $form.Controls.Add($grp)
    $boxes = [ordered]@{}
    $labels = [ordered]@{ Summary = 'Summary and findings'; Sites = 'Sites, subnets and site links'; Replication = 'Replication connections'; Domains = 'Domains, trusts and FSMO roles'; Hybrid = 'Hybrid Entra ID topology + roadmap'
        AppPartitions = 'Application partitions'; OUs = 'OUs and GPO links'; Dfsr = 'DFS Replication groups'; Exchange = 'Exchange organization'; Security = 'Security and hybrid assessment' }
    $i = 0
    foreach ($k in $labels.Keys) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $labels[$k]; $cb.AutoSize = $true
        $cb.Location = New-Object System.Drawing.Point((12 + [math]::Floor($i / 5) * 320), (22 + ($i % 5) * 19))
        $cb.Checked = $k -in 'Summary', 'Sites', 'Replication', 'Domains', 'Hybrid', 'Security'
        $grp.Controls.Add($cb); $boxes[$k] = $cb; $i++
    }
    $y += 134

    $grp2 = New-Object System.Windows.Forms.GroupBox
    $grp2.Text = 'Save as'; $grp2.Location = New-Object System.Drawing.Point(14, $y); $grp2.Size = New-Object System.Drawing.Size(656, 50); $grp2.Anchor = 'Top,Left,Right'
    $form.Controls.Add($grp2)
    $fmt = [ordered]@{}
    $i = 0
    foreach ($k in @(@('DrawIo', 'draw.io', $true), @('Html', 'HTML report', $true), @('HtmlTabs', 'Tabbed HTML', $false), @('Markdown', 'Markdown', $false), @('Csv', 'CSV', $false), @('Json', 'JSON', $true), @('Visio', 'Visio', $false))) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $k[1]; $cb.AutoSize = $true; $cb.Checked = $k[2]
        $cb.Location = New-Object System.Drawing.Point((12 + $i * 92), 20)
        $grp2.Controls.Add($cb); $fmt[$k[0]] = $cb; $i++
    }
    $y += 60
    $lblV = New-Object System.Windows.Forms.Label
    $lblV.Text = 'Open drawings in:'; $lblV.Location = New-Object System.Drawing.Point(14, ($y + 3)); $lblV.AutoSize = $true
    $form.Controls.Add($lblV)
    $viewer = New-Object System.Windows.Forms.ComboBox
    $viewer.DropDownStyle = 'DropDownList'; [void]$viewer.Items.AddRange(@('Auto (desktop if installed, else web)', 'draw.io desktop', 'draw.io on the web'))
    $viewer.SelectedIndex = @{ Auto = 0; Desktop = 1; Web = 2 }[[string](Get-AdtdSettings).DrawIoViewer]
    if ($viewer.SelectedIndex -lt 0) { $viewer.SelectedIndex = 0 }
    $viewer.Location = New-Object System.Drawing.Point(130, $y); $viewer.Width = 300
    $form.Controls.Add($viewer)
    $pre = New-Object System.Windows.Forms.Button
    $pre.Text = 'Prerequisites...'; $pre.Location = New-Object System.Drawing.Point(446, ($y - 1)); $pre.Width = 130
    $pre.Add_Click({
            $script = @((Join-Path $PSScriptRoot 'Install-Prerequisites.ps1'), (Join-Path $PSScriptRoot '..\setup\Install-Prerequisites.ps1')) | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($script) { Start-Process powershell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$script`"" }
            else { [System.Windows.Forms.MessageBox]::Show('Install-Prerequisites.ps1 was not found next to ADTD.', 'ADTD Modern') | Out-Null }
        })
    $form.Controls.Add($pre)
    $y += 34

    $lbl2 = New-Object System.Windows.Forms.Label
    $lbl2.Text = 'Output folder:'; $lbl2.Location = New-Object System.Drawing.Point(14, ($y + 3)); $lbl2.AutoSize = $true
    $form.Controls.Add($lbl2)
    $folder = New-Object System.Windows.Forms.TextBox
    $folder.Text = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ADTD'
    $folder.Location = New-Object System.Drawing.Point(110, $y); $folder.Width = 460; $folder.Anchor = 'Top,Left,Right'
    $form.Controls.Add($folder)
    $browse = New-Object System.Windows.Forms.Button
    $browse.Text = 'Browse...'; $browse.Location = New-Object System.Drawing.Point(580, ($y - 1)); $browse.Width = 90; $browse.Anchor = 'Top,Right'
    $browse.Add_Click({
            $d = New-Object System.Windows.Forms.FolderBrowserDialog
            $d.SelectedPath = $folder.Text
            if ($d.ShowDialog() -eq 'OK') { $folder.Text = $d.SelectedPath }
        })
    $form.Controls.Add($browse); $y += 36

    $log = New-Object System.Windows.Forms.TextBox
    $log.Multiline = $true; $log.ScrollBars = 'Vertical'; $log.ReadOnly = $true
    $log.Font = New-Object System.Drawing.Font('Consolas', 9)
    $log.Location = New-Object System.Drawing.Point(14, $y); $log.Size = New-Object System.Drawing.Size(656, (580 - $y)); $log.Anchor = 'Top,Bottom,Left,Right'
    $form.Controls.Add($log)

    $offCb = New-Object System.Windows.Forms.CheckBox
    $offCb.Text = 'No internet on this computer (offline mode)'; $offCb.AutoSize = $true
    $offCb.Location = New-Object System.Drawing.Point(230, 598); $offCb.Anchor = 'Bottom,Left'
    $form.Controls.Add($offCb)
    $openCb = New-Object System.Windows.Forms.CheckBox
    $openCb.Text = 'Open the results when done'; $openCb.Checked = $true; $openCb.AutoSize = $true
    $openCb.Location = New-Object System.Drawing.Point(14, 598); $openCb.Anchor = 'Bottom,Left'
    $form.Controls.Add($openCb)
    $run = New-Object System.Windows.Forms.Button
    $run.Text = 'Draw'; $run.Width = 110; $run.Height = 30; $run.Location = New-Object System.Drawing.Point(560, 592); $run.Anchor = 'Bottom,Right'
    $form.Controls.Add($run); $form.AcceptButton = $run

    $script:AdtdLogSink = { param($line) $log.AppendText($line + [Environment]::NewLine); [System.Windows.Forms.Application]::DoEvents() }
    $run.Add_Click({
            $run.Enabled = $false; $log.Clear()
            $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
            try {
                $sel = @($boxes.Keys | Where-Object { $_ -ne 'Security' -and $boxes[$_].Checked })
                $fmts = @($fmt.Keys | Where-Object { $fmt[$_].Checked })
                if (-not $sel.Count -or -not $fmts.Count) { throw 'Pick at least one drawing and one output format.' }
                $p = @{ Drawings = $sel; Format = $fmts; OutputFolder = $folder.Text; Open = $openCb.Checked
                    SkipSecurityScan = -not $boxes.Security.Checked; DrawIoViewer = @('Auto', 'Desktop', 'Web')[$viewer.SelectedIndex]; Offline = $offCb.Checked }
                [void](Set-AdtdSettings -DrawIoViewer $p.DrawIoViewer)
                if ($server.Text.Trim()) { $p.Server = $server.Text.Trim() }
                if ($useCred.Checked) {
                    $c = Get-Credential -Message 'Account that can read Active Directory'
                    if (-not $c) { throw 'No credentials entered.' }
                    $p.Credential = $c
                }
                $r = Invoke-ADTD @p
                & $script:AdtdLogSink "Done: $($r.DomainControllers) domain controllers in $($r.Sites) sites, $($r.Findings) findings ($($r.High) high)."
            } catch {
                & $script:AdtdLogSink "ERROR: $($_.Exception.Message)"
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'ADTD Modern', 'OK', 'Error') | Out-Null
            } finally {
                $form.Cursor = [System.Windows.Forms.Cursors]::Default
                $run.Enabled = $true
            }
        })
    [void]$form.ShowDialog()
    $script:AdtdLogSink = $null
}

Export-ModuleMember -Function Invoke-ADTD, Show-ADTD, Get-AdtdInventory, Get-AdtdFindings, Get-AdtdTopologyPlan, Get-AdtdGapAnalysis, New-AdtdDiagram, Export-AdtdDrawIo, Export-AdtdVisio, Export-AdtdHtmlReport, Export-AdtdMarkdown, Export-AdtdCsv, Get-AdtdDrawIoWebUrl, Open-AdtdDrawing, Get-AdtdSettings, Set-AdtdSettings
