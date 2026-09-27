# ADTD Modern - Active Directory Topology Diagrammer for current Windows Server releases.
# A read-only replacement for Microsoft's ADTD 2011 (ADTD.Net_Setup.msi).

$script:AdtdVersion = '3.0.3'
$script:AllDrawings = @('Summary', 'Sites', 'Replication', 'Domains', 'Hybrid', 'AppPartitions', 'OUs', 'Dfsr', 'Exchange')

. (Join-Path $PSScriptRoot 'ADTD.Versions.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Icons.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Collect.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Security.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Assessment.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Render.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Report.ps1')
. (Join-Path $PSScriptRoot 'ADTD.Gui.ps1')

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

Export-ModuleMember -Function Invoke-ADTD, Show-ADTD, Get-AdtdInventory, Get-AdtdFindings, Get-AdtdTopologyPlan, Get-AdtdGapAnalysis, New-AdtdDiagram, Export-AdtdDrawIo, Export-AdtdVisio, Export-AdtdHtmlReport, Export-AdtdMarkdown, Export-AdtdCsv, Get-AdtdDrawIoWebUrl, Open-AdtdDrawing, Get-AdtdSettings, Set-AdtdSettings, Test-AdtdConnection
