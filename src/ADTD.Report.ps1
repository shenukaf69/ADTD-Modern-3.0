# ADTD Modern - reports: HTML assessment report, per-finding Markdown, CSV, and draw.io web links.

function Get-AdtdDrawIoWebUrl {
    <#
    Link that opens a .drawio file in draw.io on the web (app.diagrams.net) without uploading it anywhere:
    the diagram travels in the URL fragment (#R...), which browsers never send to the server.
    Format: #R + base64(raw-deflate(encodeURIComponent(xml))), as draw.io's Graph.compress.
    #>
    param([Parameter(Mandatory)][string]$Path)
    $xml = [System.IO.File]::ReadAllText($Path)
    $encoded = [uri]::EscapeDataString($xml)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($encoded)
    $ms = New-Object System.IO.MemoryStream
    $ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionLevel]::Optimal)
    $ds.Write($bytes, 0, $bytes.Length); $ds.Close()
    $b64 = [Convert]::ToBase64String($ms.ToArray())
    $title = [uri]::EscapeDataString((Split-Path $Path -Leaf))
    return "https://app.diagrams.net/?title=$title#R$([uri]::EscapeDataString($b64))"
}

function Get-AdtdSettings {
    $file = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'ADTD\settings.json'
    $s = [ordered]@{ DrawIoViewer = 'Auto' }
    try { if (Test-Path $file) { $j = Get-Content -Raw $file | ConvertFrom-Json; foreach ($p in $j.PSObject.Properties) { $s[$p.Name] = $p.Value } } } catch { }
    return [pscustomobject]$s
}

function Set-AdtdSettings {
    param([ValidateSet('Auto', 'Desktop', 'Web')][string]$DrawIoViewer)
    $dir = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'ADTD'
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $s = Get-AdtdSettings
    if ($DrawIoViewer) { $s.DrawIoViewer = $DrawIoViewer }
    $s | ConvertTo-Json | Set-Content -Path (Join-Path $dir 'settings.json') -Encoding UTF8
    return $s
}

function Find-AdtdDrawIoDesktop {
    $candidates = @(
        (Join-Path "$env:ProgramFiles" 'draw.io\draw.io.exe'),
        (Join-Path "$env:LOCALAPPDATA" 'Programs\draw.io\draw.io.exe'),
        (Join-Path "${env:ProgramFiles(x86)}" 'draw.io\draw.io.exe')
    )
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
    return $null
}

function Open-AdtdDrawing {
    <# Opens a .drawio file in draw.io desktop, or in draw.io on the web, per -Viewer or the saved setting. #>
    param([Parameter(Mandatory)][string]$Path, [ValidateSet('Auto', 'Desktop', 'Web')][string]$Viewer)
    if (-not $Viewer) { $Viewer = (Get-AdtdSettings).DrawIoViewer }
    $exe = Find-AdtdDrawIoDesktop
    if ($Viewer -eq 'Desktop' -or ($Viewer -eq 'Auto' -and $exe)) {
        if ($exe) { Start-Process -FilePath $exe -ArgumentList "`"$Path`""; return 'Desktop' }
        Write-AdtdLog 'draw.io desktop is not installed; opening draw.io on the web instead. Run Install-Prerequisites.ps1 -DrawIoDesktop to install it.' -Level Warn
    }
    Start-Process (Get-AdtdDrawIoWebUrl $Path)
    return 'Web'
}

# ---------------------------------------------------------------- CSV

function Export-AdtdCsv {
    param($Inventory, [string]$Folder)
    $files = @()
    $sets = [ordered]@{
        'findings'           = $Inventory.Findings | Select-Object Id, Severity, Category, Area, Title, Finding, Risk, @{ N = 'Steps'; E = { $_.Steps -join ' | ' } }, @{ N = 'References'; E = { ($_.References | ForEach-Object Url) -join ' ' } }, EvidenceCount, Phase
        'finding-evidence'   = @(foreach ($f in $Inventory.Findings) { foreach ($e in @($f.Evidence)) { [pscustomobject]@{ Id = $f.Id; Title = $f.Title; Object = $e } } })
        'gap-analysis'       = if ($Inventory.Plan) { $Inventory.Plan.Gaps } else { @() }
        'roadmap'            = if ($Inventory.Plan) { @(foreach ($p in $Inventory.Plan.Phases) { foreach ($t in $p.Tasks) { [pscustomobject]@{ Phase = $p.Number; PhaseName = $p.Name; Task = $t } } }) } else { @() }
        'domain-controllers' = $Inventory.DomainControllers | Select-Object Name, HostName, Domain, Site, OperatingSystem, OSBuild, OSSupportState, OSEndOfSupport, IsGlobalCatalog, IsReadOnly, @{ N = 'FsmoRoles'; E = { $_.FsmoRoles -join ';' } }
        'domains'            = $Inventory.Domains | Select-Object Name, NetBIOS, ParentDomain, IsForestRoot, FunctionalLevelName, PdcEmulator, RidMaster, InfrastructureMaster, SysvolReplication, Reachable
        'sites'              = $Inventory.Sites | Select-Object Name, Location, Description, ISTG, UniversalGroupCaching
        'subnets'            = $Inventory.Subnets
        'site-links'         = $Inventory.SiteLinks | Select-Object Name, Transport, @{ N = 'Sites'; E = { $_.Sites -join ';' } }, Cost, ReplIntervalMin, ChangeNotification
        'connections'        = $Inventory.Connections
        'trusts'             = $Inventory.Trusts | Select-Object Source, Target, Kind, Direction, @{ N = 'Flags'; E = { $_.Flags -join ';' } }, Created
    }
    if ($Inventory.Security) {
        $sets['security-by-domain'] = @(foreach ($d in $Inventory.Security.Domains) {
                [pscustomobject]@{
                    Domain = $d.Domain; EnabledUsers = $d.Users.Enabled; EnabledComputers = $d.Computers.Enabled
                    DomainAdmins = @($d.Groups | Where-Object Key -eq 'DomainAdmins')[0].EnabledMembers
                    KrbtgtPasswordAgeDays = $d.KrbtgtPasswordAgeDays; MachineAccountQuota = $d.MachineAccountQuota
                    MinPasswordLength = $d.PasswordPolicy.MinLength; LockoutThreshold = $d.PasswordPolicy.LockoutThreshold
                    StaleUsers = @($d.Users.Stale).Count; StaleComputers = @($d.Computers.Stale).Count
                    LapsCovered = $d.Computers.WindowsLapsCovered + $d.Computers.LegacyLapsCovered; LapsEligible = $d.Computers.LapsEligible
                }
            })
        $sets['computer-os'] = @(foreach ($d in $Inventory.Security.Domains) { foreach ($o in $d.Computers.OsCounts) { [pscustomobject]@{ Domain = $d.Domain; OperatingSystem = $o.Name; Count = $o.Count } } })
    }
    if ($Inventory.Exchange) { $sets['exchange-servers'] = $Inventory.Exchange.Servers | Select-Object Name, HostName, Site, Product, Version, Supported, @{ N = 'Roles'; E = { $_.Roles -join ';' } }, Dag }
    if (@($Inventory.OUs).Count) { $sets['ous'] = $Inventory.OUs | Select-Object Domain, Name, DN, Depth, BlockInheritance, @{ N = 'GpoLinks'; E = { ($_.GpoLinks | ForEach-Object { $_.Name + $(if ($_.Enforced) { ' (enforced)' }) }) -join ';' } } }
    foreach ($k in $sets.Keys) {
        $rows = @($sets[$k])
        if (-not $rows.Count) { continue }
        $file = Join-Path $Folder "$k.csv"
        $rows | Export-Csv -Path $file -NoTypeInformation -Encoding UTF8
        $files += $file
    }
    return $files
}

# ---------------------------------------------------------------- Markdown (one file per finding)

function Get-AdtdSlug {
    param([string]$Text)
    $s = ($Text.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    if ($s.Length -gt 60) { $s = $s.Substring(0, 60); if ($s.LastIndexOf('-') -gt 30) { $s = $s.Substring(0, $s.LastIndexOf('-')) } }
    return $s
}

function Export-AdtdMarkdown {
    <# Writes a folder with README.md (index), one Markdown report per finding, and the hybrid plan. #>
    param($Inventory, [string]$Folder)
    New-Item -ItemType Directory -Path $Folder -Force | Out-Null
    $f = $Inventory.Forest
    $idx = New-Object System.Text.StringBuilder
    [void]$idx.AppendLine("# Active Directory assessment: $($f.Name)")
    [void]$idx.AppendLine('')
    [void]$idx.AppendLine("Collected $($Inventory.CollectedAt) from $($Inventory.CollectedFrom) with $($Inventory.Tool) $($Inventory.ToolVersion). Read-only: nothing in Active Directory was changed.")
    [void]$idx.AppendLine('')
    foreach ($sev in 'High', 'Medium', 'Low') { [void]$idx.AppendLine("- **$sev**: $(@($Inventory.Findings | Where-Object Severity -eq $sev).Count)") }
    [void]$idx.AppendLine('')
    [void]$idx.AppendLine('| ID | Severity | Category | Finding | Affected |')
    [void]$idx.AppendLine('|---|---|---|---|---|')
    foreach ($x in $Inventory.Findings) {
        $file = "$($x.Id)-$(Get-AdtdSlug $x.Title).md"
        [void]$idx.AppendLine("| [$($x.Id)]($file) | $($x.Severity) | $($x.Category) | $($x.Title -replace '\|', '/') | $($x.EvidenceCount) |")
        $md = New-Object System.Text.StringBuilder
        [void]$md.AppendLine("# $($x.Id): $($x.Title)")
        [void]$md.AppendLine('')
        [void]$md.AppendLine("**Severity:** $($x.Severity) · **Category:** $($x.Category) · **Area:** $($x.Area) · **Roadmap phase:** $($x.Phase) · **Forest:** $($f.Name)")
        [void]$md.AppendLine('')
        [void]$md.AppendLine('## What ADTD found'); [void]$md.AppendLine(''); [void]$md.AppendLine($x.Finding); [void]$md.AppendLine('')
        [void]$md.AppendLine('## Why it matters'); [void]$md.AppendLine(''); [void]$md.AppendLine($x.Risk); [void]$md.AppendLine('')
        [void]$md.AppendLine('## How to fix'); [void]$md.AppendLine('')
        $i = 1; foreach ($s in $x.Steps) { [void]$md.AppendLine("$i. $s"); $i++ }
        [void]$md.AppendLine('')
        if (@($x.Evidence).Count) {
            [void]$md.AppendLine("## Affected objects ($($x.EvidenceCount))"); [void]$md.AppendLine('')
            foreach ($e in $x.Evidence) { [void]$md.AppendLine("- $e") }
            if ($x.EvidenceCount -gt @($x.Evidence).Count) { [void]$md.AppendLine("- ... see finding-evidence.csv") }
            [void]$md.AppendLine('')
        }
        if (@($x.References).Count) {
            [void]$md.AppendLine('## References'); [void]$md.AppendLine('')
            foreach ($r in $x.References) { [void]$md.AppendLine("- [$($r.Title)]($($r.Url))") }
        }
        [System.IO.File]::WriteAllText((Join-Path $Folder $file), $md.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    }
    if ($Inventory.Plan) {
        [void]$idx.AppendLine(''); [void]$idx.AppendLine('See [hybrid-plan.md](hybrid-plan.md) for the target topology, gap analysis and roadmap.')
        $pl = $Inventory.Plan
        $m = New-Object System.Text.StringBuilder
        [void]$m.AppendLine("# Target topology and roadmap: $($f.Name)"); [void]$m.AppendLine('')
        [void]$m.AppendLine('## Suggested target topology'); [void]$m.AppendLine('')
        foreach ($t in $pl.Target) { [void]$m.AppendLine("- **$($t.Area):** $($t.Recommendation)") }
        [void]$m.AppendLine(''); [void]$m.AppendLine('## What on-premises AD has, and what is missing'); [void]$m.AppendLine('')
        [void]$m.AppendLine('| Capability | Status | Evidence | Recommendation | Priority |'); [void]$m.AppendLine('|---|---|---|---|---|')
        foreach ($g in $pl.Gaps) { [void]$m.AppendLine("| $($g.Capability) | $($g.Status) | $($g.Evidence -replace '\|', '/') | $($g.Recommendation) | $($g.Priority) |") }
        [void]$m.AppendLine(''); [void]$m.AppendLine('## Roadmap'); [void]$m.AppendLine('')
        foreach ($p in $pl.Phases) {
            [void]$m.AppendLine("### Phase $($p.Number): $($p.Name)"); [void]$m.AppendLine(''); [void]$m.AppendLine("_$($p.Goal)_"); [void]$m.AppendLine('')
            foreach ($t in $p.Tasks) { [void]$m.AppendLine("- [ ] $t") }
            [void]$m.AppendLine('')
        }
        [void]$m.AppendLine('## Check by hand (not visible over LDAP)'); [void]$m.AppendLine('')
        foreach ($v in $pl.VerifyManually) { [void]$m.AppendLine("- [ ] $($v.Item) - $($v.Why) ([reference]($($v.Ref.Url)))") }
        [System.IO.File]::WriteAllText((Join-Path $Folder 'hybrid-plan.md'), $m.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    }
    [System.IO.File]::WriteAllText((Join-Path $Folder 'README.md'), $idx.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    return $Folder
}

# ---------------------------------------------------------------- HTML

function ConvertTo-AdtdHtmlTable {
    param($Rows, [string[]]$Columns)
    $rows = @($Rows)
    if (-not $rows.Count) { return '<p class="muted">None.</p>' }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('<div class="scroll"><table><thead><tr>')
    foreach ($c in $Columns) { [void]$sb.Append("<th>$(HE $c)</th>") }
    [void]$sb.Append('</tr></thead><tbody>')
    foreach ($r in $rows) {
        $cls = ''
        if ($r.PSObject.Properties['OSSupportState'] -and $r.OSSupportState -eq 'Unsupported') { $cls = ' class="bad"' }
        [void]$sb.Append("<tr$cls>")
        foreach ($c in $Columns) {
            $v = $r.$c
            if ($v -is [array]) { $v = $v -join ', ' }
            if ($v -is [bool]) { $v = if ($v) { 'Yes' } else { '' } }
            if ($c -eq 'Status') { [void]$sb.Append("<td><span class='pill st-$(("$v" -replace '[^A-Za-z]', '').ToLower())'>$(HE $v)</span></td>") }
            else { [void]$sb.Append("<td>$(HE $v)</td>") }
        }
        [void]$sb.Append('</tr>')
    }
    [void]$sb.Append('</tbody></table></div>')
    return $sb.ToString()
}

function ConvertTo-AdtdFindingCard {
    param($F)
    $ev = @($F.Evidence)
    $open = if ($ev.Count -le 15) { ' open' } else { '' }
    $evHtml = if ($ev.Count) {
        $more = if ($F.EvidenceCount -gt $ev.Count) { "<li class='muted'>... $($F.EvidenceCount - $ev.Count) more in finding-evidence.csv</li>" } else { '' }
        "<details$open><summary>Affected objects ($($F.EvidenceCount))</summary><ul class='ev'>$(($ev | ForEach-Object { "<li>$(HE $_)</li>" }) -join '')$more</ul></details>"
    } else { '' }
    $steps = ($F.Steps | ForEach-Object { "<li>$(HE $_)</li>" }) -join ''
    $refs = if (@($F.References).Count) { "<p class='refs'>References: $((@($F.References) | ForEach-Object { "<a href='$(HE $_.Url)' target='_blank' rel='noopener'>$(HE $_.Title)</a>" }) -join ' &#183; ')</p>" } else { '' }
    @"
<article class="finding sev-$($F.Severity.ToLower())" data-cat="$($F.Category)" id="$($F.Id)">
<header><span class="badge b-$($F.Severity.ToLower())">$($F.Severity)</span><span class="fid">$($F.Id)</span><h3>$(HE $F.Title)</h3><span class="muted meta">$(HE $F.Category) &#183; $(HE $F.Area) &#183; roadmap phase $($F.Phase)</span></header>
<p><b>What ADTD found.</b> $(HE $F.Finding)</p>
<p><b>Why it matters.</b> $(HE $F.Risk)</p>
$evHtml
<p><b>How to fix</b></p><ol>$steps</ol>
$refs
</article>
"@
}

function Export-AdtdHtmlReport {
    <#
    Writes the assessment report. Default: one long page (easy to print). -Tabs: a single HTML file with tabs for
    Summary, Findings (filter and search), Diagrams (one tab per draw.io page, shown with the draw.io web viewer),
    Hybrid plan and Inventory.
    #>
    param($Inventory, [string]$Path, [string]$DrawingFile, [switch]$NoDrawIoWeb, [switch]$Tabs)
    $inv = $Inventory; $f = $inv.Forest
    $findings = @($inv.Findings)
    $cnt = @{}; foreach ($s in 'High', 'Medium', 'Low') { $cnt[$s] = @($findings | Where-Object Severity -eq $s).Count }
    $byCat = foreach ($c in 'Security', 'Health', 'Hybrid') { $x = @($findings | Where-Object Category -eq $c); "<tr><td>$c</td><td>$(@($x | Where-Object Severity -eq 'High').Count)</td><td>$(@($x | Where-Object Severity -eq 'Medium').Count)</td><td>$(@($x | Where-Object Severity -eq 'Low').Count)</td></tr>" }
    $top = @($findings | Where-Object Severity -eq 'High' | Select-Object -First 8)
    $topHtml = if ($top.Count) { '<ol>' + (($top | ForEach-Object { "<li><a href='#$($_.Id)'>$(HE $_.Title)</a> <span class='muted'>($($_.EvidenceCount) affected)</span></li>" }) -join '') + '</ol>' } else { '<p>No high-severity findings.</p>' }
    $plan = $inv.Plan
    $h = if ($inv.Security) { Get-AdtdHybridState $inv } else { $null }

    $sections = New-Object System.Collections.ArrayList
    $sec = { param($id, $title, $body) [void]$sections.Add([pscustomobject]@{ Id = $id; Title = $title; Body = $body }) }

    $summary = "<p>ADTD read the forest <b>$(HE $f.Name)</b> ($(@($inv.Domains).Count) domain(s), $(@($inv.Sites).Count) site(s), $(@($inv.DomainControllers).Count) domain controller(s)) and found <b>$($findings.Count)</b> issue(s): <b>$($cnt.High)</b> high, <b>$($cnt.Medium)</b> medium and <b>$($cnt.Low)</b> low.</p>"
    if (-not $inv.Security) { $summary += "<p class='muted'>The security scan was skipped (-SkipSecurityScan), so only health checks ran.</p>" }
    $summary += "<div class='grid2'><div><h3>Fix first</h3>$topHtml</div><div><h3>Findings by category</h3><table><thead><tr><th>Category</th><th>High</th><th>Medium</th><th>Low</th></tr></thead><tbody>$($byCat -join '')</tbody></table>"
    if ($h) { $summary += "<h3>Hybrid identity today</h3><ul><li>Directory sync: <b>$(if ($h.CloudSync) { 'Cloud Sync' } elseif ($h.ConnectSync) { 'Connect Sync' } else { 'none found' })</b></li><li>Tenant: <b>$(if ($h.TenantName) { HE $h.TenantName } else { 'unknown (no device registration SCP)' })</b></li><li>AD FS: <b>$(if ($h.Adfs) { 'found' } else { 'not found' })</b></li><li>Users on non-routable UPN suffixes: <b>$($h.NonRoutableUsers)</b></li></ul>" }
    $summary += '</div></div>'
    & $sec 'summary' 'Executive summary' $summary

    foreach ($c in 'Security', 'Health', 'Hybrid') {
        $x = @($findings | Where-Object Category -eq $c)
        $title = @{ Security = 'Security findings'; Health = 'Health and topology findings'; Hybrid = 'Hybrid identity readiness findings' }[$c]
        $body = if ($x.Count) { ($x | ForEach-Object { ConvertTo-AdtdFindingCard $_ }) -join "`n" } else { '<p>No issues found.</p>' }
        & $sec $c.ToLower() "$title ($($x.Count))" $body
    }

    if ($plan) {
        $gap = "<p>What your on-premises Active Directory has today, and what a current Microsoft hybrid identity design adds. <i>Not detectable</i> items live in Microsoft Entra ID or on servers and can't be seen over LDAP.</p>" + (ConvertTo-AdtdHtmlTable $plan.Gaps @('Capability', 'Status', 'Evidence', 'Recommendation', 'Priority'))
        & $sec 'gaps' 'Hybrid readiness: what on-premises AD is missing' $gap
        $tgt = '<table><thead><tr><th>Area</th><th>Recommendation</th></tr></thead><tbody>' + (($plan.Target | ForEach-Object { "<tr><td><b>$(HE $_.Area)</b></td><td>$(HE $_.Recommendation)</td></tr>" }) -join '') + '</tbody></table>'
        $ph = '<div class="phases">' + (($plan.Phases | ForEach-Object { "<div class='phase p$($_.Number)'><h3>Phase $($_.Number): $(HE $_.Name)</h3><p class='muted'>$(HE $_.Goal)</p><ul>$(($_.Tasks | ForEach-Object { $t = HE $_; if ($_ -match '^\[([A-Z]\d+)\]') { $t = $t -replace '^\[([A-Z]\d+)\]', "<a href='#`$1'>[`$1]</a>" }; "<li>$t</li>" }) -join '')</ul></div>" }) -join '') + '</div>'
        & $sec 'plan' 'Suggested target topology and upgrade roadmap' "$tgt<h3>Roadmap</h3>$ph"
        $vm = '<ul class="check">' + (($plan.VerifyManually | ForEach-Object { "<li><b>$(HE $_.Item)</b> - $(HE $_.Why) <a href='$(HE $_.Ref.Url)' target='_blank' rel='noopener'>reference</a></li>" }) -join '') + '</ul>'
        & $sec 'verify' 'Check by hand' "<p>These settings matter as much as the findings above, but they live in registry, services or cloud configuration that LDAP can't read.</p>$vm"
    }

    if ($Tabs -and $DrawingFile -and (Test-Path $DrawingFile)) {
        $xmlText = [System.IO.File]::ReadAllText($DrawingFile)
        $names = @(([xml]$xmlText).mxfile.diagram | ForEach-Object { $_.name })
        $webUrl = if ($NoDrawIoWeb) { $null } else { Get-AdtdDrawIoWebUrl $DrawingFile }
        $sub = ($names | ForEach-Object -Begin { $i = 0 } -Process { "<button class='sub' data-page='$i'>$(HE $_)</button>"; $i++ }) -join ''
        $link = if ($webUrl -and $webUrl.Length -lt 1900000) { "<a class='btn' href='$(HE $webUrl)' target='_blank' rel='noopener'>Open all pages in draw.io web</a>" } else { '' }
        $body = "<p class='muted'>File <code>$(HE (Split-Path $DrawingFile -Leaf))</code>. Pick a page. Use the viewer's toolbar to zoom or open it full screen, or edit it in draw.io. $link</p><div class='subtabs'>$sub</div><div id='dgm' class='dgm'></div><p id='dgm-offline' class='muted' hidden>The draw.io viewer could not load (no internet access?). Open the .drawio file in draw.io desktop, or use the link above on a machine with internet access.</p>"
        $body += "<script type='application/json' id='dgm-xml'>$(($xmlText | ConvertTo-Json -Compress) -replace '</', '<\/')</script>"
        if (-not $NoDrawIoWeb) { $body += "<script src='https://viewer.diagrams.net/js/viewer-static.min.js' async onerror=`"document.getElementById('dgm-offline').hidden=false`"></script>" }
        & $sec 'diagrams' 'Diagrams' $body
    } elseif ($DrawingFile -and (Test-Path $DrawingFile)) {
        $leaf = HE (Split-Path $DrawingFile -Leaf)
        $body = "<p>File: <code>$leaf</code>. Open it in <b>draw.io desktop</b>, or in <b>draw.io on the web</b>: <a href='https://app.diagrams.net' target='_blank' rel='noopener'>app.diagrams.net</a> &rarr; <i>Open existing diagram</i>."
        if (-not $NoDrawIoWeb) {
            $url = Get-AdtdDrawIoWebUrl $DrawingFile
            if ($url.Length -lt 1900000) { $body += " Or use this link, which opens the drawing straight in draw.io on the web (the drawing is inside the link and is not uploaded): <a class='btn' href='$(HE $url)' target='_blank' rel='noopener'>Open in draw.io web</a>" }
            $cfg = @{ highlight = '#2f6fb3'; nav = $true; resize = $true; toolbar = 'zoom pages layers lightbox'; edit = '_blank'; xml = [System.IO.File]::ReadAllText($DrawingFile) } | ConvertTo-Json -Compress
            $body += "</p><div class='viewer'><div class='mxgraph' style='max-width:100%;border:1px solid var(--line);border-radius:8px' data-mxgraph='$(HE $cfg)'></div></div><p class='muted'>The interactive viewer loads draw.io's viewer script from viewer.diagrams.net and needs internet access; the drawing itself stays in this file.</p><script src='https://viewer.diagrams.net/js/viewer-static.min.js' async></script>"
        } else { $body += '</p>' }
        & $sec 'diagrams' 'Diagrams' $body
    }

    $inventory = "<h3>Domains</h3>" + (ConvertTo-AdtdHtmlTable $inv.Domains @('Name', 'NetBIOS', 'ParentDomain', 'FunctionalLevelName', 'PdcEmulator', 'RidMaster', 'InfrastructureMaster', 'SysvolReplication')) +
        "<h3>Domain controllers</h3>" + (ConvertTo-AdtdHtmlTable $inv.DomainControllers @('Name', 'Domain', 'Site', 'OperatingSystem', 'OSBuild', 'OSEndOfSupport', 'IsGlobalCatalog', 'IsReadOnly', 'FsmoRoles')) +
        "<h3>Sites</h3>" + (ConvertTo-AdtdHtmlTable $inv.Sites @('Name', 'Location', 'Description', 'ISTG', 'UniversalGroupCaching')) +
        "<h3>Subnets</h3>" + (ConvertTo-AdtdHtmlTable $inv.Subnets @('Name', 'Site', 'Location', 'Description')) +
        "<h3>Site links</h3>" + (ConvertTo-AdtdHtmlTable $inv.SiteLinks @('Name', 'Transport', 'Sites', 'Cost', 'ReplIntervalMin', 'ChangeNotification')) +
        "<h3>Trusts</h3>" + (ConvertTo-AdtdHtmlTable $inv.Trusts @('Source', 'Target', 'Kind', 'Direction', 'Flags', 'Created')) +
        "<h3>Replication connections</h3>" + (ConvertTo-AdtdHtmlTable $inv.Connections @('From', 'To', 'FromSite', 'ToSite', 'Automatic', 'Enabled', 'Transport'))
    if (@($inv.AppPartitions).Count) { $inventory += '<h3>Application partitions</h3>' + (ConvertTo-AdtdHtmlTable $inv.AppPartitions @('Name', 'Replicas', 'ReadOnlyReplicas')) }
    if (@($inv.Dfsr).Count) { $inventory += '<h3>DFS Replication</h3>' + (ConvertTo-AdtdHtmlTable $inv.Dfsr @('Domain', 'Name', 'Members', 'Folders')) }
    if ($inv.Exchange) { $inventory += "<h3>Exchange ($(HE $inv.Exchange.Organization))</h3>" + (ConvertTo-AdtdHtmlTable $inv.Exchange.Servers @('Name', 'Site', 'Product', 'Version', 'Roles', 'Dag')) }
    if ($inv.Security) {
        $rows = @(foreach ($d in $inv.Security.Domains) {
                [pscustomobject]@{
                    Domain = $d.Domain; Users = "$($d.Users.Enabled) enabled of $($d.Users.Total)"; Computers = "$($d.Computers.Enabled) enabled of $($d.Computers.Total)"
                    DomainAdmins = @($d.Groups | Where-Object Key -eq 'DomainAdmins')[0].EnabledMembers; Krbtgt = "$($d.KrbtgtPasswordAgeDays) days"
                    PasswordPolicy = "min $($d.PasswordPolicy.MinLength), lockout $($d.PasswordPolicy.LockoutThreshold), $($d.PasswordPolicy.FineGrainedPolicies) fine-grained"
                    Laps = "$($d.Computers.WindowsLapsCovered + $d.Computers.LegacyLapsCovered) of $($d.Computers.LapsEligible)"; gMSA = $d.GmsaCount
                }
            })
        $inventory += '<h3>Security overview by domain</h3>' + (ConvertTo-AdtdHtmlTable $rows @('Domain', 'Users', 'Computers', 'DomainAdmins', 'Krbtgt', 'PasswordPolicy', 'Laps', 'gMSA'))
        $os = @(foreach ($d in $inv.Security.Domains) { foreach ($o in $d.Computers.OsCounts) { [pscustomobject]@{ Domain = $d.Domain; OperatingSystem = $o.Name; Count = $o.Count } } })
        $inventory += '<h3>Computer operating systems</h3>' + (ConvertTo-AdtdHtmlTable ($os | Sort-Object Domain, @{ E = 'Count'; Descending = $true }) @('Domain', 'OperatingSystem', 'Count'))
    }
    & $sec 'inventory' 'Inventory' $inventory

    $nav = ($sections | ForEach-Object { "<a href='#s-$($_.Id)'>$(HE ($_.Title -replace ' \(\d+\)$', ''))</a>" }) -join ''
    $body = ($sections | ForEach-Object { "<section id='s-$($_.Id)'><h2>$(HE $_.Title)</h2>$($_.Body)</section>" }) -join "`n"
    $forestBox = "<section><h2>Forest</h2><p>Schema master <b>$(HE $f.SchemaMaster)</b> &#183; Domain naming master <b>$(HE $f.DomainNamingMaster)</b> &#183; Tombstone lifetime <b>$($f.TombstoneLifetimeDays) days</b>$(if ($f.ExchangeSchemaName) { " &#183; Exchange schema <b>$(HE $f.ExchangeSchemaName)</b> ($($f.ExchangeSchemaVersion))" })</p><p class='muted'>$((@($f.OptionalFeatures) | ForEach-Object { "$(HE $_.Name): $(if ($_.Enabled) { 'on' } else { 'off' })" }) -join ' &#183; ')</p></section>"
    if ($Tabs) {
        $get = { param($ids) ($sections | Where-Object { $ids -contains $_.Id } | ForEach-Object { "<section id='s-$($_.Id)'><h2>$(HE $_.Title)</h2>$($_.Body)</section>" }) -join "`n" }
        $filter = "<div class='filters'><button class='f on' data-sev=''>All ($($findings.Count))</button><button class='f' data-sev='high'>High ($($cnt.High))</button><button class='f' data-sev='medium'>Medium ($($cnt.Medium))</button><button class='f' data-sev='low'>Low ($($cnt.Low))</button><select id='fcat'><option value=''>All categories</option><option>Security</option><option>Health</option><option>Hybrid</option></select><input id='fq' type='search' placeholder='Search findings and affected objects'></div>"
        $tabsDef = @(
            , @('summary', 'Summary', ((& $get @('summary')) + $forestBox))
            , @('findings', "Findings ($($findings.Count))", ($filter + (& $get @('security', 'health', 'hybrid'))))
        )
        if (@($sections | Where-Object Id -eq 'diagrams').Count) { $tabsDef += , @('diagrams', 'Diagrams', (& $get @('diagrams'))) }
        if ($plan) { $tabsDef += , @('plan', 'Hybrid plan', (& $get @('gaps', 'plan', 'verify'))) }
        $tabsDef += , @('inventory', 'Inventory', (& $get @('inventory')))
        $nav = ($tabsDef | ForEach-Object { "<button class='tab' data-tab='$($_[0])'>$(HE $_[1])</button>" }) -join ''
        $body = ($tabsDef | ForEach-Object { "<div class='panel' id='t-$($_[0])'>$($_[2])</div>" }) -join "`n"
        $body += @'
<script>
(function(){
  var tabs=[].slice.call(document.querySelectorAll('button.tab')), panels=[].slice.call(document.querySelectorAll('.panel'));
  function show(id){ tabs.forEach(function(t){t.classList.toggle('on',t.dataset.tab===id)}); panels.forEach(function(p){p.hidden=p.id!=='t-'+id}); if(id==='diagrams'){ drawPage(current) } try{history.replaceState(null,'','#'+id)}catch(e){} }
  tabs.forEach(function(t){ t.addEventListener('click',function(){ show(t.dataset.tab) }) });
  function route(){ var h=location.hash.slice(1); if(!h){ show('summary'); return }
    if(document.getElementById('t-'+h)){ show(h); return }
    var el=document.getElementById(h); if(el){ var p=el.closest('.panel'); if(p){ show(p.id.slice(2)); el.scrollIntoView(); return } } show('summary') }
  document.addEventListener('click',function(e){ var a=e.target.closest('a[href^="#"]'); if(!a) return; var id=a.getAttribute('href').slice(1), el=document.getElementById(id); if(el&&el.closest('.panel')){ e.preventDefault(); show(el.closest('.panel').id.slice(2)); el.scrollIntoView({behavior:'smooth'}) } });
  // findings filter
  var sev='', fcat=document.getElementById('fcat'), fq=document.getElementById('fq');
  function filt(){ var q=(fq&&fq.value||'').toLowerCase(), c=fcat?fcat.value:'';
    [].forEach.call(document.querySelectorAll('article.finding'),function(a){ var ok=(!sev||a.classList.contains('sev-'+sev))&&(!c||a.dataset.cat===c)&&(!q||a.textContent.toLowerCase().indexOf(q)>=0); a.hidden=!ok }) }
  [].forEach.call(document.querySelectorAll('button.f'),function(b){ b.addEventListener('click',function(){ sev=b.dataset.sev; [].forEach.call(document.querySelectorAll('button.f'),function(x){x.classList.toggle('on',x===b)}); filt() }) });
  if(fcat) fcat.addEventListener('change',filt); if(fq) fq.addEventListener('input',filt);
  // diagrams: one draw.io viewer, re-created for the selected page
  var xmlEl=document.getElementById('dgm-xml'), xml=xmlEl?JSON.parse(xmlEl.textContent):null, current=0;
  var subs=[].slice.call(document.querySelectorAll('button.sub'));
  subs.forEach(function(b){ b.addEventListener('click',function(){ current=+b.dataset.page; drawPage(current) }) });
  function drawPage(i){ if(!xml) return; subs.forEach(function(b){ b.classList.toggle('on',+b.dataset.page===i) });
    var host=document.getElementById('dgm'); if(!host||host.offsetParent===null) return;
    if(!window.GraphViewer){ setTimeout(function(){ if(window.GraphViewer) drawPage(i); else document.getElementById('dgm-offline').hidden=false },1500); return }
    host.innerHTML=''; var d=document.createElement('div'); d.className='mxgraph'; d.style.maxWidth='100%';
    d.setAttribute('data-mxgraph',JSON.stringify({highlight:'#2f6fb3',nav:true,resize:true,page:i,toolbar:'zoom layers lightbox',edit:'_blank',xml:xml}));
    host.appendChild(d); GraphViewer.createViewerForElement(d) }
  window.addEventListener('hashchange',route); route();
})();
</script>
'@
    }
    $optional = (@($f.OptionalFeatures) | ForEach-Object { "$(HE $_.Name): $(if ($_.Enabled) { 'on' } else { 'off' })" }) -join ' &#183; '
    $html = @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>AD Assessment Report</title>
<style>
:root{--bg:#f7f8fa;--card:#fff;--fg:#1d2330;--muted:#5d6675;--line:#e1e4ea;--accent:#2f6fb3;--high:#b3261e;--med:#a15c00;--low:#2f6fb3;--ok:#2e7d32;--code:#eef1f5}
@media (prefers-color-scheme:dark){:root{--bg:#14171c;--card:#1d2128;--fg:#e6e8ec;--muted:#9aa3b2;--line:#2c323c;--accent:#7fb0e8;--high:#f28b82;--med:#f4b860;--low:#8ab4f8;--ok:#81c995;--code:#262b33}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:14px/1.55 "Segoe UI",system-ui,sans-serif}
header.top{padding:28px 32px 12px}h1{margin:0 0 4px;font-size:24px}h2{font-size:19px;margin:0 0 12px}h3{font-size:15px;margin:16px 0 6px}
a{color:var(--accent)}.muted{color:var(--muted)}code{background:var(--code);padding:1px 5px;border-radius:5px}
nav{display:flex;flex-wrap:wrap;gap:6px;padding:0 32px 16px;position:sticky;top:0;background:var(--bg);z-index:2;padding-top:8px}nav a{text-decoration:none;border:1px solid var(--line);border-radius:999px;padding:3px 12px;background:var(--card)}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;padding:0 32px 16px}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px 14px}.card b{display:block;font-size:22px}
.card.h b{color:var(--high)}.card.m b{color:var(--med)}.card.l b{color:var(--low)}
section{background:var(--card);border:1px solid var(--line);border-radius:10px;margin:0 32px 16px;padding:18px 20px}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:24px}
.scroll{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:13px}th,td{text-align:left;padding:6px 8px;border-bottom:1px solid var(--line);vertical-align:top}th{color:var(--muted);font-weight:600}tr.bad td{color:var(--high)}
.finding{border:1px solid var(--line);border-left:5px solid var(--low);border-radius:8px;padding:12px 16px;margin:0 0 14px}
.finding.sev-high{border-left-color:var(--high)}.finding.sev-medium{border-left-color:var(--med)}
.finding header{display:flex;flex-wrap:wrap;align-items:baseline;gap:8px}.finding h3{margin:0;font-size:16px}.fid{font-family:Consolas,monospace;color:var(--muted)}.meta{width:100%;font-size:12px}
.badge{font-size:11px;font-weight:700;text-transform:uppercase;padding:2px 8px;border-radius:999px;color:#fff}.b-high{background:var(--high)}.b-medium{background:var(--med)}.b-low{background:var(--low)}
@media (prefers-color-scheme:dark){.badge{color:#14171c}}
details summary{cursor:pointer;color:var(--accent)}ul.ev{columns:2;font-size:12.5px;margin:6px 0}.refs{font-size:12.5px}
.pill{white-space:nowrap;padding:1px 8px;border-radius:999px;font-size:12px;border:1px solid var(--line)}.st-present{color:var(--ok)}.st-missing{color:var(--high)}.st-partial{color:var(--med)}.st-notdetectable{color:var(--muted)}
.phases{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px}.phase{border:1px solid var(--line);border-top:5px solid var(--low);border-radius:8px;padding:8px 14px}
.phase.p1{border-top-color:var(--high)}.phase.p2{border-top-color:var(--med)}.phase.p4{border-top-color:var(--ok)}.phase ul{padding-left:18px;font-size:13px}
ul.check li{margin:4px 0}.btn{display:inline-block;margin-left:6px;padding:4px 12px;border-radius:6px;background:var(--accent);color:#fff;text-decoration:none}
footer{padding:8px 32px 32px;color:var(--muted);font-size:12px}
@media (max-width:700px){header.top,nav,.cards{padding-left:16px;padding-right:16px}section{margin:0 16px 16px}.grid2{grid-template-columns:1fr}ul.ev{columns:1}}
nav.tabs button.tab{font:inherit;cursor:pointer;border:1px solid var(--line);border-radius:999px;padding:4px 14px;background:var(--card);color:var(--fg)}nav.tabs button.tab.on{background:var(--accent);color:#fff;border-color:var(--accent)}
.filters{display:flex;flex-wrap:wrap;gap:8px;margin:0 32px 12px}.filters button,.subtabs button{font:inherit;cursor:pointer;border:1px solid var(--line);border-radius:6px;padding:3px 10px;background:var(--card);color:var(--fg)}.filters button.on,.subtabs button.on{border-color:var(--accent);color:var(--accent);font-weight:600}
.filters select,.filters input{font:inherit;padding:3px 8px;border:1px solid var(--line);border-radius:6px;background:var(--card);color:var(--fg)}.filters input{flex:1;min-width:180px}
.subtabs{display:flex;flex-wrap:wrap;gap:6px;margin:8px 0 12px}.dgm{min-height:300px;background:#fff;border:1px solid var(--line);border-radius:8px;overflow:auto}
@media (max-width:700px){.filters{margin:0 16px 12px}}
@media print{nav,.viewer,.btn,.filters,.subtabs{display:none}.panel{display:block!important}.panel[hidden]{display:block!important}section,.finding{break-inside:avoid-page}body{background:#fff}}
</style></head><body>
<header class="top"><h1>Active Directory assessment: $(HE $f.Name)</h1>
<div class="muted">Collected $(HE $inv.CollectedAt) from $(HE $inv.CollectedFrom) with $(HE $inv.Tool) $(HE $inv.ToolVersion). Read-only: nothing in Active Directory was changed.</div></header>
<div class="cards">
<div class="card h"><span class="muted">High</span><b>$($cnt.High)</b></div>
<div class="card m"><span class="muted">Medium</span><b>$($cnt.Medium)</b></div>
<div class="card l"><span class="muted">Low</span><b>$($cnt.Low)</b></div>
<div class="card"><span class="muted">Forest level</span><b>$(HE ($f.FunctionalLevelName -replace 'Windows Server ', ''))</b></div>
<div class="card"><span class="muted">Schema</span><b>$($f.SchemaVersion)</b><span class="muted">$(HE $f.SchemaVersionName)</span></div>
<div class="card"><span class="muted">Domain controllers</span><b>$(@($inv.DomainControllers).Count)</b></div>
</div>
<nav$(if ($Tabs) { " class='tabs'" })>$nav</nav>
$(if (-not $Tabs) { $forestBox })
$body
<footer>Generated by $(HE $inv.Tool) $(HE $inv.ToolVersion). Findings are based on what an ordinary domain user can read over LDAP; confirm each one before you change production systems.</footer>
</body></html>
"@
    [System.IO.File]::WriteAllText($Path, $html, (New-Object System.Text.UTF8Encoding($false)))
    return $Path
}
