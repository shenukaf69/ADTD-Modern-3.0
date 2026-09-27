# ADTD Modern - turns an inventory into drawings (draw.io / Visio) and reports (HTML, CSV, JSON).
# Layouts build a neutral page model (nodes, containers, edges); each back end just draws that model.

function ConvertTo-HtmlText { param([string]$Text) return [System.Net.WebUtility]::HtmlEncode("$Text") }
Set-Alias -Name HE -Value ConvertTo-HtmlText -Scope Script

$script:NodeStyles = @{
    site      = 'swimlane;html=1;startSize=28;rounded=1;arcSize=6;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;fontSize=13;swimlaneFillColor=#f4f8fd;collapsible=0;'
    group     = 'swimlane;html=1;startSize=28;rounded=1;arcSize=6;fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;fontSize=13;swimlaneFillColor=#faf6fc;collapsible=0;'
    dc        = 'rounded=1;whiteSpace=wrap;html=1;arcSize=10;fillColor=#d5e8d4;strokeColor=#82b366;fontSize=11;align=left;spacingLeft=6;'
    rodc      = 'rounded=1;whiteSpace=wrap;html=1;arcSize=10;fillColor=#fff2cc;strokeColor=#d6b656;fontSize=11;align=left;spacingLeft=6;dashed=1;'
    warn      = 'rounded=1;whiteSpace=wrap;html=1;arcSize=10;fillColor=#ffe6cc;strokeColor=#d79b00;fontSize=11;align=left;spacingLeft=6;'
    bad       = 'rounded=1;whiteSpace=wrap;html=1;arcSize=10;fillColor=#f8cecc;strokeColor=#b85450;fontSize=11;align=left;spacingLeft=6;'
    domain    = 'rounded=1;whiteSpace=wrap;html=1;arcSize=6;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=11;align=left;verticalAlign=top;spacingLeft=8;spacingTop=4;'
    forest    = 'rounded=1;whiteSpace=wrap;html=1;arcSize=4;fillColor=#e1d5e7;strokeColor=#9673a6;fontSize=11;align=left;verticalAlign=top;spacingLeft=8;spacingTop=4;'
    external  = 'rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;dashed=1;fontSize=11;'
    hub       = 'ellipse;shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=10;'
    text      = 'text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;fontSize=10;fontColor=#555555;spacingLeft=4;'
    title     = 'text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=top;whiteSpace=wrap;fontSize=20;fontStyle=1;'
    ou        = 'rounded=1;whiteSpace=wrap;html=1;arcSize=8;fillColor=#f5f5f5;strokeColor=#999999;fontSize=11;align=left;verticalAlign=top;spacingLeft=6;spacingTop=2;'
    ouroot    = 'rounded=1;whiteSpace=wrap;html=1;arcSize=8;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=11;align=left;verticalAlign=top;spacingLeft=6;spacingTop=2;'
    partition = 'shape=cylinder;whiteSpace=wrap;html=1;boundedLbl=1;size=8;fillColor=#e1d5e7;strokeColor=#9673a6;fontSize=11;'
    exchange  = 'rounded=1;whiteSpace=wrap;html=1;arcSize=10;fillColor=#ffe6cc;strokeColor=#d79b00;fontSize=11;align=left;spacingLeft=6;'
    panel     = 'rounded=1;whiteSpace=wrap;html=1;arcSize=2;fillColor=#ffffff;strokeColor=#999999;fontSize=11;align=left;verticalAlign=top;spacingLeft=10;spacingTop=6;'
}
$script:EdgeStyles = @{
    sitelink = 'endArrow=none;html=1;strokeWidth=2;strokeColor=#6c8ebf;fontSize=10;labelBackgroundColor=#ffffff;'
    auto     = 'endArrow=block;endFill=1;html=1;strokeColor=#82b366;fontSize=9;'
    manual   = 'endArrow=block;endFill=1;html=1;strokeColor=#d79b00;strokeWidth=2;fontSize=9;'
    auto2    = 'startArrow=block;startFill=1;endArrow=block;endFill=1;html=1;strokeColor=#82b366;fontSize=9;'
    manual2  = 'startArrow=block;startFill=1;endArrow=block;endFill=1;html=1;strokeColor=#d79b00;strokeWidth=2;fontSize=9;'
    disabled = 'endArrow=block;html=1;strokeColor=#b85450;dashed=1;fontSize=9;'
    tree     = 'endArrow=none;html=1;strokeColor=#6c8ebf;strokeWidth=2;fontSize=10;labelBackgroundColor=#ffffff;'
    trust1   = 'endArrow=block;endFill=1;html=1;strokeColor=#9673a6;strokeWidth=2;dashed=1;fontSize=10;labelBackgroundColor=#ffffff;'
    trust2   = 'startArrow=block;startFill=1;endArrow=block;endFill=1;html=1;strokeColor=#9673a6;strokeWidth=2;dashed=1;fontSize=10;labelBackgroundColor=#ffffff;'
    outree   = 'edgeStyle=orthogonalEdgeStyle;rounded=0;endArrow=none;html=1;strokeColor=#999999;exitX=0.06;exitY=1;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;'
    replica  = 'endArrow=none;html=1;strokeColor=#9673a6;dashed=1;'
    dfsr     = 'endArrow=block;endFill=1;html=1;strokeColor=#82b366;'
}
# Visio fill / line colours for the same kinds (RGB).
$script:VisioColors = @{
    site = @(218, 232, 252, 108, 142, 191); group = @(225, 213, 231, 150, 115, 166); dc = @(213, 232, 212, 130, 179, 102)
    rodc = @(255, 242, 204, 214, 182, 86); warn = @(255, 230, 204, 215, 155, 0); bad = @(248, 206, 204, 184, 84, 80)
    domain = @(218, 232, 252, 108, 142, 191); forest = @(225, 213, 231, 150, 115, 166); external = @(245, 245, 245, 102, 102, 102)
    hub = @(218, 232, 252, 108, 142, 191); ou = @(245, 245, 245, 153, 153, 153); ouroot = @(218, 232, 252, 108, 142, 191)
    partition = @(225, 213, 231, 150, 115, 166); exchange = @(255, 230, 204, 215, 155, 0); panel = @(255, 255, 255, 153, 153, 153)
}

function New-AdtdPage {
    param([string]$Name)
    [pscustomobject]@{ Name = $Name; Nodes = New-Object System.Collections.ArrayList; Edges = New-Object System.Collections.ArrayList; Index = @{} }
}

function Add-AdtdNode {
    param($Page, [string]$Id, [string]$Label, [double]$X, [double]$Y, [double]$W, [double]$H, [string]$Kind, [string]$Parent, [string]$Tooltip)
    $n = [pscustomobject]@{ Id = $Id; Label = $Label; X = $X; Y = $Y; W = $W; H = $H; Kind = $Kind; Parent = $Parent; Tooltip = $Tooltip }
    [void]$Page.Nodes.Add($n)
    $Page.Index[$Id] = $n
    return $n
}

function Add-AdtdEdge {
    param($Page, [string]$Source, [string]$Target, [string]$Label, [string]$Kind)
    if (-not $Page.Index.ContainsKey($Source) -or -not $Page.Index.ContainsKey($Target)) { return }
    [void]$Page.Edges.Add([pscustomobject]@{ Id = "e$($Page.Edges.Count + 1)"; Source = $Source; Target = $Target; Label = $Label; Kind = $Kind })
}

function Get-SafeId { param([string]$Prefix, [string]$Name) return $Prefix + '_' + ($Name -replace '[^A-Za-z0-9]', '_').ToLower() }

function Get-DcKind {
    param($Dc)
    if ($Dc.OSSupportState -eq 'Unsupported') { return 'bad' }
    if ($Dc.OSSupportState -eq 'EndingSoon') { return 'warn' }
    if ($Dc.IsReadOnly) { return 'rodc' }
    return 'dc'
}

function Get-DcLabel {
    param($Dc)
    $tags = @()
    if ($Dc.IsReadOnly) { $tags += 'RODC' }
    if ($Dc.IsGlobalCatalog) { $tags += 'GC' }
    $tags += @($Dc.FsmoRoles)
    $l = "<b>$(HE $Dc.Name)</b>"
    if ($tags.Count) { $l += " <font color='#555555'>[$(HE ($tags -join ', '))]</font>" }
    $l += "<br>$(HE $Dc.OperatingSystem)"
    if ($Dc.Domain) { $l += "<br><font color='#555555'>$(HE $Dc.Domain)</font>" }
    return $l
}

function Add-SiteContainers {
    <# Draws one container per site holding its DCs; returns a map site name -> container node. #>
    param($Page, $Inventory, [switch]$WithSubnets, [string[]]$OnlySites)
    $dcW = 200; $dcH = 62; $gap = 12; $colGap = 140; $rowGap = 120
    $sites = @($Inventory.Sites)
    if ($OnlySites) { $sites = @($sites | Where-Object { $OnlySites -contains $_.Name }) }
    # Busiest sites first so hubs end up top-left.
    $sites = @($sites | Sort-Object @{ E = { $n = $_.Name; - @($Inventory.SiteLinks | Where-Object { $_.Sites -contains $n }).Count } }, Name)

    $boxes = @()
    foreach ($s in $sites) {
        $dcs = @($Inventory.DomainControllers | Where-Object { $_.Site -eq $s.Name })
        $cols = [math]::Max(1, [math]::Min(3, $dcs.Count))
        $rows = [math]::Ceiling($dcs.Count / $cols)
        $w = [math]::Max(240, $cols * ($dcW + $gap) + $gap)
        $h = 28 + $gap + [math]::Max(1, $rows) * ($dcH + $gap)
        if (-not $dcs.Count) { $h = 28 + 40 }
        $subLines = @()
        if ($WithSubnets) {
            $subs = @($Inventory.Subnets | Where-Object { $_.Site -eq $s.Name } | ForEach-Object { $_.Name })
            $subLines = @($subs | Select-Object -First 6)
            if ($subs.Count -gt 6) { $subLines += "+ $($subs.Count - 6) more" }
            if (-not $subs.Count) { $subLines = @('No subnets') }
            $h += 18 + 14 * $subLines.Count
        }
        $boxes += [pscustomobject]@{ Site = $s; Dcs = $dcs; Cols = $cols; W = $w; H = $h; Subnets = $subLines }
    }

    $gridCols = [math]::Max(1, [math]::Ceiling([math]::Sqrt($boxes.Count)))
    $colW = @{}; $rowH = @{}
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        $c = [int]($i % $gridCols); $r = [int][math]::Floor($i / $gridCols)
        $colW[$c] = [math]::Max([double]$colW[$c], $boxes[$i].W)
        $rowH[$r] = [math]::Max([double]$rowH[$r], $boxes[$i].H)
    }
    $map = @{}
    $top = 90
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        $b = $boxes[$i]; $c = [int]($i % $gridCols); $r = [int][math]::Floor($i / $gridCols)
        $x = 40; for ($k = 0; $k -lt $c; $k++) { $x += $colW[$k] + $colGap }
        $y = $top; for ($k = 0; $k -lt $r; $k++) { $y += $rowH[$k] + $rowGap }
        $siteLabel = HE $b.Site.Name
        if ($b.Site.Location) { $siteLabel += " <font style='font-weight:normal' color='#555555'>($(HE $b.Site.Location))</font>" }
        $sid = Get-SafeId 'site' $b.Site.Name
        $node = Add-AdtdNode $Page $sid $siteLabel $x $y $b.W $b.H 'site' $null $b.Site.Description
        $map[$b.Site.Name] = $node
        $j = 0
        foreach ($dc in $b.Dcs) {
            $dx = $gap + ($j % $b.Cols) * ($dcW + $gap)
            $dy = 28 + $gap + [math]::Floor($j / $b.Cols) * ($dcH + $gap)
            $tip = "$($dc.HostName) | $($dc.OperatingSystem) (build $($dc.OSBuild)); support ends $($dc.OSEndOfSupport)"
            [void](Add-AdtdNode $Page (Get-SafeId 'dc' $dc.Name) (Get-DcLabel $dc) $dx $dy $dcW $dcH (Get-DcKind $dc) $sid $tip)
            $j++
        }
        if (-not $b.Dcs.Count) {
            [void](Add-AdtdNode $Page "$sid`_empty" '<i>No domain controllers</i>' $gap 34 ($b.W - 2 * $gap) 24 'text' $sid $null)
        }
        if ($b.Subnets.Count) {
            $sy = $b.H - (8 + 14 * $b.Subnets.Count)
            [void](Add-AdtdNode $Page "$sid`_subnets" ('Subnets: ' + (($b.Subnets | ForEach-Object { HE $_ }) -join '<br>')) $gap ($sy - 10) ($b.W - 2 * $gap) (14 * $b.Subnets.Count + 10) 'text' $sid $null)
        }
    }
    return $map
}

function Get-Bounds {
    param($Page)
    $maxX = 0; $maxY = 0
    foreach ($n in $Page.Nodes) { if (-not $n.Parent) { $maxX = [math]::Max($maxX, $n.X + $n.W); $maxY = [math]::Max($maxY, $n.Y + $n.H) } }
    return @($maxX, $maxY)
}

function New-AdtdSitesPage {
    param($Inventory)
    $p = New-AdtdPage 'Sites and site links'
    [void](Add-AdtdNode $p 'title' "Sites and site links - $(HE $Inventory.Forest.Name)" 40 20 900 36 'title' $null $null)
    $map = Add-SiteContainers $p $Inventory -WithSubnets
    $b = Get-Bounds $p
    $hubX = 40; $hubY = $b[1] + 80
    foreach ($l in $Inventory.SiteLinks) {
        $label = "<b>$(HE $l.Name)</b><br>cost $($l.Cost) &#183; every $($l.ReplIntervalMin) min"
        if ($l.ChangeNotification) { $label += ' &#183; change notification' }
        if ($l.Transport -eq 'SMTP') { $label += ' &#183; SMTP' }
        $members = @($l.Sites | Where-Object { $map.ContainsKey($_) })
        if ($members.Count -eq 2) {
            Add-AdtdEdge $p $map[$members[0]].Id $map[$members[1]].Id $label 'sitelink'
        } elseif ($members.Count -gt 2) {
            $hid = Get-SafeId 'link' $l.Name
            [void](Add-AdtdNode $p $hid $label $hubX $hubY 170 90 'hub' $null "Multi-site link: $($l.Sites -join ', ')")
            $hubX += 230
            foreach ($m in $members) { Add-AdtdEdge $p $hid $map[$m].Id '' 'sitelink' }
        }
    }
    if ($Inventory.SiteLinkBridges.Count) {
        $b = Get-Bounds $p
        $txt = '<b>Site link bridges</b><br>' + (($Inventory.SiteLinkBridges | ForEach-Object { "$(HE $_.Name): $(HE ($_.SiteLinks -join ', '))" }) -join '<br>')
        [void](Add-AdtdNode $p 'bridges' $txt 40 ($b[1] + 40) 600 (30 + 16 * $Inventory.SiteLinkBridges.Count) 'panel' $null $null)
    }
    Add-Legend $p
    return $p
}

function New-AdtdReplicationPage {
    param($Inventory)
    $p = New-AdtdPage 'Replication'
    [void](Add-AdtdNode $p 'title' "Replication connections - $(HE $Inventory.Forest.Name)" 40 20 900 36 'title' $null $null)
    [void](Add-SiteContainers $p $Inventory)
    # A pair of matching connections (A pulls from B and B from A) is drawn as one two-headed arrow.
    $kindOf = { param($c) if (-not $c.Enabled) { 'disabled' } elseif ($c.Automatic) { 'auto' } else { 'manual' } }
    $done = @{}
    foreach ($c in $Inventory.Connections) {
        $key = "$($c.From)|$($c.To)"
        if ($done[$key]) { continue }
        $kind = & $kindOf $c
        $back = $Inventory.Connections | Where-Object { $_.From -eq $c.To -and $_.To -eq $c.From -and (& $kindOf $_) -eq $kind } | Select-Object -First 1
        if ($back) { $done["$($c.To)|$($c.From)"] = $true; if ($kind -ne 'disabled') { $kind += '2' } }
        $done[$key] = $true
        $label = if ($c.FromSite -ne $c.ToSite) { 'inter-site' } else { '' }
        Add-AdtdEdge $p (Get-SafeId 'dc' $c.From) (Get-SafeId 'dc' $c.To) $label $kind
    }
    $b = Get-Bounds $p
    [void](Add-AdtdNode $p 'legend_conn' '<b>Arrows</b> point from the source DC to the DC that pulls changes; two heads mean both directions.<br><font color="#82b366">Green</font>: created by the KCC &#183; <font color="#d79b00">Orange</font>: created manually &#183; <font color="#b85450">Red dashed</font>: disabled' 40 ($b[1] + 30) 640 50 'panel' $null $null)
    return $p
}

function New-AdtdDomainsPage {
    param($Inventory)
    $p = New-AdtdPage 'Domains and trusts'
    $f = $Inventory.Forest
    [void](Add-AdtdNode $p 'title' "Forest $(HE $f.Name)" 40 20 900 36 'title' $null $null)
    $rb = @($f.OptionalFeatures | Where-Object { $_.Enabled } | ForEach-Object { $_.Name })
    $fl = "<b>Forest functional level:</b> $(HE $f.FunctionalLevelName)<br><b>Schema:</b> $(HE $f.SchemaVersionName) (version $($f.SchemaVersion))"
    if ($f.ExchangeSchemaName) { $fl += "<br><b>Exchange schema:</b> $(HE $f.ExchangeSchemaName) ($($f.ExchangeSchemaVersion))" }
    $fl += "<br><b>Schema master:</b> $(HE $f.SchemaMaster) &#183; <b>Domain naming master:</b> $(HE $f.DomainNamingMaster)"
    $fl += "<br><b>Optional features on:</b> $(if ($rb.Count) { HE ($rb -join ', ') } else { 'none' }) &#183; <b>Tombstone lifetime:</b> $($f.TombstoneLifetimeDays) days"
    [void](Add-AdtdNode $p 'forest' $fl 40 64 640 96 'forest' $null $null)

    $domains = @($Inventory.Domains)
    $names = @($domains | ForEach-Object { $_.Name })
    $children = @{}
    foreach ($d in $domains) { if ($d.ParentDomain -and $names -contains $d.ParentDomain) { if (-not $children[$d.ParentDomain]) { $children[$d.ParentDomain] = @() }; $children[$d.ParentDomain] += $d } }
    $roots = @($domains | Where-Object { -not $_.ParentDomain -or $names -notcontains $_.ParentDomain })

    $W = 270; $Hd = 150; $gapX = 50; $levelH = 230; $top = 210
    $script:nextX = 40
    $place = $null
    $place = {
        param($d, $depth)
        $kids = @($children[$d.Name] | Sort-Object Name)
        $xs = @()
        foreach ($k in $kids) { $xs += (& $place $k ($depth + 1)) }
        if ($xs.Count) { $x = ($xs[0] + $xs[-1]) / 2 } else { $x = $script:nextX; $script:nextX += $W + $gapX }
        $dcs = @($Inventory.DomainControllers | Where-Object { $_.Domain -eq $d.Name })
        $ro = @($dcs | Where-Object { $_.IsReadOnly }).Count
        $l = "<b>$(HE $d.Name)</b> ($(HE $d.NetBIOS))"
        if ($d.IsForestRoot) { $l += " <font color='#9673a6'>forest root</font>" }
        $l += "<br>Level: $(HE $d.FunctionalLevelName)<br>DCs: $($dcs.Count)$(if ($ro) { " ($ro read-only)" })<br>PDC: $(HE $d.PdcEmulator)<br>RID: $(HE $d.RidMaster) &#183; Infra: $(HE $d.InfrastructureMaster)<br>SYSVOL: $(HE $d.SysvolReplication)"
        $kind = if (-not $d.Reachable) { 'warn' } elseif ($d.SysvolReplication -eq 'FRS') { 'bad' } else { 'domain' }
        $n = Add-AdtdNode $p (Get-SafeId 'dom' $d.Name) $l $x ($top + $depth * $levelH) $W $Hd $kind $null $d.DN
        return $x
    }
    foreach ($r in $roots) { [void](& $place $r 0) }
    foreach ($d in $domains) {
        if ($d.ParentDomain -and $names -contains $d.ParentDomain) {
            Add-AdtdEdge $p (Get-SafeId 'dom' $d.ParentDomain) (Get-SafeId 'dom' $d.Name) 'parent-child<br>two-way transitive' 'tree'
        }
    }

    # Trusts: each trust is stored on both sides, so draw each pair once.
    $seen = @{}
    $b = Get-Bounds $p
    $extX = [math]::Max($b[0] + 160, 760); $extY = $top
    foreach ($t in $Inventory.Trusts) {
        $a = $t.Source; $z = $t.Target
        $isParentChild = @($domains | Where-Object { ($_.Name -eq $a -and $_.ParentDomain -eq $z) -or ($_.Name -eq $z -and $_.ParentDomain -eq $a) }).Count -gt 0
        if ($isParentChild) { continue }
        if ($names -notcontains $a) { continue }
        $key = (@($a, $z) | Sort-Object) -join '|'
        if ($seen[$key]) { continue }
        $seen[$key] = $true
        $zid = Get-SafeId 'dom' $z
        if (-not $p.Index.ContainsKey($zid)) {
            [void](Add-AdtdNode $p $zid "<b>$(HE $z)</b><br>external" $extX $extY 220 60 'external' $null $null)
            $extY += 100
        }
        $kindLabel = if ($t.Kind -eq 'Within forest') { 'shortcut / tree-root' } else { $t.Kind }
        $label = "$(HE $kindLabel) trust<br>$(HE $t.Direction)"
        if ($t.Flags.Count) { $label += "<br><font color='#555555'>$(HE ($t.Flags -join ', '))</font>" }
        $aid = Get-SafeId 'dom' $a
        switch ($t.Direction) {
            'Two-way' { Add-AdtdEdge $p $aid $zid $label 'trust2' }
            'Outbound' { Add-AdtdEdge $p $aid $zid $label 'trust1' }  # arrow: trusting -> trusted
            'Inbound' { Add-AdtdEdge $p $zid $aid $label 'trust1' }
            default { Add-AdtdEdge $p $aid $zid $label 'trust1' }
        }
    }
    return $p
}

function New-AdtdAppPartitionsPage {
    param($Inventory)
    $p = New-AdtdPage 'Application partitions'
    [void](Add-AdtdNode $p 'title' 'Application partitions' 40 20 900 36 'title' $null $null)
    $y = 90; $dcY = 90
    foreach ($a in $Inventory.AppPartitions) {
        $id = Get-SafeId 'nc' $a.Name
        [void](Add-AdtdNode $p $id "<b>$(HE $a.Name)</b><br>$(@($a.Replicas).Count) replica(s)" 40 $y 300 70 'partition' $null $a.DN)
        foreach ($r in @($a.Replicas) + @($a.ReadOnlyReplicas)) {
            $did = Get-SafeId 'dc' $r
            if (-not $p.Index.ContainsKey($did)) {
                $dc = $Inventory.DomainControllers | Where-Object { $_.Name -eq $r } | Select-Object -First 1
                $lbl = if ($dc) { Get-DcLabel $dc } else { "<b>$(HE $r)</b>" }
                $kind = if ($dc) { Get-DcKind $dc } else { 'dc' }
                [void](Add-AdtdNode $p $did $lbl 560 $dcY 210 62 $kind $null $null)
                $dcY += 80
            }
            Add-AdtdEdge $p $id $did '' 'replica'
        }
        $y += 110
    }
    return $p
}

function New-AdtdOuPages {
    param($Inventory)
    $pages = @()
    foreach ($domain in @($Inventory.OUs | Group-Object Domain)) {
        $p = New-AdtdPage "OUs - $($domain.Name)"
        [void](Add-AdtdNode $p 'title' "Organizational units and GPO links - $(HE $domain.Name)" 40 20 900 36 'title' $null $null)
        $items = @($domain.Group)
        $byParent = @{}
        foreach ($o in $items) { $k = "$($o.ParentDN)".ToLower(); if (-not $byParent[$k]) { $byParent[$k] = @() }; $byParent[$k] += $o }
        $script:ouY = 80
        $walk = $null
        $walk = {
            param($o, $depth)
            $links = @($o.GpoLinks)
            $lbl = "<b>$(HE $o.Name)</b>"
            if ($o.BlockInheritance) { $lbl += " <font color='#b85450'>[blocks inheritance]</font>" }
            foreach ($g in $links) {
                $t = "&#9656; $(HE $g.Name)"
                if ($g.Enforced) { $t += " <font color='#b85450'>(enforced)</font>" }
                if ($g.Disabled) { $t = "<font color='#999999'><s>$t</s> (link disabled)</font>" }
                $lbl += "<br>$t"
            }
            $h = 28 + 15 * $links.Count
            $kind = if ($depth -eq 0) { 'ouroot' } else { 'ou' }
            [void](Add-AdtdNode $p (Get-SafeId 'ou' $o.DN) $lbl (40 + $depth * 36) $script:ouY 320 $h $kind $null $o.DN)
            $script:ouY += $h + 12
            foreach ($c in @($byParent["$($o.DN)".ToLower()] | Sort-Object Name)) {
                & $walk $c ($depth + 1)
                Add-AdtdEdge $p (Get-SafeId 'ou' $o.DN) (Get-SafeId 'ou' $c.DN) '' 'outree'
            }
        }
        foreach ($r in @($items | Where-Object { $_.Depth -eq 0 })) { & $walk $r 0 }
        $pages += $p
    }
    return $pages
}

function New-AdtdDfsrPage {
    param($Inventory)
    $p = New-AdtdPage 'DFS Replication'
    [void](Add-AdtdNode $p 'title' 'DFS Replication groups' 40 20 900 36 'title' $null $null)
    $y = 90
    foreach ($rg in $Inventory.Dfsr) {
        $members = @($rg.Members)
        $cols = [math]::Max(1, [math]::Min(4, $members.Count))
        $rows = [math]::Max(1, [math]::Ceiling($members.Count / $cols))
        $w = [math]::Max(320, $cols * 200 + 20)
        $h = 28 + 20 + $rows * 70 + 30
        $gid = Get-SafeId 'rg' "$($rg.Domain)_$($rg.Name)"
        [void](Add-AdtdNode $p $gid "$(HE $rg.Name) <font style='font-weight:normal' color='#555555'>($(HE $rg.Domain))</font>" 40 $y $w $h 'group' $null $null)
        $i = 0
        foreach ($m in $members) {
            [void](Add-AdtdNode $p "$gid`_$(Get-SafeId 'm' $m)" "<b>$(HE $m)</b>" (10 + ($i % $cols) * 200) (40 + [math]::Floor($i / $cols) * 70) 180 46 'dc' $gid $null)
            $i++
        }
        $folders = if (@($rg.Folders).Count) { 'Folders: ' + (HE ($rg.Folders -join ', ')) } else { 'No replicated folders' }
        [void](Add-AdtdNode $p "$gid`_folders" $folders 10 ($h - 30) ($w - 20) 24 'text' $gid $null)
        foreach ($c in $rg.Connections) {
            if (-not $c.From -or -not $c.To) { continue }
            $kind = if ($c.Enabled) { 'dfsr' } else { 'disabled' }
            Add-AdtdEdge $p "$gid`_$(Get-SafeId 'm' $c.From)" "$gid`_$(Get-SafeId 'm' $c.To)" '' $kind
        }
        $y += $h + 60
    }
    return $p
}

function New-AdtdExchangePage {
    param($Inventory)
    $x = $Inventory.Exchange
    $p = New-AdtdPage 'Exchange'
    [void](Add-AdtdNode $p 'title' "Exchange organization $(HE $x.Organization)" 40 20 900 36 'title' $null $null)
    $info = "<b>Schema:</b> $(HE $x.SchemaName)<br><b>Servers:</b> $(@($x.Servers).Count) &#183; <b>DAGs:</b> $(if (@($x.Dags).Count) { HE ($x.Dags -join ', ') } else { 'none' })"
    [void](Add-AdtdNode $p 'exinfo' $info 40 64 640 54 'panel' $null $null)
    $y = 150; $x0 = 40
    foreach ($g in @($x.Servers | Group-Object { if ($_.Site) { $_.Site } else { '(no site)' } })) {
        $srv = @($g.Group)
        $cols = [math]::Max(1, [math]::Min(3, $srv.Count)); $rows = [math]::Ceiling($srv.Count / $cols)
        $w = [math]::Max(260, $cols * 232 + 12); $h = 28 + 12 + $rows * 88
        $sid = Get-SafeId 'exsite' $g.Name
        [void](Add-AdtdNode $p $sid "Site $(HE $g.Name)" $x0 $y $w $h 'site' $null $null)
        $i = 0
        foreach ($s in $srv) {
            $l = "<b>$(HE $s.Name)</b><br>$(HE $s.Product) ($(HE $s.Version))<br>$(HE ($s.Roles -join ', '))"
            if ($s.Dag) { $l += "<br>DAG: $(HE $s.Dag)" }
            $kind = if ($s.Supported) { 'exchange' } else { 'bad' }
            [void](Add-AdtdNode $p "$sid`_$(Get-SafeId 'x' $s.Name)" $l (12 + ($i % $cols) * 232) (40 + [math]::Floor($i / $cols) * 88) 220 76 $kind $sid $s.HostName)
            $i++
        }
        $x0 += $w + 60
        if ($x0 -gt 1600) { $x0 = 40; $y += $h + 60 }
    }
    return $p
}

function New-AdtdSummaryPage {
    param($Inventory)
    $p = New-AdtdPage 'Summary'
    $f = $Inventory.Forest
    [void](Add-AdtdNode $p 'title' "Active Directory topology - $(HE $f.Name)" 40 20 1000 36 'title' $null $null)
    $os = @($Inventory.DomainControllers | Group-Object OperatingSystem | Sort-Object Name | ForEach-Object { "$(HE $_.Name): $($_.Count)" }) -join '<br>'
    $facts = "<b>Collected:</b> $(HE $Inventory.CollectedAt) from $(HE $Inventory.CollectedFrom)<br><b>Forest level:</b> $(HE $f.FunctionalLevelName)<br><b>Schema:</b> $(HE $f.SchemaVersionName)" +
        "<br><b>Domains:</b> $(@($Inventory.Domains).Count) &#183; <b>Sites:</b> $(@($Inventory.Sites).Count) &#183; <b>Subnets:</b> $(@($Inventory.Subnets).Count) &#183; <b>Site links:</b> $(@($Inventory.SiteLinks).Count)" +
        "<br><b>Domain controllers:</b> $(@($Inventory.DomainControllers).Count) ($(@($Inventory.DomainControllers | Where-Object IsReadOnly).Count) read-only, $(@($Inventory.DomainControllers | Where-Object IsGlobalCatalog).Count) global catalogs)<br><br><b>DC operating systems</b><br>$os"
    [void](Add-AdtdNode $p 'facts' $facts 40 70 460 260 'panel' $null $null)

    $findings = @($Inventory.Findings | Sort-Object @{ E = { @{ High = 0; Medium = 1; Low = 2 }[$_.Severity] } })
    $shown = @($findings | Select-Object -First 30)
    $rows = foreach ($x in $shown) {
        $c = switch ($x.Severity) { 'High' { '#b85450' } 'Medium' { '#d79b00' } default { '#6c8ebf' } }
        "<tr><td style='color:$c;font-weight:bold;padding-right:8px;vertical-align:top'>$($x.Severity)</td><td style='vertical-align:top;padding-right:8px'>$(HE $x.Id)<br>$(HE $x.Category)</td><td style='vertical-align:top'><b>$(HE $x.Title)</b><br>$(HE $x.Finding)</td></tr>"
    }
    $tbl = if ($shown.Count) { "<b>Findings ($($findings.Count))</b><table style='font-size:11px;margin-top:4px'>$($rows -join '')</table>" } else { '<b>Findings</b><br>No issues found.' }
    if ($findings.Count -gt $shown.Count) { $tbl += "<br><i>$($findings.Count - $shown.Count) more in the HTML report.</i>" }
    [void](Add-AdtdNode $p 'findings' $tbl 530 70 760 ([math]::Max(260, 40 + 34 * $shown.Count)) 'panel' $null $null)
    return $p
}

function Add-Legend {
    param($Page)
    $b = Get-Bounds $Page
    $x = [math]::Max(40, $b[0] + 60)
    $items = @(@('dc', 'Domain controller'), @('rodc', 'Read-only DC'), @('warn', 'Support ends within 12 months'), @('bad', 'Operating system out of support'))
    [void](Add-AdtdNode $Page 'legend' '<b>Legend</b>' $x 90 220 (40 + 36 * $items.Count) 'panel' $null $null)
    $y = 120
    foreach ($i in $items) { [void](Add-AdtdNode $Page "legend_$($i[0])" $i[1] ($x + 10) $y 200 28 $i[0] $null $null); $y += 36 }
}

function Get-GapKind {
    param([string]$Status)
    switch ($Status) { 'Present' { 'dc' } 'Partial' { 'warn' } 'Missing' { 'bad' } 'Not detectable' { 'external' } default { 'panel' } }
}

function New-AdtdHybridPage {
    <# Current state on the left, the identity bridge in the middle, Microsoft Entra ID on the right. #>
    param($Inventory)
    $p = New-AdtdPage 'Target hybrid topology'
    $plan = $Inventory.Plan
    $gaps = @{}; foreach ($g in @($plan.Gaps)) { $gaps[$g.Capability] = $g }
    $st = { param($cap) if ($gaps.ContainsKey($cap)) { $gaps[$cap].Status } else { 'Unknown' } }
    $kind = { param($cap) Get-GapKind (& $st $cap) }
    $h = if ($Inventory.Security) { Get-AdtdHybridState $Inventory } else { $null }
    [void](Add-AdtdNode $p 'title' "Target hybrid identity topology - $(HE $Inventory.Forest.Name)" 40 20 1100 36 'title' $null $null)

    $W = 300; $boxH = 64; $gap = 14
    $col = {
        param($id, $label, $x, $items)
        $h2 = 40 + $items.Count * ($boxH + $gap)
        [void](Add-AdtdNode $p $id $label $x 90 ($W + 28) $h2 'group' $null $null)
        $y = 40
        foreach ($i in $items) { [void](Add-AdtdNode $p $i[0] $i[1] 14 $y $W $boxH $i[2] $id $null); $y += $boxH + $gap }
    }
    $dcs = @($Inventory.DomainControllers)
    $bad = @($dcs | Where-Object { $_.OSSupportState -ne 'Supported' }).Count
    $onprem = @(
        , @('op_forest', "<b>Forest $(HE $Inventory.Forest.Name)</b><br>$(@($Inventory.Domains).Count) domain(s) &#183; level $(HE ($Inventory.Forest.FunctionalLevelName -replace 'Windows Server ', ''))", (& $kind 'Modern functional level'))
        , @('op_dcs', "<b>Domain controllers</b><br>$($dcs.Count) DC(s) in $(@($dcs | Group-Object Site).Count) site(s); $bad need replacing", $(if ($bad) { 'bad' } else { 'dc' }))
        , @('op_sysvol', "<b>SYSVOL replication</b><br>$(HE (& $st 'SYSVOL on DFS Replication')) ($(HE $gaps['SYSVOL on DFS Replication'].Evidence))", (& $kind 'SYSVOL on DFS Replication'))
        , @('op_laps', "<b>Local admin passwords</b><br>Windows LAPS: $(HE (& $st 'Windows LAPS'))", (& $kind 'Windows LAPS'))
        , @('op_pwd', "<b>Password protection on DCs</b><br>$(HE (& $st 'Entra Password Protection on DCs'))", (& $kind 'Entra Password Protection on DCs'))
    )
    if ($h -and $h.Adfs) { $onprem += , @('op_adfs', '<b>AD FS</b><br>Retire: move to password hash sync', 'warn') }
    if ($h -and $h.CertificateServices) { $onprem += , @('op_adcs', "<b>AD CS</b><br>$(HE $gaps['Certificate services'].Evidence)", $(if (@($Inventory.Security.Forest.RiskyTemplates).Count) { 'warn' } else { 'dc' })) }
    if ($Inventory.Exchange) { $onprem += , @('op_ex', "<b>Exchange on-premises</b><br>$(@($Inventory.Exchange.Servers).Count) server(s); target Exchange Online", $(if (@($Inventory.Exchange.Servers | Where-Object { -not $_.Supported }).Count) { 'bad' } else { 'warn' })) }
    & $col 'onprem' 'On-premises Active Directory (today)' 40 $onprem

    $syncLabel = if (-not $h) { '<b>Directory sync</b><br>Not scanned' } elseif ($h.CloudSync) { "<b>Microsoft Entra Cloud Sync</b><br>$(@($h.CloudSyncAgents).Count) agent account(s)" } elseif ($h.ConnectSync) { '<b>Microsoft Entra Connect Sync</b><br>Consider Cloud Sync (see X02)' } else { '<b>Directory sync: missing</b><br>Recommended: Microsoft Entra Cloud Sync' }
    $syncKind = if ($h -and ($h.CloudSync -or $h.ConnectSync)) { 'dc' } else { 'bad' }
    $bridge = @(
        , @('br_sync', $syncLabel, $syncKind)
        , @('br_upn', "<b>Routable UPNs</b><br>$(HE $gaps['Routable UPNs matching email'].Evidence)", (& $kind 'Routable UPNs matching email'))
        , @('br_join', "<b>Hybrid join (device SCP)</b><br>$(HE (& $st 'Microsoft Entra hybrid join'))", (& $kind 'Microsoft Entra hybrid join'))
        , @('br_krb', "<b>Microsoft Entra Kerberos</b><br>Cloud Kerberos trust: $(HE (& $st 'Microsoft Entra Kerberos (cloud Kerberos trust)'))", (& $kind 'Microsoft Entra Kerberos (cloud Kerberos trust)'))
        , @('br_mdi', '<b>Defender for Identity sensors</b><br>Verify: not visible in AD', 'external')
    )
    & $col 'bridge' 'Identity bridge' 440 $bridge

    $tenant = if ($h -and $h.TenantName) { HE $h.TenantName } else { 'your tenant' }
    $cloud = @(
        , @('cl_tenant', "<b>Microsoft Entra ID</b><br>$tenant", $(if ($h -and $h.TenantName) { 'dc' } else { 'external' }))
        , @('cl_auth', "<b>Cloud authentication</b><br>Password hash sync + Conditional Access + MFA$(if ($h -and $h.Adfs) { ' (after AD FS)' })", $(if ($h -and $h.Adfs) { 'warn' } else { 'external' }))
        , @('cl_whfb', '<b>Passwordless</b><br>Windows Hello for Business (cloud Kerberos trust), FIDO2', (& $kind 'Microsoft Entra Kerberos (cloud Kerberos trust)'))
        , @('cl_devices', '<b>Devices</b><br>Intune + Autopilot, Entra join for new PCs', 'external')
        , @('cl_apps', '<b>Apps</b><br>Entra app proxy / Private Access for on-premises apps', 'external')
        , @('cl_m365', "<b>Microsoft 365</b><br>$(if ($Inventory.Exchange) { 'Exchange Online (migrate mailboxes)' } else { 'Exchange Online, SharePoint, Teams' })", $(if ($Inventory.Exchange) { 'warn' } else { 'external' }))
    )
    & $col 'cloud' 'Microsoft Entra ID and Microsoft 365 (target)' 840 $cloud

    Add-AdtdEdge $p 'op_forest' 'br_sync' 'users, groups<br>password hashes' 'auto'
    Add-AdtdEdge $p 'br_sync' 'cl_tenant' '' 'auto'
    Add-AdtdEdge $p 'op_dcs' 'br_mdi' '' 'replica'
    Add-AdtdEdge $p 'br_krb' 'cl_whfb' '' 'replica'
    Add-AdtdEdge $p 'br_join' 'cl_devices' '' 'replica'
    if ($p.Index.ContainsKey('op_adfs')) { Add-AdtdEdge $p 'op_adfs' 'cl_auth' 'migrate (Staged Rollout)' 'manual' }
    if ($p.Index.ContainsKey('op_ex')) { Add-AdtdEdge $p 'op_ex' 'cl_m365' 'migrate mailboxes' 'manual' }

    $b = Get-Bounds $p
    $items = @(@('dc', 'In place'), @('warn', 'Needs work'), @('bad', 'Missing / recommended'), @('external', 'Target or not visible from AD'))
    [void](Add-AdtdNode $p 'legend' '<b>Legend</b>' 40 ($b[1] + 30) 900 60 'panel' $null $null)
    $x = 50; foreach ($i in $items) { [void](Add-AdtdNode $p "legend_$($i[0])" $i[1] $x ($b[1] + 56) 200 26 $i[0] $null $null); $x += 215 }
    return $p
}

function New-AdtdRoadmapPage {
    param($Inventory)
    $p = New-AdtdPage 'Upgrade roadmap'
    $plan = $Inventory.Plan
    [void](Add-AdtdNode $p 'title' "Suggested upgrade roadmap - $(HE $Inventory.Forest.Name)" 40 20 1100 36 'title' $null $null)
    $x = 40; $maxH = 0
    foreach ($ph in @($plan.Phases)) {
        $tasks = @($ph.Tasks)
        $shown = @($tasks | Select-Object -First 16)
        $label = "<b>Phase $($ph.Number): $(HE $ph.Name)</b><br><i>$(HE $ph.Goal)</i><br><br>" + (($shown | ForEach-Object { "&#9656; $(HE $_)" }) -join '<br>')
        if ($tasks.Count -gt $shown.Count) { $label += "<br><i>+ $($tasks.Count - $shown.Count) more in the report</i>" }
        $hgt = 90 + 30 * $shown.Count
        $kind = @('bad', 'warn', 'domain', 'dc')[$ph.Number - 1]
        [void](Add-AdtdNode $p "phase$($ph.Number)" $label $x 80 320 $hgt 'panel' $null $null)
        [void](Add-AdtdNode $p "phasebar$($ph.Number)" '' $x 70 320 10 $kind $null $null)
        if ($ph.Number -gt 1) { Add-AdtdEdge $p "phase$($ph.Number - 1)" "phase$($ph.Number)" '' 'auto' }
        $x += 360; $maxH = [math]::Max($maxH, $hgt)
    }
    $t = '<b>Suggested target topology</b><br>' + ((@($plan.Target) | ForEach-Object { "<b>$(HE $_.Area):</b> $(HE $_.Recommendation)" }) -join '<br>')
    [void](Add-AdtdNode $p 'target' $t 40 ($maxH + 120) 1400 (40 + 20 * @($plan.Target).Count) 'panel' $null $null)
    return $p
}

function New-AdtdDiagram {
    <# Builds the page list for the requested drawings. #>
    param($Inventory, [string[]]$Drawings = @('Summary', 'Sites', 'Replication', 'Domains'))
    $pages = @()
    if ($Drawings -contains 'Summary') { $pages += New-AdtdSummaryPage $Inventory }
    if ($Drawings -contains 'Sites') { $pages += New-AdtdSitesPage $Inventory }
    if ($Drawings -contains 'Replication') { $pages += New-AdtdReplicationPage $Inventory }
    if ($Drawings -contains 'Domains') { $pages += New-AdtdDomainsPage $Inventory }
    if ($Drawings -contains 'AppPartitions' -and @($Inventory.AppPartitions).Count) { $pages += New-AdtdAppPartitionsPage $Inventory }
    if ($Drawings -contains 'OUs' -and @($Inventory.OUs).Count) { $pages += New-AdtdOuPages $Inventory }
    if ($Drawings -contains 'Dfsr' -and @($Inventory.Dfsr).Count) { $pages += New-AdtdDfsrPage $Inventory }
    if ($Drawings -contains 'Exchange' -and $Inventory.Exchange) { $pages += New-AdtdExchangePage $Inventory }
    if ($Drawings -contains 'Hybrid' -and $Inventory.Plan) { $pages += New-AdtdHybridPage $Inventory; $pages += New-AdtdRoadmapPage $Inventory }
    return $pages
}

# ---------------------------------------------------------------- draw.io

function ConvertTo-XmlAttr { param([string]$s) return [System.Security.SecurityElement]::Escape("$s") }

function Export-AdtdDrawIo {
    param($Pages, [string]$Path)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("<mxfile host=`"ADTD Modern`" agent=`"ADTD Modern $script:AdtdVersion`" type=`"device`">`n")
    $pi = 0
    foreach ($p in $Pages) {
        $pi++
        $b = Get-Bounds $p
        [void]$sb.Append("  <diagram id=`"page$pi`" name=`"$(ConvertTo-XmlAttr $p.Name)`">`n")
        [void]$sb.Append("    <mxGraphModel dx=`"1400`" dy=`"900`" grid=`"1`" gridSize=`"10`" guides=`"1`" tooltips=`"1`" connect=`"1`" arrows=`"1`" fold=`"1`" page=`"0`" pageScale=`"1`" pageWidth=`"$([int]$b[0] + 80)`" pageHeight=`"$([int]$b[1] + 80)`" math=`"0`" shadow=`"0`">`n      <root>`n        <mxCell id=`"0`" />`n        <mxCell id=`"1`" parent=`"0`" />`n")
        foreach ($n in $p.Nodes) {
            $style = $script:NodeStyles[$n.Kind]
            $parent = if ($n.Parent) { $n.Parent } else { '1' }
            $tip = if ($n.Tooltip) { " tooltip=`"$(ConvertTo-XmlAttr $n.Tooltip)`"" } else { '' }
            if ($tip) {
                # Tooltips need the UserObject wrapper.
                [void]$sb.Append("        <UserObject id=`"$(ConvertTo-XmlAttr $n.Id)`" label=`"$(ConvertTo-XmlAttr $n.Label)`"$tip>`n          <mxCell style=`"$style`" vertex=`"1`" parent=`"$(ConvertTo-XmlAttr $parent)`">`n            <mxGeometry x=`"$($n.X)`" y=`"$($n.Y)`" width=`"$($n.W)`" height=`"$($n.H)`" as=`"geometry`" />`n          </mxCell>`n        </UserObject>`n")
            } else {
                [void]$sb.Append("        <mxCell id=`"$(ConvertTo-XmlAttr $n.Id)`" value=`"$(ConvertTo-XmlAttr $n.Label)`" style=`"$style`" vertex=`"1`" parent=`"$(ConvertTo-XmlAttr $parent)`">`n          <mxGeometry x=`"$($n.X)`" y=`"$($n.Y)`" width=`"$($n.W)`" height=`"$($n.H)`" as=`"geometry`" />`n        </mxCell>`n")
            }
        }
        foreach ($e in $p.Edges) {
            [void]$sb.Append("        <mxCell id=`"$($e.Id)`" value=`"$(ConvertTo-XmlAttr $e.Label)`" style=`"$($script:EdgeStyles[$e.Kind])`" edge=`"1`" parent=`"1`" source=`"$(ConvertTo-XmlAttr $e.Source)`" target=`"$(ConvertTo-XmlAttr $e.Target)`">`n          <mxGeometry relative=`"1`" as=`"geometry`" />`n        </mxCell>`n")
        }
        [void]$sb.Append("      </root>`n    </mxGraphModel>`n  </diagram>`n")
    }
    [void]$sb.Append("</mxfile>`n")
    [System.IO.File]::WriteAllText($Path, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    return $Path
}

# ---------------------------------------------------------------- Visio (COM)

function ConvertTo-PlainText {
    param([string]$Html)
    $t = $Html -replace '(?i)<br\s*/?>', "`n" -replace '(?i)</tr>', "`n" -replace '(?i)</td>', '  ' -replace '<[^>]+>', ''
    return [System.Net.WebUtility]::HtmlDecode($t).Trim()
}

function Export-AdtdVisio {
    <#
    Draws the pages in Microsoft Visio (desktop, any version from 2013) through COM and saves a .vsdx.
    Shapes are plain rectangles and dynamic connectors, so no stencils are needed.
    #>
    param($Pages, [string]$Path, [switch]$Visible)
    try { $visio = New-Object -ComObject Visio.InvisibleApp }
    catch {
        try { $visio = New-Object -ComObject Visio.Application }
        catch { throw 'Microsoft Visio is not installed on this computer. Open the .drawio file in draw.io instead (it can also export to .vsdx).' }
    }
    if ($Visible) { try { $visio.Visible = $true } catch { } }
    $scale = 96.0   # pixels per inch
    try {
        $doc = $visio.Documents.Add('')
        $first = $true
        foreach ($p in $Pages) {
            $vp = if ($first) { $doc.Pages.Item(1) } else { $doc.Pages.Add() }
            $first = $false
            $vp.Name = $p.Name
            $b = Get-Bounds $p
            $pw = ($b[0] + 80) / $scale; $ph = ($b[1] + 80) / $scale
            $vp.PageSheet.CellsU('PageWidth').FormulaU = "$pw in"
            $vp.PageSheet.CellsU('PageHeight').FormulaU = "$ph in"
            $shapes = @{}
            # Containers first so children sit on top.
            $ordered = @($p.Nodes | Where-Object { -not $_.Parent }) + @($p.Nodes | Where-Object { $_.Parent })
            foreach ($n in $ordered) {
                $ax = $n.X; $ay = $n.Y
                if ($n.Parent -and $p.Index.ContainsKey($n.Parent)) { $ax += $p.Index[$n.Parent].X; $ay += $p.Index[$n.Parent].Y }
                $x1 = $ax / $scale; $x2 = ($ax + $n.W) / $scale
                $y1 = $ph - ($ay + $n.H) / $scale; $y2 = $ph - $ay / $scale
                $s = $vp.DrawRectangle($x1, $y1, $x2, $y2)
                $s.Text = ConvertTo-PlainText $n.Label
                $s.CellsU('Char.Size').FormulaU = if ($n.Kind -eq 'title') { '16 pt' } elseif ($n.Kind -eq 'text') { '7 pt' } else { '8 pt' }
                $col = $script:VisioColors[$n.Kind]
                if ($col) {
                    $s.CellsU('FillForegnd').FormulaU = "THEMEGUARD(RGB($($col[0]),$($col[1]),$($col[2])))"
                    $s.CellsU('LineColor').FormulaU = "THEMEGUARD(RGB($($col[3]),$($col[4]),$($col[5])))"
                } else {
                    $s.CellsU('FillPattern').FormulaU = '0'
                    $s.CellsU('LinePattern').FormulaU = '0'
                }
                if ($n.Kind -in 'site', 'group', 'forest', 'domain', 'panel', 'ou', 'ouroot', 'text', 'title') {
                    $s.CellsU('VerticalAlign').FormulaU = '0'
                    $s.CellsU('Para.HorzAlign').FormulaU = '0'
                }
                if ($n.Kind -eq 'rodc' -or $n.Kind -eq 'external') { $s.CellsU('LinePattern').FormulaU = '2' }
                if ($n.Kind -eq 'hub') { $s.CellsU('Rounding').FormulaU = '0.5 in' } else { $s.CellsU('Rounding').FormulaU = '0.05 in' }
                if ($n.Tooltip) { $s.CellsU('Comment').FormulaU = '"' + ($n.Tooltip -replace '"', '""') + '"' }
                $shapes[$n.Id] = $s
            }
            foreach ($e in $p.Edges) {
                $a = $shapes[$e.Source]; $z = $shapes[$e.Target]
                if (-not $a -or -not $z) { continue }
                $c = $vp.Drop($visio.ConnectorToolDataObject, 0, 0)
                $c.CellsU('BeginX').GlueTo($a.CellsU('PinX'))
                $c.CellsU('EndX').GlueTo($z.CellsU('PinX'))
                if ($e.Label) { $c.Text = ConvertTo-PlainText $e.Label; $c.CellsU('Char.Size').FormulaU = '7 pt' }
                $style = $script:EdgeStyles[$e.Kind]
                $c.CellsU('EndArrow').FormulaU = if ($style -match 'endArrow=block') { '4' } else { '0' }
                $c.CellsU('BeginArrow').FormulaU = if ($style -match 'startArrow=block') { '4' } else { '0' }
                if ($style -match 'dashed=1') { $c.CellsU('LinePattern').FormulaU = '2' }
                if ($style -match 'strokeColor=#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})') {
                    $c.CellsU('LineColor').FormulaU = "THEMEGUARD(RGB($([Convert]::ToInt32($Matches[1],16)),$([Convert]::ToInt32($Matches[2],16)),$([Convert]::ToInt32($Matches[3],16))))"
                }
            }
        }
        $doc.SaveAs($Path) | Out-Null
        if (-not $Visible) { $doc.Close() }
    } finally {
        if (-not $Visible) { $visio.Quit() }
    }
    return $Path
}
