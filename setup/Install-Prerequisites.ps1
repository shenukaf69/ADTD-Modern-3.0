<#
.SYNOPSIS
Checks and installs what ADTD Modern needs: draw.io (desktop or web), PowerShell 7 (optional) and Visio (optional).

.DESCRIPTION
Run it with no parameters for a status report and a menu. Or use switches:

  -DrawIoDesktop   Install the free draw.io desktop app: from a local installer file if one is found
                   (-DrawIoInstaller, or a draw.io-*.exe / .msi in the package's drawio folder), else winget,
                   else the official installer from GitHub. Offline computers: use a local installer file.
  -DrawIoWeb       Use draw.io on the web (app.diagrams.net) instead: nothing to install. Checks it is reachable.
  -PowerShell7     Install PowerShell 7 (optional; Windows PowerShell 5.1 is enough).
  -Visio           Install Visio desktop with Microsoft's Office Deployment Tool (optional; you need a Visio licence).
                   -VisioEdition Plan2 (subscription, default), Professional2024 or Standard2024 (volume licence).
  -CheckOnly       Only show the status report.
  -Quiet           No prompts.

ADTD only needs a Windows computer that can reach a domain controller. draw.io (free) shows the drawings;
Visio is only needed if you want ADTD to draw straight into Visio.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\Install-Prerequisites.ps1
.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\Install-Prerequisites.ps1 -DrawIoDesktop -Quiet
.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\Install-Prerequisites.ps1 -DrawIoWeb
.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\Install-Prerequisites.ps1 -Visio -VisioEdition Professional2024
#>
[CmdletBinding()]
param(
    [switch]$DrawIoDesktop,
    [string]$DrawIoInstaller,
    [switch]$DrawIoWeb,
    [switch]$PowerShell7,
    [switch]$Visio,
    [ValidateSet('Plan2', 'Professional2024', 'Standard2024')]
    [string]$VisioEdition = 'Plan2',
    [string]$VisioProductKey,
    [switch]$CheckOnly,
    [switch]$Quiet
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }

function Test-Admin {
    try { return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { return $false }
}
function Find-DrawIo {
    foreach ($c in @((Join-Path "$env:ProgramFiles" 'draw.io\draw.io.exe'), (Join-Path "$env:LOCALAPPDATA" 'Programs\draw.io\draw.io.exe'), (Join-Path "${env:ProgramFiles(x86)}" 'draw.io\draw.io.exe'))) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    return $null
}
function Get-OfficeC2R {
    try { return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' -ErrorAction Stop } catch { return $null }
}
function Find-Visio {
    $c2r = Get-OfficeC2R
    if ($c2r -and "$($c2r.ProductReleaseIds)" -match 'Visio') { return "Click-to-Run: $(($c2r.ProductReleaseIds -split ',' | Where-Object { $_ -match 'Visio' }) -join ', ')" }
    try { if ([type]::GetTypeFromProgID('Visio.Application')) { return 'Installed (COM registered)' } } catch { }
    return $null
}
function Test-Port([string]$HostName, [int]$Port) {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $t = $c.BeginConnect($HostName, $Port, $null, $null)
        $ok = $t.AsyncWaitHandle.WaitOne(3000) -and $c.Connected
        $c.Close(); return $ok
    } catch { return $false }
}
function Test-Url([string]$Url) {
    try { $r = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 10; return $r.StatusCode -lt 400 } catch { return $false }
}
function Set-Viewer([string]$Viewer) {
    $dir = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'ADTD'
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $file = Join-Path $dir 'settings.json'
    $s = [ordered]@{ DrawIoViewer = $Viewer }
    try { if (Test-Path $file) { $j = Get-Content -Raw $file | ConvertFrom-Json; foreach ($p in $j.PSObject.Properties) { if ($p.Name -ne 'DrawIoViewer') { $s[$p.Name] = $p.Value } } } } catch { }
    $s | ConvertTo-Json | Set-Content -Path $file -Encoding UTF8
    Write-Host "ADTD will open drawings in: draw.io $(if ($Viewer -eq 'Web') { 'on the web' } elseif ($Viewer -eq 'Desktop') { 'desktop' } else { 'desktop if installed, otherwise on the web' })" -ForegroundColor Green
}
function Get-Winget { Get-Command winget.exe -ErrorAction SilentlyContinue }

function Show-Status {
    $rows = New-Object System.Collections.ArrayList
    $add = { param($item, $state, $note) [void]$rows.Add([pscustomobject]@{ Item = $item; Status = $state; Notes = $note }) }
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    & $add 'Windows' $(if ([Environment]::Is64BitOperatingSystem) { 'OK' } else { 'Needs 64-bit' }) "$($os.Caption) build $($os.BuildNumber)"
    & $add 'Windows PowerShell 5.1' $(if ($PSVersionTable.PSVersion.Major -ge 5) { 'OK' } else { 'Missing' }) "Running $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion)"
    $pwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    & $add 'PowerShell 7 (optional)' $(if ($pwsh) { 'OK' } else { 'Not installed' }) $(if ($pwsh) { $pwsh.Source } else { 'Optional. Install with -PowerShell7' })
    $domain = $null; $dc = $null
    try { $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain(); $dc = $domain.FindDomainController().Name } catch { }
    & $add 'Domain membership' $(if ($domain) { 'OK' } else { 'Not joined' }) $(if ($domain) { "$($domain.Name), DC $dc" } else { 'Not domain-joined: use ADTD -Server <dc> -Credential (Get-Credential)' })
    $rootOk = $false; $nc = $null
    try { $rd = New-Object System.DirectoryServices.DirectoryEntry('LDAP://RootDSE'); $nc = $rd.Properties['defaultNamingContext'][0]; $rootOk = [bool]$nc } catch { }
    & $add 'Read Active Directory as this user' $(if ($rootOk) { 'OK' } else { 'Failed' }) $(if ($rootOk) { "$env:USERDOMAIN\$env:USERNAME can read $nc (ADTD only needs read access)" } else { 'Could not read RootDSE: log on with a domain account, or run ADTD with -Server and -Credential' })
    if ($dc) {
        & $add 'LDAP (389) to a DC' $(if (Test-Port $dc 389) { 'OK' } else { 'Blocked' }) $dc
        & $add 'Global catalog (3268)' $(if (Test-Port $dc 3268) { 'OK' } else { 'Blocked' }) 'Used to read DC operating systems across the forest'
    }
    $d = Find-DrawIo
    $li = try { Find-LocalDrawIoInstaller } catch { $null }
    & $add 'draw.io desktop' $(if ($d) { 'OK' } else { 'Not installed' }) $(if ($d) { $d } elseif ($li) { "Installer ready: $li (choose 1)" } else { 'Install with -DrawIoDesktop, or use draw.io on the web' })
    & $add 'draw.io on the web' $(if (Test-Url 'https://app.diagrams.net') { 'Reachable' } else { 'Not reachable' }) 'https://app.diagrams.net (and viewer.diagrams.net for the report viewer)'
    & $add 'winget' $(if (Get-Winget) { 'OK' } else { 'Not available' }) 'Used to install draw.io and PowerShell 7; a direct download is used otherwise'
    $v = Find-Visio
    & $add 'Visio desktop (optional)' $(if ($v) { 'OK' } else { 'Not installed' }) $(if ($v) { $v } else { 'Optional: only for -Format Visio. Install with -Visio (needs a licence)' })
    $mod = Get-Module -ListAvailable ADTD | Select-Object -First 1
    & $add 'ADTD Modern module' $(if ($mod) { 'OK' } else { 'Not installed' }) $(if ($mod) { "$($mod.Version) in $($mod.ModuleBase)" } else { 'Run the MSI or Install-ADTD.ps1' })
    & $add 'Execution policy' (Get-ExecutionPolicy) 'The Start menu shortcuts use -ExecutionPolicy Bypass for their own process'
    & $add 'Running as administrator' $(if (Test-Admin) { 'Yes' } else { 'No' }) 'Needed for machine-wide installs and Visio; draw.io and PowerShell 7 can install per user'
    $rows | Format-Table -AutoSize -Wrap | Out-Host
}

function Find-LocalDrawIoInstaller {
    if ($DrawIoInstaller) { if (Test-Path $DrawIoInstaller) { return (Resolve-Path $DrawIoInstaller).Path } else { throw "Installer not found: $DrawIoInstaller" } }
    foreach ($dir in @($PSScriptRoot, (Join-Path $PSScriptRoot 'drawio'), (Join-Path $PSScriptRoot '..\drawio'), (Join-Path $PSScriptRoot '..\..\drawio'))) {
        if (-not (Test-Path $dir)) { continue }
        $f = Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^draw\.io-.*\.(exe|msi)$' } | Sort-Object Name -Descending | Select-Object -First 1
        if ($f) { return $f.FullName }
    }
    return $null
}

function Install-DrawIoFromFile([string]$File) {
    $sig = Get-AuthenticodeSignature $File
    if ($sig.Status -ne 'Valid') { throw "The installer's signature is not valid ($($sig.Status)); not running it. File: $File" }
    Write-Host "Installing draw.io desktop from $File (signed by: $($sig.SignerCertificate.Subject))"
    if ($File -match '\.msi$') {
        if (-not (Test-Admin)) { throw 'The draw.io .msi installs for all users and needs an elevated PowerShell. Use the draw.io-*-windows-installer.exe for a per-user install.' }
        Start-Process msiexec.exe -ArgumentList "/i `"$File`" /qn" -Wait
    } else {
        Start-Process -FilePath $File -ArgumentList '/S' -Wait
    }
    return [bool](Find-DrawIo)
}

function Install-DrawIoDesktop {
    if (Find-DrawIo) { Write-Host 'draw.io desktop is already installed.' -ForegroundColor Green; return $true }
    $local = Find-LocalDrawIoInstaller
    if ($local) {
        if (Install-DrawIoFromFile $local) { Write-Host 'draw.io desktop installed.' -ForegroundColor Green; return $true }
        Write-Warning 'The local installer finished but draw.io.exe was not found in the usual folders.'
        return $false
    }
    $wg = Get-Winget
    if ($wg) {
        Write-Host 'Installing draw.io desktop with winget (JGraph.Draw)...'
        $scope = if (Test-Admin) { @() } else { @('--scope', 'user') }
        & $wg.Source install --id JGraph.Draw -e --silent --accept-source-agreements --accept-package-agreements @scope
        if (Find-DrawIo) { Write-Host 'draw.io desktop installed.' -ForegroundColor Green; return $true }
        Write-Warning 'winget did not finish the install; trying the official installer.'
    }
    Write-Host 'Downloading the latest draw.io desktop installer from github.com/jgraph/drawio-desktop...'
    $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest' -UseBasicParsing -Headers @{ 'User-Agent' = 'ADTD-Modern' }
    $asset = $rel.assets | Where-Object { $_.name -match '^draw\.io-[\d.]+-windows-installer\.exe$' } | Select-Object -First 1
    if (-not $asset) { throw 'Could not find the Windows installer in the latest draw.io release. Download it from https://www.drawio.com/ instead.' }
    $file = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $file -UseBasicParsing
    $sig = Get-AuthenticodeSignature $file
    if ($sig.Status -ne 'Valid') { throw "The downloaded installer's signature is not valid ($($sig.Status)); not running it. File: $file" }
    Write-Host "Signed by: $($sig.SignerCertificate.Subject)"
    Start-Process -FilePath $file -ArgumentList '/S' -Wait
    if (Find-DrawIo) { Write-Host 'draw.io desktop installed.' -ForegroundColor Green; return $true }
    Write-Warning 'The installer finished but draw.io.exe was not found in the usual folders.'
    return $false
}

function Install-PowerShell7 {
    if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { Write-Host 'PowerShell 7 is already installed.' -ForegroundColor Green; return }
    $wg = Get-Winget
    if (-not $wg) { Write-Warning 'winget is not available. Download PowerShell 7 from https://aka.ms/powershell-release?tag=stable'; return }
    & $wg.Source install --id Microsoft.PowerShell -e --silent --accept-source-agreements --accept-package-agreements
}

function Install-VisioDesktop {
    if (Find-Visio) { Write-Host "Visio is already installed: $(Find-Visio)" -ForegroundColor Green; return }
    if (-not (Test-Admin)) { throw 'Installing Visio needs an elevated (Run as administrator) PowerShell.' }
    Write-Host "Visio is licensed separately. Plan 2 needs a Visio Plan 2 licence assigned to the user; 2024 editions need a volume licence (KMS or MAK)." -ForegroundColor Yellow
    if (-not $Quiet) { $a = Read-Host 'Continue? (y/N)'; if ($a -notmatch '^[yY]') { return } }
    $work = Join-Path $env:TEMP 'ADTD-ODT'
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    Write-Host 'Finding the latest Office Deployment Tool on the Microsoft Download Center...'
    $page = Invoke-WebRequest -Uri 'https://www.microsoft.com/en-us/download/details.aspx?id=49117' -UseBasicParsing
    $m = [regex]::Match($page.Content, 'https://download\.microsoft\.com/download/[^"''\s]+officedeploymenttool[^"''\s]*\.exe', 'IgnoreCase')
    if (-not $m.Success) { throw 'Could not find the Office Deployment Tool download link. Download it from https://www.microsoft.com/download/details.aspx?id=49117 and run setup.exe /configure yourself.' }
    $odt = Join-Path $work 'officedeploymenttool.exe'
    Invoke-WebRequest -Uri $m.Value -OutFile $odt -UseBasicParsing
    $sig = Get-AuthenticodeSignature $odt
    if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Microsoft') { throw "The Office Deployment Tool's signature could not be verified ($($sig.Status))." }
    Start-Process -FilePath $odt -ArgumentList "/quiet /extract:`"$work`"" -Wait

    $c2r = Get-OfficeC2R
    $bits = if ($c2r -and $c2r.Platform -eq 'x86') { '32' } else { '64' }
    switch ($VisioEdition) {
        'Plan2' { $product = 'VisioProRetail'; $channel = if ($c2r -and $c2r.UpdateChannel) { $null } else { 'Current' } }
        'Professional2024' { $product = 'VisioPro2024Volume'; $channel = 'PerpetualVL2024' }
        'Standard2024' { $product = 'VisioStd2024Volume'; $channel = 'PerpetualVL2024' }
    }
    $pidKey = if ($VisioProductKey) { " PIDKEY=`"$VisioProductKey`"" } else { '' }
    $ch = if ($channel) { " Channel=`"$channel`"" } else { '' }
    $xml = @"
<Configuration>
  <Add OfficeClientEdition="$bits"$ch>
    <Product ID="$product"$pidKey>
      <Language ID="MatchInstalled" Fallback="en-us" />
    </Product>
  </Add>
  <Display Level="Full" AcceptEULA="FALSE" />
</Configuration>
"@
    $cfg = Join-Path $work 'visio.xml'
    Set-Content -Path $cfg -Value $xml -Encoding UTF8
    Write-Host "Installing $product ($bits-bit) with the Office Deployment Tool. The Office installer window will show progress."
    Start-Process -FilePath (Join-Path $work 'setup.exe') -ArgumentList "/configure `"$cfg`"" -Wait
    if (Find-Visio) { Write-Host 'Visio installed. Sign in with the licensed account (Plan 2) or activate the volume licence.' -ForegroundColor Green }
    else { Write-Warning "Visio was not detected after setup. Check the log in $env:TEMP (files named like '<computer>-*.log')." }
}

Write-Host ''
Write-Host 'ADTD Modern - prerequisites' -ForegroundColor Cyan
Show-Status
if ($CheckOnly) { return }

$any = $DrawIoDesktop -or $DrawIoWeb -or $PowerShell7 -or $Visio
if (-not $any -and -not $Quiet) {
    Write-Host 'What would you like to do?'
    Write-Host '  1  Install draw.io desktop (free) and open drawings there'
    Write-Host '  2  Use draw.io on the web (free, nothing to install)'
    Write-Host '  3  Install PowerShell 7 (optional)'
    Write-Host '  4  Install Visio desktop (optional, needs a Visio licence)'
    Write-Host '  5  Exit'
    $choice = Read-Host 'Choose 1-5 (you can enter several, like 1,3)'
    foreach ($c in ($choice -split '[,\s]+' | Where-Object { $_ })) {
        switch ($c) { '1' { $DrawIoDesktop = $true } '2' { $DrawIoWeb = $true } '3' { $PowerShell7 = $true } '4' { $Visio = $true } default { } }
    }
}
if ($DrawIoDesktop) { if (Install-DrawIoDesktop) { Set-Viewer 'Desktop' } }
if ($DrawIoWeb) {
    if (Test-Url 'https://app.diagrams.net') { Set-Viewer 'Web' }
    else { Write-Warning 'app.diagrams.net is not reachable from this computer (proxy or firewall?). Drawings will still be saved; open them in draw.io desktop or on another computer.'; Set-Viewer 'Web' }
}
if ($PowerShell7) { Install-PowerShell7 }
if ($Visio) { Install-VisioDesktop }
if ($DrawIoDesktop -or $DrawIoWeb -or $PowerShell7 -or $Visio) { Write-Host ''; Write-Host 'Updated status:' -ForegroundColor Cyan; Show-Status }
