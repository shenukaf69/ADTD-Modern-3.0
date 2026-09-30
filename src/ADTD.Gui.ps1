# ADTD Modern - the window (Windows Forms): main window, About, and the first-run welcome
# with desktop shortcut and taskbar pinning. Loaded by ADTD.psm1; nothing here runs at import.

$script:AdtdAuthor = 'Shenuka Fernando'
$script:AdtdRepoUrl = 'https://github.com/shenukaf69/ADTD-Modern-3.0'
$script:AdtdAuthorUrl = 'https://github.com/shenukaf69'

function Initialize-AdtdGui {
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    if (-not $script:AdtdGuiReady) {
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $script:AdtdGuiReady = $true
    }
    $g = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero)
    $script:AdtdDpi = [math]::Max(1.0, $g.DpiX / 96.0)
    $g.Dispose()
    $script:AdtdTheme = @{
        Accent     = [System.Drawing.Color]::FromArgb(15, 108, 189)
        AccentDark = [System.Drawing.Color]::FromArgb(11, 61, 145)
        Back       = [System.Drawing.Color]::FromArgb(243, 246, 250)
        Card       = [System.Drawing.Color]::White
        Border     = [System.Drawing.Color]::FromArgb(222, 227, 234)
        Text       = [System.Drawing.Color]::FromArgb(32, 38, 46)
        Muted      = [System.Drawing.Color]::FromArgb(96, 106, 120)
        Good       = [System.Drawing.Color]::FromArgb(16, 124, 16)
        Bad        = [System.Drawing.Color]::FromArgb(196, 43, 28)
    }
}

function Get-AdtdPx([double]$Value) { [int][math]::Round($Value * $script:AdtdDpi) }

function Get-AdtdAppIcon {
    $ico = Join-Path $PSScriptRoot 'ADTD.ico'
    if (Test-Path $ico) { try { return New-Object System.Drawing.Icon($ico) } catch { } }
    return $null
}

function Get-AdtdAppImage([int]$Size) {
    $png = Join-Path $PSScriptRoot 'ADTD-64.png'
    if (-not (Test-Path $png)) { return $null }
    $src = [System.Drawing.Image]::FromFile($png)
    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'AntiAlias'
    $g.DrawImage($src, 0, 0, $Size, $Size)
    $g.Dispose(); $src.Dispose()
    return $bmp
}

function New-AdtdLabel {
    param([string]$Text, [double]$Size = 9.75, [string]$Style = 'Regular', $Color, [switch]$Wrap, [int]$WrapWidth = 440)
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $Text; $l.AutoSize = $true
    $l.Font = New-Object System.Drawing.Font('Segoe UI', $Size, [System.Drawing.FontStyle]$Style)
    $l.ForeColor = if ($Color) { $Color } else { $script:AdtdTheme.Text }
    $l.BackColor = [System.Drawing.Color]::Transparent
    $l.Margin = New-Object System.Windows.Forms.Padding(0, 2, 0, 2)
    if ($Wrap) { $l.MaximumSize = New-Object System.Drawing.Size((Get-AdtdPx $WrapWidth), 0) }
    return $l
}

function New-AdtdButton {
    param([string]$Text, [switch]$Primary, [int]$Width = 0)
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $Text; $b.AutoSize = $true; $b.FlatStyle = 'Flat'
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    $b.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 10), (Get-AdtdPx 3), (Get-AdtdPx 10), (Get-AdtdPx 3))
    $b.Margin = New-Object System.Windows.Forms.Padding(0, 2, (Get-AdtdPx 8), 2)
    if ($Width) { $b.MinimumSize = New-Object System.Drawing.Size((Get-AdtdPx $Width), 0) }
    if ($Primary) {
        $b.BackColor = $script:AdtdTheme.Accent; $b.ForeColor = [System.Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
        $b.FlatAppearance.MouseOverBackColor = $script:AdtdTheme.AccentDark
        $b.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5)
    } else {
        $b.BackColor = [System.Drawing.Color]::White; $b.ForeColor = $script:AdtdTheme.Text
        $b.FlatAppearance.BorderColor = $script:AdtdTheme.Border
        $b.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(235, 243, 252)
    }
    return $b
}

function New-AdtdTable {
    param([int]$Columns = 1, [switch]$Fill, [int]$Stretch = -1)
    $t = New-Object System.Windows.Forms.TableLayoutPanel
    $t.ColumnCount = $Columns; $t.AutoSize = $true; $t.AutoSizeMode = 'GrowAndShrink'
    $t.Dock = 'Fill'; $t.Margin = New-Object System.Windows.Forms.Padding(0)
    $t.BackColor = [System.Drawing.Color]::Transparent
    for ($i = 0; $i -lt $Columns; $i++) {
        if ($Fill -or $i -eq $Stretch -or ($Columns -eq 1 -and $Stretch -lt 0)) { [void]$t.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', (100 / $Columns)))) }
        else { [void]$t.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('AutoSize'))) }
    }
    return $t
}

function New-AdtdCard {
    <# A white "card" with a numbered heading. Returns @(card, body) - add controls to body. #>
    param([string]$Number, [string]$Title, [string]$Hint, [int]$WrapWidth = 440)
    $card = New-AdtdTable
    $card.BackColor = $script:AdtdTheme.Card
    $card.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 16), (Get-AdtdPx 12), (Get-AdtdPx 16), (Get-AdtdPx 14))
    $card.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, (Get-AdtdPx 12))
    $card.Add_Paint({ param($s, $e) $p = New-Object System.Drawing.Pen($script:AdtdTheme.Border); $e.Graphics.DrawRectangle($p, 0, 0, $s.Width - 1, $s.Height - 1); $p.Dispose() })
    $head = New-Object System.Windows.Forms.FlowLayoutPanel
    $head.AutoSize = $true; $head.WrapContents = $false; $head.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, (Get-AdtdPx 6))
    $num = New-AdtdLabel $Number 10 'Bold' ([System.Drawing.Color]::White)
    $num.BackColor = $script:AdtdTheme.Accent; $num.AutoSize = $false; $num.TextAlign = 'MiddleCenter'
    $num.Size = New-Object System.Drawing.Size((Get-AdtdPx 24), (Get-AdtdPx 24)); $num.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 8), 0)
    $head.Controls.Add($num)
    $head.Controls.Add((New-AdtdLabel $Title 12 'Bold'))
    $card.Controls.Add($head)
    if ($Hint) { $card.Controls.Add((New-AdtdLabel $Hint 9 -Color $script:AdtdTheme.Muted -Wrap -WrapWidth $WrapWidth)) }
    $body = New-AdtdTable
    $body.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 6), 0, 0)
    $card.Controls.Add($body)
    return @($card, $body)
}

function Get-AdtdInstallInfo {
    param([string]$HostPath)
    $exe = if ($HostPath -and (Test-Path $HostPath)) { $HostPath } else { Join-Path $PSScriptRoot 'ADTD.exe' }
    $docs = [Environment]::GetFolderPath('MyDocuments')
    $kind = if ($env:ProgramFiles -and $PSScriptRoot -like "$env:ProgramFiles\*") { 'All users (MSI)' }
    elseif ($docs -and $PSScriptRoot -like "$docs\*PowerShell\Modules\*") { 'Current user' }
    else { 'Not installed (running from a folder)' }
    [pscustomobject]@{
        Folder  = $PSScriptRoot
        Exe     = $(if (Test-Path $exe) { (Resolve-Path $exe).Path } else { $null })
        Kind    = $kind
        Desktop = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'ADTD Modern.lnk')
    }
}

function New-AdtdShortcut {
    <# Creates a .lnk that starts ADTD Modern with its own icon. #>
    param([Parameter(Mandatory)][string]$Path, [string]$HostPath)
    $info = Get-AdtdInstallInfo -HostPath $HostPath
    $sh = New-Object -ComObject WScript.Shell
    $lnk = $sh.CreateShortcut($Path)
    if ($info.Exe) {
        $lnk.TargetPath = $info.Exe
        $lnk.IconLocation = "$($info.Exe),0"
    } else {
        $lnk.TargetPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $lnk.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File `"$(Join-Path $info.Folder 'ADTD.ps1')`" -Gui"
        $ico = Join-Path $info.Folder 'ADTD.ico'
        if (Test-Path $ico) { $lnk.IconLocation = "$ico,0" }
    }
    $lnk.WorkingDirectory = $info.Folder
    $lnk.Description = 'ADTD Modern - Active Directory topology, security and hybrid Entra ID assessment'
    $lnk.Save()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($sh)
    return $Path
}

function Test-AdtdPinned {
    $dir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
    if (-not (Test-Path $dir)) { return $false }
    $sh = New-Object -ComObject WScript.Shell
    try {
        foreach ($f in Get-ChildItem $dir -Filter *.lnk) {
            $t = $sh.CreateShortcut($f.FullName).TargetPath
            if ($t -like '*\ADTD.exe' -or $f.BaseName -eq 'ADTD Modern') { return $true }
        }
    } finally { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($sh) }
    return $false
}

function Invoke-AdtdPinToTaskbar {
    <#
    Windows 10 (1809+) and 11 don't let programs pin themselves; older builds still accept the
    "taskbarpin" shell verb. Tries that first; returns $true if ADTD Modern ends up pinned.
    #>
    param([string]$HostPath)
    if (Test-AdtdPinned) { return $true }
    $info = Get-AdtdInstallInfo -HostPath $HostPath
    $target = if ($info.Exe) { $info.Exe } else { $null }
    if ($target) {
        try {
            $shell = New-Object -ComObject Shell.Application
            $item = $shell.Namespace((Split-Path $target -Parent)).ParseName((Split-Path $target -Leaf))
            $item.InvokeVerb('taskbarpin')
            Start-Sleep -Milliseconds 400
        } catch { }
    }
    return (Test-AdtdPinned)
}

function Show-AdtdPinHelp {
    param($Owner)
    $msg = "Windows only lets you pin apps yourself. It takes two clicks:`r`n`r`n" +
    "1. With ADTD Modern open, right-click its icon on the taskbar.`r`n" +
    "2. Choose 'Pin to taskbar'.`r`n`r`n" +
    "To pin it to Start: open Start, find ADTD Modern, right-click it and choose 'Pin to Start'."
    [void][System.Windows.Forms.MessageBox]::Show($Owner, $msg, 'Pin ADTD Modern to the taskbar', 'OK', 'Information')
}

function New-AdtdLink {
    param([string]$Text, [string]$Url)
    $l = New-Object System.Windows.Forms.LinkLabel
    $l.Text = $Text; $l.AutoSize = $true; $l.LinkColor = $script:AdtdTheme.Accent
    $l.Font = New-Object System.Drawing.Font('Segoe UI', 9.75)
    $l.Margin = New-Object System.Windows.Forms.Padding(0, 2, (Get-AdtdPx 12), 2)
    $l.Tag = $Url
    $l.Add_LinkClicked({ try { Start-Process $this.Tag } catch { } })
    return $l
}

function New-AdtdLocationRow {
    <# "Installed in <path>  [Open folder]" row, used by About and the welcome screen. #>
    param($Info)
    $t = New-AdtdTable 2 -Stretch 0
    $path = New-Object System.Windows.Forms.TextBox
    $path.Text = $Info.Folder; $path.ReadOnly = $true; $path.Dock = 'Fill'
    $path.BackColor = $script:AdtdTheme.Back; $path.BorderStyle = 'FixedSingle'
    $path.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 4), (Get-AdtdPx 8), 0)
    $open = New-AdtdButton 'Open folder'
    $open.Tag = $Info.Folder
    $open.Add_Click({ Start-Process explorer.exe "`"$($this.Tag)`"" })
    $t.Controls.Add($path, 0, 0); $t.Controls.Add($open, 1, 0)
    return $t
}

function New-AdtdDialog {
    param([string]$Title, [int]$Width = 560)
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Title; $f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false; $f.MinimizeBox = $false
    $f.StartPosition = 'CenterParent'; $f.BackColor = $script:AdtdTheme.Card
    $f.Font = New-Object System.Drawing.Font('Segoe UI', 9.75)
    $f.AutoSize = $true; $f.AutoSizeMode = 'GrowAndShrink'
    $f.MinimumSize = New-Object System.Drawing.Size((Get-AdtdPx $Width), 0)
    $icon = Get-AdtdAppIcon; if ($icon) { $f.Icon = $icon }
    $body = New-AdtdTable
    $body.Dock = 'None'; $body.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 22), (Get-AdtdPx 18), (Get-AdtdPx 22), (Get-AdtdPx 16))
    $body.MinimumSize = New-Object System.Drawing.Size((Get-AdtdPx ($Width - 20)), 0)
    $f.Controls.Add($body)
    return @($f, $body)
}

function New-AdtdTitleBlock {
    param([string]$Subtitle)
    $t = New-AdtdTable 2
    $pic = New-Object System.Windows.Forms.PictureBox
    $pic.Size = New-Object System.Drawing.Size((Get-AdtdPx 56), (Get-AdtdPx 56)); $pic.SizeMode = 'Zoom'
    $pic.Image = Get-AdtdAppImage (Get-AdtdPx 56)
    $pic.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 14), 0)
    $t.Controls.Add($pic, 0, 0)
    $col = New-AdtdTable
    $col.Controls.Add((New-AdtdLabel 'ADTD Modern' 18 'Bold' $script:AdtdTheme.AccentDark))
    $col.Controls.Add((New-AdtdLabel $Subtitle 9.75 -Color $script:AdtdTheme.Muted))
    $t.Controls.Add($col, 1, 0)
    $t.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, (Get-AdtdPx 12))
    return $t
}

function Show-AdtdAbout {
    <# About ADTD Modern: author, version, install location, shortcuts, notices. #>
    param($Owner, [string]$HostPath)
    Initialize-AdtdGui
    $f, $body = New-AdtdDialog 'About ADTD Modern' 580
    $info = Get-AdtdInstallInfo -HostPath $HostPath
    $body.Controls.Add((New-AdtdTitleBlock "Version $script:AdtdVersion  |  Active Directory Topology Diagrammer"))

    $body.Controls.Add((New-AdtdLabel "Designed and developed by $script:AdtdAuthor" 11 'Bold'))
    $body.Controls.Add((New-AdtdLabel ('Draws your Active Directory in draw.io and reports its health, security risks and readiness for ' +
                'Microsoft Entra ID hybrid identity, with a suggested target topology and upgrade roadmap. Read-only: it never changes Active Directory.') 9.75 -Wrap -WrapWidth 530))
    $links = New-Object System.Windows.Forms.FlowLayoutPanel
    $links.AutoSize = $true; $links.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 6), 0, (Get-AdtdPx 10))
    $links.Controls.Add((New-AdtdLink 'Project on GitHub' $script:AdtdRepoUrl))
    $links.Controls.Add((New-AdtdLink "$script:AdtdAuthor on GitHub" $script:AdtdAuthorUrl))
    $links.Controls.Add((New-AdtdLink 'Report an issue' "$script:AdtdRepoUrl/issues"))
    $body.Controls.Add($links)

    $body.Controls.Add((New-AdtdLabel 'Installed in' 9.75 'Bold'))
    $body.Controls.Add((New-AdtdLabel "$($info.Kind)" 9 -Color $script:AdtdTheme.Muted))
    $body.Controls.Add((New-AdtdLocationRow $info))

    $sc = New-Object System.Windows.Forms.FlowLayoutPanel
    $sc.AutoSize = $true; $sc.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 8), 0, (Get-AdtdPx 10))
    $desk = New-AdtdButton $(if (Test-Path $info.Desktop) { 'Remove desktop shortcut' } else { 'Add desktop shortcut' })
    # Handlers run inside ShowDialog below, so they see this function's variables ($HostPath).
    $desk.Add_Click({
            try {
                $i = Get-AdtdInstallInfo -HostPath $HostPath
                if (Test-Path $i.Desktop) { Remove-Item $i.Desktop -Force; $this.Text = 'Add desktop shortcut' }
                else { [void](New-AdtdShortcut -Path $i.Desktop -HostPath $HostPath); $this.Text = 'Remove desktop shortcut' }
            } catch { [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'ADTD Modern') }
        })
    $pin = New-AdtdButton $(if (Test-AdtdPinned) { 'Pinned to taskbar' } else { 'Pin to taskbar' })
    $pin.Add_Click({
            if (Invoke-AdtdPinToTaskbar -HostPath $HostPath) { $this.Text = 'Pinned to taskbar' } else { Show-AdtdPinHelp $this.FindForm() }
        })
    $sc.Controls.Add($desk); $sc.Controls.Add($pin)
    $body.Controls.Add($sc)

    $legal = New-Object System.Windows.Forms.TextBox
    $legal.Multiline = $true; $legal.ReadOnly = $true; $legal.ScrollBars = 'Vertical'; $legal.BorderStyle = 'FixedSingle'
    $legal.BackColor = $script:AdtdTheme.Back; $legal.Font = New-Object System.Drawing.Font('Segoe UI', 8.75)
    $legal.Size = New-Object System.Drawing.Size((Get-AdtdPx 530), (Get-AdtdPx 110))
    $legal.Text = (@(
            "Copyright (c) 2026 $script:AdtdAuthor. All rights reserved.",
            "ADTD Modern is an independent personal project by $script:AdtdAuthor. It is not a Microsoft product and is not endorsed or supported by Microsoft. It was inspired by Microsoft's Active Directory Topology Diagrammer (2011).",
            '',
            'Third-party software:',
            '- mxGraph 4.2.2 (c) JGraph Ltd, Apache License 2.0 - the offline diagram viewer in HTML reports (lib\mxgraph-LICENSE.txt).',
            '',
            'draw.io is a trademark of JGraph Ltd. Microsoft, Active Directory, Microsoft Entra, Exchange, Visio and Windows are trademarks of the Microsoft group of companies.'
        ) -join "`r`n")
    $legal.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, (Get-AdtdPx 12))
    $legal.TabStop = $false   # otherwise it gets focus, selects everything and opens scrolled to the end
    $body.Controls.Add($legal)

    $ok = New-AdtdButton 'Close' -Primary -Width 100
    $ok.DialogResult = 'OK'; $ok.Anchor = 'Right'
    $body.Controls.Add($ok)
    $f.AcceptButton = $ok; $f.CancelButton = $ok
    $f.ActiveControl = $ok
    $f.Add_Shown({ $legal.SelectionStart = 0; $legal.SelectionLength = 0; $legal.ScrollToCaret() })
    if (-not $Owner) { $f.StartPosition = 'CenterScreen' }
    [void]$f.ShowDialog($Owner)
    $f.Dispose()
}

function Show-AdtdWelcome {
    <#
    First-run screen: where ADTD Modern is installed, plus a desktop shortcut and taskbar pin.
    Returns 'Open' (Finish, open the app now), 'Close' (Finish only) or 'Cancel' (window closed).
    #>
    param($Owner, [string]$HostPath)
    Initialize-AdtdGui
    $f, $body = New-AdtdDialog 'ADTD Modern is ready' 560
    $info = Get-AdtdInstallInfo -HostPath $HostPath
    $body.Controls.Add((New-AdtdTitleBlock "Version $script:AdtdVersion  |  by $script:AdtdAuthor"))
    $body.Controls.Add((New-AdtdLabel 'ADTD Modern is installed.' 12 'Bold' $script:AdtdTheme.Good))
    $body.Controls.Add((New-AdtdLabel "Installed in ($($info.Kind.ToLower())):" 9.75 -Color $script:AdtdTheme.Muted))
    $body.Controls.Add((New-AdtdLocationRow $info))

    $body.Controls.Add((New-AdtdLabel 'Make it easy to find' 11 'Bold'))
    $cbDesk = New-Object System.Windows.Forms.CheckBox
    $cbDesk.Text = 'Add a shortcut to my desktop'; $cbDesk.AutoSize = $true; $cbDesk.Checked = $true
    if (Test-Path $info.Desktop) { $cbDesk.Text = 'Keep the shortcut on my desktop' }
    $cbPin = New-Object System.Windows.Forms.CheckBox
    $cbPin.Text = 'Pin to the taskbar'; $cbPin.AutoSize = $true; $cbPin.Checked = -not (Test-AdtdPinned)
    if (-not $cbPin.Checked) { $cbPin.Text = 'Pin to the taskbar (already pinned)'; $cbPin.Enabled = $false }
    $cbOpen = New-Object System.Windows.Forms.CheckBox
    $cbOpen.Text = 'Open ADTD Modern now'; $cbOpen.AutoSize = $true; $cbOpen.Checked = $true
    foreach ($c in $cbDesk, $cbPin, $cbOpen) { $c.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 2), (Get-AdtdPx 3), 0, (Get-AdtdPx 3)); $body.Controls.Add($c) }
    $body.Controls.Add((New-AdtdLabel 'The Start menu always has ADTD Modern, the Prerequisites checker and the Read me. You can change these later in About.' 9 -Color $script:AdtdTheme.Muted -Wrap -WrapWidth 500))

    $ok = New-AdtdButton 'Finish' -Primary -Width 110
    $ok.DialogResult = 'OK'; $ok.Anchor = 'Right'
    $ok.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 12), 0, 0)
    $body.Controls.Add($ok)
    $f.AcceptButton = $ok
    if (-not $Owner) { $f.StartPosition = 'CenterScreen' }
    # Opened by the installer, the window can start behind other windows; bring it to the front.
    $f.Add_Shown({ $this.TopMost = $true; $this.Activate(); $this.TopMost = $false })
    $result = $f.ShowDialog($Owner)
    $f.Dispose()
    [void](Set-AdtdSettings -WelcomeShown $script:AdtdVersion)
    if ($result -ne 'OK') { return 'Cancel' }

    try {
        if ($cbDesk.Checked) { [void](New-AdtdShortcut -Path $info.Desktop -HostPath $HostPath) }
        elseif (Test-Path $info.Desktop) { Remove-Item $info.Desktop -Force }
    } catch { [void][System.Windows.Forms.MessageBox]::Show("Could not create the desktop shortcut: $($_.Exception.Message)", 'ADTD Modern') }
    if ($cbPin.Enabled -and $cbPin.Checked -and -not (Invoke-AdtdPinToTaskbar -HostPath $HostPath)) { Show-AdtdPinHelp $Owner }
    if ($cbOpen.Checked) { return 'Open' } else { return 'Close' }
}

function Show-ADTD {
    <#
    .SYNOPSIS
    Opens the ADTD Modern window.
    .PARAMETER Welcome
    Shows the first-run screen (install location, desktop shortcut, pin to taskbar) first. The MSI runs this after install.
    .PARAMETER HostPath
    Path of ADTD.exe when the window is hosted by it (set by the launcher).
    #>
    [CmdletBinding()]
    param([switch]$Welcome, [string]$HostPath)
    Initialize-AdtdGui
    # Event handlers below run inside $form.ShowDialog(), while this function is still running,
    # so they can use its variables directly ($form, $log, $boxes, ...).
    $Theme = $script:AdtdTheme

    $installed = (Get-AdtdInstallInfo -HostPath $HostPath).Kind -notlike 'Not installed*'
    if ($Welcome -or ($installed -and [string](Get-AdtdSettings).WelcomeShown -ne $script:AdtdVersion)) {
        $answer = Show-AdtdWelcome -HostPath $HostPath
        if ($answer -eq 'Close' -or ($answer -eq 'Cancel' -and $Welcome)) { return }
        # Right after an MSI install this process can be elevated; start the app as the signed-in user instead.
        $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $exe = (Get-AdtdInstallInfo -HostPath $HostPath).Exe
        if ($Welcome -and $admin -and $exe -and $answer -eq 'Open') { Start-Process explorer.exe "`"$exe`""; return }
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "ADTD Modern $script:AdtdVersion"
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.75)
    $form.BackColor = $Theme.Back
    $form.StartPosition = 'CenterScreen'
    $area = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $form.Size = New-Object System.Drawing.Size([math]::Min((Get-AdtdPx 1040), $area.Width - 20), [math]::Min((Get-AdtdPx 790), $area.Height - 20))
    $form.MinimumSize = New-Object System.Drawing.Size([math]::Min((Get-AdtdPx 900), $area.Width - 20), [math]::Min((Get-AdtdPx 520), $area.Height - 20))
    $icon = Get-AdtdAppIcon; if ($icon) { $form.Icon = $icon }
    $tips = New-Object System.Windows.Forms.ToolTip

    # ---- header: gradient banner with the app icon, About and Prerequisites ------------------------
    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = 'Top'; $header.Height = Get-AdtdPx 78
    $grad = New-Object System.Drawing.Bitmap(400, 40)
    $gg = [System.Drawing.Graphics]::FromImage($grad)
    $gb = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(0, 0, 400, 40)), $Theme.AccentDark, $Theme.Accent, 0.0)
    $gg.FillRectangle($gb, 0, 0, 400, 40); $gb.Dispose(); $gg.Dispose()
    $header.BackgroundImage = $grad; $header.BackgroundImageLayout = 'Stretch'
    $hl = New-AdtdTable 3 -Stretch 1
    $hl.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 18), (Get-AdtdPx 11), (Get-AdtdPx 14), 0)
    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Size = New-Object System.Drawing.Size((Get-AdtdPx 52), (Get-AdtdPx 52)); $logo.SizeMode = 'Zoom'
    $logo.Image = Get-AdtdAppImage (Get-AdtdPx 52); $logo.BackColor = [System.Drawing.Color]::Transparent
    $logo.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 12), 0)
    $titles = New-AdtdTable
    $titles.Controls.Add((New-AdtdLabel 'ADTD Modern' 17 'Bold' ([System.Drawing.Color]::White)))
    $titles.Controls.Add((New-AdtdLabel "Active Directory topology, security and Entra ID hybrid assessment  |  v$script:AdtdVersion" 9 -Color ([System.Drawing.Color]::FromArgb(214, 228, 245))))
    $hb = New-Object System.Windows.Forms.FlowLayoutPanel
    $hb.AutoSize = $true; $hb.WrapContents = $false; $hb.BackColor = [System.Drawing.Color]::Transparent
    $hb.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 12), 0, 0)
    $mkHead = {
        param($Text, $Tip)
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $Text; $b.AutoSize = $true; $b.FlatStyle = 'Flat'; $b.Cursor = [System.Windows.Forms.Cursors]::Hand
        $b.ForeColor = [System.Drawing.Color]::White; $b.BackColor = [System.Drawing.Color]::Transparent
        $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(150, 190, 235)
        $b.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60, 255, 255, 255)
        $b.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(90, 255, 255, 255)
        $b.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 8), (Get-AdtdPx 2), (Get-AdtdPx 8), (Get-AdtdPx 2))
        $b.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 6), 0, 0, 0)
        $tips.SetToolTip($b, $Tip)
        $hb.Controls.Add($b)
        $b
    }
    $preBtn = & $mkHead 'Prerequisites' 'Check and install draw.io desktop, PowerShell 7 and optional Visio'
    $aboutBtn = & $mkHead 'About' 'Version, author, install location, desktop shortcut and taskbar pin'
    $hl.Controls.Add($logo, 0, 0); $hl.Controls.Add($titles, 1, 0); $hl.Controls.Add($hb, 2, 0)
    $header.Controls.Add($hl)

    # ---- body: two columns of cards ---------------------------------------------------------------
    # The cards sit in a scrolling panel, so nothing is hidden when the window or screen is small.
    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock = 'Fill'; $scroll.AutoScroll = $true
    $body = New-AdtdTable 2 -Fill
    $body.Dock = 'Top'
    $body.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 16), (Get-AdtdPx 14), (Get-AdtdPx 16), (Get-AdtdPx 4))
    $scroll.Controls.Add($body)
    $left = New-AdtdTable; $left.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 6), 0)
    $right = New-AdtdTable; $right.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 6), 0, 0, 0)
    $body.Controls.Add($left, 0, 0); $body.Controls.Add($right, 1, 0)

    # 1. Connection
    $c1, $b1 = New-AdtdCard '1' 'Connect to Active Directory' 'ADTD only reads Active Directory. A normal domain user account is enough.'
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $dom = if ($env:USERDNSDOMAIN) { $env:USERDNSDOMAIN.ToLower() } else { 'the domain this computer is in' }
    $b1.Controls.Add((New-AdtdLabel 'Domain or domain controller' 9.75 'Bold'))
    $server = New-Object System.Windows.Forms.TextBox
    $server.Dock = 'Fill'; $server.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 2), 0, 0)
    $tips.SetToolTip($server, 'Examples: contoso.com  or  dc01.contoso.com')
    $b1.Controls.Add($server)
    $b1.Controls.Add((New-AdtdLabel "Leave empty to use $dom, or type a domain (contoso.com) or a domain controller (dc01.contoso.com)." 8.75 -Color $Theme.Muted -Wrap))

    $signIn = New-AdtdLabel 'Sign in as' 9.75 'Bold'; $signIn.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 8), 0, 0)
    $b1.Controls.Add($signIn)
    $rbMe = New-Object System.Windows.Forms.RadioButton
    $rbMe.Text = "My Windows account ($me)"; $rbMe.AutoSize = $true; $rbMe.Checked = $true
    $rbOther = New-Object System.Windows.Forms.RadioButton
    $rbOther.Text = 'A different account'; $rbOther.AutoSize = $true
    $tips.SetToolTip($rbOther, 'For another domain or forest, or when this computer is not domain-joined.')
    foreach ($r in $rbMe, $rbOther) { $r.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 2), (Get-AdtdPx 2), 0, 0); $b1.Controls.Add($r) }

    $cred = New-AdtdTable 2 -Stretch 1
    $cred.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 22), (Get-AdtdPx 2), 0, 0)
    $lu = New-AdtdLabel 'User name' 9.75
    $user = New-Object System.Windows.Forms.TextBox; $user.Dock = 'Fill'
    $lp = New-AdtdLabel 'Password' 9.75
    $pass = New-Object System.Windows.Forms.TextBox; $pass.Dock = 'Fill'; $pass.UseSystemPasswordChar = $true
    foreach ($l in $lu, $lp) { $l.Anchor = 'Left'; $l.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 10), 0) }
    foreach ($tb in $user, $pass) { $tb.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 2), 0, (Get-AdtdPx 2)) }
    $credHint = New-AdtdLabel 'CONTOSO\jane or jane@contoso.com. Used for this run only; never saved.' 8.75 -Color $Theme.Muted -Wrap -WrapWidth 360
    $cred.Controls.Add($lu, 0, 0); $cred.Controls.Add($user, 1, 0)
    $cred.Controls.Add($lp, 0, 1); $cred.Controls.Add($pass, 1, 1)
    $cred.Controls.Add($credHint, 1, 2)
    $b1.Controls.Add($cred)

    $testRow = New-AdtdTable 2 -Stretch 1
    $testRow.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 8), 0, 0)
    $testBtn = New-AdtdButton 'Test connection'
    $testRes = New-AdtdLabel '' 9 -Wrap -WrapWidth 300; $testRes.Anchor = 'Left'
    $testRow.Controls.Add($testBtn, 0, 0); $testRow.Controls.Add($testRes, 1, 0)
    $b1.Controls.Add($testRow)
    $setCred = {
        $on = $rbOther.Checked
        foreach ($c in $user, $pass, $lu, $lp, $credHint) { $c.Enabled = $on }
        $testRes.Text = ''
        if ($on) { [void]$user.Focus() }
    }
    $rbOther.Add_CheckedChanged($setCred); & $setCred
    $left.Controls.Add($c1)

    # 3. Output (left column, under the connection)
    $c3, $b3 = New-AdtdCard '3' 'Save the results' 'Hover over a format to see what it contains.'
    $fg = New-AdtdTable 3 -Fill
    $fmt = [ordered]@{}
    foreach ($k in @(
            @('DrawIo', 'draw.io drawing', $true, 'Editable .drawio file for draw.io desktop or draw.io on the web'),
            @('Html', 'HTML report', $true, 'Single-page assessment report'),
            @('HtmlTabs', 'Tabbed HTML', $false, 'One HTML file with tabs: summary, findings, diagrams, hybrid plan and inventory. Diagrams work offline.'),
            @('Markdown', 'Markdown', $false, 'One report per finding, plus an index and the hybrid plan'),
            @('Csv', 'CSV', $false, 'Findings, gap analysis, roadmap and inventory tables for Excel'),
            @('Json', 'JSON', $true, 'Inventory, to redraw or re-assess later with -InputFile'),
            @('Visio', 'Visio (.vsdx)', $false, 'Needs Visio desktop on this computer'))) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $k[1]; $cb.AutoSize = $true; $cb.Checked = $k[2]
        $cb.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 2), (Get-AdtdPx 2), (Get-AdtdPx 6), (Get-AdtdPx 2))
        $tips.SetToolTip($cb, $k[3])
        $fg.Controls.Add($cb); $fmt[$k[0]] = $cb
    }
    $b3.Controls.Add($fg)

    $rows = New-AdtdTable 3 -Stretch 1
    $rows.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 8), 0, 0)
    $l1 = New-AdtdLabel 'Save to' 9.75 'Bold'
    $folder = New-Object System.Windows.Forms.TextBox; $folder.Dock = 'Fill'
    $folder.Text = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'ADTD'
    $browse = New-AdtdButton 'Browse...'
    $browse.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 2), 0, (Get-AdtdPx 2))
    $l2 = New-AdtdLabel 'Open in' 9.75 'Bold'
    $viewer = New-Object System.Windows.Forms.ComboBox
    $viewer.DropDownStyle = 'DropDownList'; $viewer.Dock = 'Fill'
    [void]$viewer.Items.AddRange(@('Auto (draw.io desktop if installed, else web)', 'draw.io desktop', 'draw.io on the web'))
    $vi = @{ Auto = 0; Desktop = 1; Web = 2 }[[string](Get-AdtdSettings).DrawIoViewer]
    $viewer.SelectedIndex = if ($null -ne $vi) { $vi } else { 0 }
    foreach ($l in $l1, $l2) { $l.Anchor = 'Left'; $l.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 12), 0) }
    foreach ($c in $folder, $viewer) { $c.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 5), (Get-AdtdPx 8), (Get-AdtdPx 3)) }
    $rows.Controls.Add($l1, 0, 0); $rows.Controls.Add($folder, 1, 0); $rows.Controls.Add($browse, 2, 0)
    $rows.Controls.Add($l2, 0, 1); $rows.Controls.Add($viewer, 1, 1)
    $rows.SetColumnSpan($viewer, 2)
    $b3.Controls.Add($rows)

    $openCb = New-Object System.Windows.Forms.CheckBox
    $openCb.Text = 'Open the results when done'; $openCb.Checked = $true; $openCb.AutoSize = $true
    $offCb = New-Object System.Windows.Forms.CheckBox
    $offCb.Text = 'No internet on this computer (offline mode)'; $offCb.AutoSize = $true
    $tips.SetToolTip($offCb, 'Leaves out draw.io web links and opens drawings in draw.io desktop. Reports still show the diagrams.')
    foreach ($c in $openCb, $offCb) { $c.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 2), (Get-AdtdPx 4), 0, 0); $b3.Controls.Add($c) }
    $left.Controls.Add($c3)

    # 2. Drawings (right column)
    $c2, $b2 = New-AdtdCard '2' 'Choose what to draw' 'Each drawing becomes a page in the draw.io file. The assessment adds findings, security risks and the Entra ID hybrid plan to the reports.'
    $boxes = [ordered]@{}
    $labels = [ordered]@{ Summary = 'Summary and findings'; Sites = 'Sites, subnets and site links'; Replication = 'Replication connections'; Domains = 'Domains, trusts and FSMO roles'; Hybrid = 'Hybrid Entra ID topology and roadmap'
        AppPartitions = 'Application partitions'; OUs = 'OUs and GPO links'; Dfsr = 'DFS Replication groups'; Exchange = 'Exchange organization'; Security = 'Security and hybrid assessment' }
    $recommended = 'Summary', 'Sites', 'Replication', 'Domains', 'Hybrid', 'Security'
    foreach ($k in $labels.Keys) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $labels[$k]; $cb.AutoSize = $true; $cb.Checked = $k -in $recommended
        $cb.Margin = New-Object System.Windows.Forms.Padding((Get-AdtdPx 2), (Get-AdtdPx 1), 0, (Get-AdtdPx 1))
        $b2.Controls.Add($cb); $boxes[$k] = $cb
    }
    $tips.SetToolTip($boxes.Security, 'Health, security and Entra ID hybrid-readiness checks. Reads every user and computer once; untick for a quick topology-only run.')
    $sel = New-Object System.Windows.Forms.FlowLayoutPanel
    $sel.AutoSize = $true; $sel.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 6), 0, 0)
    $links = foreach ($linkText in 'Select all', 'Recommended', 'Clear') {
        $ln = New-Object System.Windows.Forms.LinkLabel
        $ln.Text = $linkText; $ln.AutoSize = $true; $ln.LinkColor = $Theme.Accent
        $ln.Margin = New-Object System.Windows.Forms.Padding(0, 0, (Get-AdtdPx 14), 0)
        $sel.Controls.Add($ln); $ln
    }
    $lnAll, $lnRec, $lnNone = $links
    $b2.Controls.Add($sel)
    $right.Controls.Add($c2)

    # 4. Activity (right column)
    $c4, $b4 = New-AdtdCard '4' 'Activity' ''
    $log = New-Object System.Windows.Forms.TextBox
    $log.Multiline = $true; $log.ScrollBars = 'Vertical'; $log.ReadOnly = $true; $log.BorderStyle = 'None'
    $log.BackColor = $Theme.Back; $log.Font = New-Object System.Drawing.Font('Consolas', 9)
    $log.Dock = 'Fill'; $log.MinimumSize = New-Object System.Drawing.Size(0, (Get-AdtdPx 150))
    $log.Text = "Ready. Choose the options, then click 'Draw my Active Directory'."
    $b4.Controls.Add($log)
    $right.Controls.Add($c4)
    # Activity takes the rest of the right column, and the log fills the card.
    foreach ($tbl in $right, $c4) {
        $tbl.RowStyles.Clear()
        for ($i = 0; $i -lt $tbl.Controls.Count; $i++) {
            $style = if ($i -eq $tbl.Controls.Count - 1) { New-Object System.Windows.Forms.RowStyle('Percent', 100) } else { New-Object System.Windows.Forms.RowStyle('AutoSize') }
            [void]$tbl.RowStyles.Add($style)
        }
    }
    [void]$b4.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))

    # ---- action bar and status bar ----------------------------------------------------------------
    $bar = New-Object System.Windows.Forms.Panel
    $bar.Dock = 'Bottom'; $bar.Height = Get-AdtdPx 64; $bar.BackColor = $Theme.Card
    $bar.Add_Paint({ param($s, $e) $p = New-Object System.Drawing.Pen($script:AdtdTheme.Border); $e.Graphics.DrawLine($p, 0, 0, $s.Width, 0); $p.Dispose() })
    $bl = New-AdtdTable 3 -Stretch 0
    $bl.Padding = New-Object System.Windows.Forms.Padding((Get-AdtdPx 16), (Get-AdtdPx 12), (Get-AdtdPx 16), 0)
    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Style = 'Marquee'; $progress.MarqueeAnimationSpeed = 0; $progress.Visible = $false
    $progress.Dock = 'Fill'; $progress.Margin = New-Object System.Windows.Forms.Padding(0, (Get-AdtdPx 10), (Get-AdtdPx 16), (Get-AdtdPx 10))
    $openOut = New-AdtdButton 'Open output folder'
    $run = New-AdtdButton 'Draw my Active Directory' -Primary
    $run.Margin = New-Object System.Windows.Forms.Padding(0)
    $bl.Controls.Add($progress, 0, 0); $bl.Controls.Add($openOut, 1, 0); $bl.Controls.Add($run, 2, 0)
    $bar.Controls.Add($bl)

    $status = New-Object System.Windows.Forms.StatusStrip
    $status.BackColor = $Theme.Back
    $st1 = New-Object System.Windows.Forms.ToolStripStatusLabel
    $st1.Text = 'Ready'; $st1.Spring = $true; $st1.TextAlign = 'MiddleLeft'
    $st2 = New-Object System.Windows.Forms.ToolStripStatusLabel
    $st2.Text = "Signed in as $me"; $st2.ForeColor = $Theme.Muted
    $st3 = New-Object System.Windows.Forms.ToolStripStatusLabel
    $st3.Text = "  by $script:AdtdAuthor"; $st3.ForeColor = $Theme.Muted
    [void]$status.Items.AddRange(@($st1, $st2, $st3))

    $form.Controls.Add($scroll); $form.Controls.Add($bar); $form.Controls.Add($status); $form.Controls.Add($header)
    $scroll.BringToFront()
    $form.AcceptButton = $run

    # ---- behaviour ---------------------------------------------------------------------------------
    $getCred = {
        if (-not $rbOther.Checked) { return $null }
        $u = $user.Text.Trim()
        if (-not $u) { throw "Type the user name of the other account (for example CONTOSO\jane), or choose 'My Windows account'." }
        if (-not $pass.Text) { throw "Type the password for $u." }
        $sec = New-Object System.Security.SecureString
        foreach ($ch in $pass.Text.ToCharArray()) { $sec.AppendChar($ch) }
        $sec.MakeReadOnly()
        New-Object System.Management.Automation.PSCredential($u, $sec)
    }
    $lnAll.Add_LinkClicked({ foreach ($b in $boxes.Values) { $b.Checked = $true } })
    $lnRec.Add_LinkClicked({ foreach ($k in @($boxes.Keys)) { $boxes[$k].Checked = $k -in $recommended } })
    $lnNone.Add_LinkClicked({ foreach ($b in $boxes.Values) { $b.Checked = $false } })
    $browse.Add_Click({
            $d = New-Object System.Windows.Forms.FolderBrowserDialog
            $d.SelectedPath = $folder.Text
            if ($d.ShowDialog($form) -eq 'OK') { $folder.Text = $d.SelectedPath }
        })
    $preBtn.Add_Click({
            $script = @((Join-Path $PSScriptRoot 'Install-Prerequisites.ps1'), (Join-Path $PSScriptRoot '..\setup\Install-Prerequisites.ps1')) | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($script) { Start-Process powershell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$script`"" }
            else { [void][System.Windows.Forms.MessageBox]::Show($form, 'Install-Prerequisites.ps1 was not found next to ADTD.', 'ADTD Modern') }
        })
    $aboutBtn.Add_Click({ Show-AdtdAbout -Owner $form -HostPath $HostPath })
    $openOut.Add_Click({
            New-Item -ItemType Directory -Path $folder.Text -Force | Out-Null
            Start-Process explorer.exe "`"$($folder.Text)`""
        })
    $testBtn.Add_Click({
            $testRes.Text = 'Connecting...'; $testRes.ForeColor = $Theme.Muted
            $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
            [System.Windows.Forms.Application]::DoEvents()
            try {
                $r = Test-AdtdConnection -Server $server.Text.Trim() -Credential (& $getCred)
                $testRes.Text = "Connected to $($r.Domain) ($($r.DomainController)) as $($r.Account)"
                $testRes.ForeColor = $Theme.Good
            } catch {
                $testRes.Text = "Could not connect: $($_.Exception.Message)"
                $testRes.ForeColor = $Theme.Bad
            } finally { $form.Cursor = [System.Windows.Forms.Cursors]::Default }
        })

    $script:AdtdLogSink = {
        param($line)
        $log.AppendText([Environment]::NewLine + $line)
        $st1.Text = $line -replace '^\S+\s+\S+\s+', ''
        [System.Windows.Forms.Application]::DoEvents()
    }
    $run.Add_Click({
            $run.Enabled = $false; $log.Text = 'Starting...'
            $st1.ForeColor = $Theme.Text
            $progress.Visible = $true; $progress.MarqueeAnimationSpeed = 30
            $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
            try {
                $sel = @($boxes.Keys | Where-Object { $_ -ne 'Security' -and $boxes[$_].Checked })
                $fmts = @($fmt.Keys | Where-Object { $fmt[$_].Checked })
                if (-not $sel.Count) { throw 'Choose at least one drawing in step 2.' }
                if (-not $fmts.Count) { throw 'Choose at least one format in step 3.' }
                $p = @{ Drawings = $sel; Format = $fmts; OutputFolder = $folder.Text; Open = $openCb.Checked
                    SkipSecurityScan = -not $boxes.Security.Checked; DrawIoViewer = @('Auto', 'Desktop', 'Web')[$viewer.SelectedIndex]; Offline = $offCb.Checked
                }
                [void](Set-AdtdSettings -DrawIoViewer $p.DrawIoViewer)
                if ($server.Text.Trim()) { $p.Server = $server.Text.Trim() }
                $c = & $getCred
                if ($c) { $p.Credential = $c }
                $r = Invoke-ADTD @p
                $done = "Done: $($r.DomainControllers) domain controllers in $($r.Sites) sites, $($r.Findings) findings ($($r.High) high)."
                & $script:AdtdLogSink $done
                & $script:AdtdLogSink 'Finished successfully.'
                $st1.Text = 'Finished successfully.'; $st1.ForeColor = $Theme.Good
                $msg = "ADTD finished successfully.`r`n`r`n$($done -replace '^Done: ', '')`r`n`r`nResults are saved in:`r`n$($folder.Text)"
                [void][System.Windows.Forms.MessageBox]::Show($form, $msg, 'ADTD Modern', 'OK', 'Information')
            } catch {
                & $script:AdtdLogSink "ERROR: $($_.Exception.Message)"
                $st1.Text = 'Stopped with an error. See Activity.'; $st1.ForeColor = $Theme.Bad
                [void][System.Windows.Forms.MessageBox]::Show($form, $_.Exception.Message, 'ADTD Modern', 'OK', 'Error')
            } finally {
                $progress.MarqueeAnimationSpeed = 0; $progress.Visible = $false
                $form.Cursor = [System.Windows.Forms.Cursors]::Default
                $run.Enabled = $true
            }
        })

    [void]$form.ShowDialog()
    $script:AdtdLogSink = $null
    $pass.Text = ''
    $form.Dispose()
}

function Test-AdtdConnection {
    <#
    .SYNOPSIS
    Checks that ADTD can read Active Directory with the given server and account.
    #>
    [CmdletBinding()]
    param([string]$Server, [pscredential]$Credential)
    $oldServer = $script:AdtdServer; $oldCred = $script:AdtdCredential
    try {
        $script:AdtdServer = if ($Server) { $Server } else { $null }
        $script:AdtdCredential = $Credential
        $root = Get-AdtdRootDse
        # RootDSE can be read anonymously, so bind to the domain to check the account too.
        $nc = $root['defaultnamingcontext']
        $path = if ($Server) { "LDAP://$Server/$nc" } else { "LDAP://$nc" }
        $e = New-AdtdDirectoryEntry $path
        try { $e.RefreshCache([string[]]@('name')) } finally { $e.Dispose() }
        [pscustomobject]@{
            Domain           = ($nc -replace '^DC=', '' -replace ',DC=', '.')
            DomainController = $root['dnshostname']
            Account          = $(if ($Credential) { $Credential.UserName } else { [Security.Principal.WindowsIdentity]::GetCurrent().Name })
        }
    } finally { $script:AdtdServer = $oldServer; $script:AdtdCredential = $oldCred }
}
