# ADTD Modern - Copyright (c) 2026 Shenuka Fernando. All rights reserved.
# Free to use under the ADTD Modern Licence (LICENSE). Copying, modifying or reselling needs written permission.

<#
.SYNOPSIS
Installs ADTD Modern for the current user without the MSI and without admin rights.

.DESCRIPTION
Copies the module to Documents\WindowsPowerShell\Modules\ADTD (Windows PowerShell 5.1) and
Documents\PowerShell\Modules\ADTD (PowerShell 7), adds Start menu shortcuts that open ADTD.exe
(the app, with its own icon), then opens the welcome screen: install location, desktop shortcut
and pin to taskbar.

.PARAMETER DesktopShortcut
Also adds an "ADTD Modern" shortcut to your desktop (the welcome screen offers this too).

.PARAMETER NoWelcome
Doesn't open the welcome screen at the end.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\Install-ADTD.ps1
powershell -ExecutionPolicy Bypass -File .\Install-ADTD.ps1 -DesktopShortcut -NoWelcome
powershell -ExecutionPolicy Bypass -File .\Install-ADTD.ps1 -Uninstall
#>
param([switch]$Uninstall, [switch]$DesktopShortcut, [switch]$NoWelcome)
$ErrorActionPreference = 'Stop'
$docs = [Environment]::GetFolderPath('MyDocuments')
$targets = @((Join-Path $docs 'WindowsPowerShell\Modules\ADTD'), (Join-Path $docs 'PowerShell\Modules\ADTD'))
$menu = Join-Path ([Environment]::GetFolderPath('Programs')) 'ADTD Modern'
$desktop = Join-Path ([Environment]::GetFolderPath('Desktop')) 'ADTD Modern.lnk'
$src = Join-Path $PSScriptRoot '..\src'
if (-not (Test-Path (Join-Path $src 'ADTD.psd1'))) { $src = $PSScriptRoot }   # files next to this script

if ($Uninstall) {
    foreach ($t in $targets + $menu + $desktop) { if (Test-Path $t) { Remove-Item $t -Recurse -Force; Write-Host "Removed $t" } }
    return
}

foreach ($t in $targets) {
    New-Item -ItemType Directory -Path $t -Force | Out-Null
    Copy-Item (Join-Path $src '*.ps*1') $t -Force
    foreach ($f in 'ADTD.exe', 'ADTD.ico', 'ADTD-64.png', 'LICENSE.txt') { if (Test-Path (Join-Path $src $f)) { Copy-Item (Join-Path $src $f) $t -Force } }
    if (Test-Path (Join-Path $src 'lib')) { Copy-Item (Join-Path $src 'lib') $t -Recurse -Force }
    $prereq = Join-Path $PSScriptRoot 'Install-Prerequisites.ps1'
    if (Test-Path $prereq) { Copy-Item $prereq $t -Force }
    Get-ChildItem $t | Unblock-File
    Write-Host "Installed to $t"
}
$readme = Join-Path $src 'README.html'
if (Test-Path $readme) { foreach ($t in $targets) { Copy-Item $readme $t -Force } }

New-Item -ItemType Directory -Path $menu -Force | Out-Null
$shell = New-Object -ComObject WScript.Shell
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$exe = Join-Path $targets[0] 'ADTD.exe'
$app = @((Join-Path $menu 'ADTD Modern.lnk'))
if ($DesktopShortcut) { $app += $desktop }
foreach ($path in $app) {
    $lnk = $shell.CreateShortcut($path)
    if (Test-Path $exe) {
        $lnk.TargetPath = $exe
        $lnk.IconLocation = "$exe,0"
    } else {
        $lnk.TargetPath = $ps
        $lnk.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File `"$($targets[0])\ADTD.ps1`" -Gui"
    }
    $lnk.WorkingDirectory = $targets[0]
    $lnk.Description = 'ADTD Modern - Active Directory topology, security and hybrid Entra ID assessment'
    $lnk.Save()
}
if ($DesktopShortcut) { Write-Host "Desktop shortcut: $desktop" }
Write-Host "Start menu shortcut: $menu"
$lnk2 = $shell.CreateShortcut((Join-Path $menu 'ADTD Modern - Prerequisites.lnk'))
$lnk2.TargetPath = $ps
$lnk2.Arguments = "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$($targets[0])\Install-Prerequisites.ps1`""
$lnk2.WorkingDirectory = $targets[0]
if (Test-Path (Join-Path $targets[0] 'ADTD.ico')) { $lnk2.IconLocation = "$(Join-Path $targets[0] 'ADTD.ico'),0" }
$lnk2.Save()
Write-Host 'Done. Open "ADTD Modern" from the Start menu, or run Invoke-ADTD in PowerShell.'
Write-Host 'Next: run "ADTD Modern - Prerequisites" to install draw.io desktop or choose draw.io on the web.'
if (-not $NoWelcome -and (Test-Path $exe)) { Start-Process $exe -ArgumentList '--welcome' }
