<#
.SYNOPSIS
Builds dist\ADTD_Modern_Setup_3.0.2.msi from ADTD.wxs.

.DESCRIPTION
Uses WiX Toolset 3.x (candle.exe / light.exe) on Windows, or wixl (msitools) on Linux / WSL.
Bump the version in three places before a release: ADTD.wxs (Product Version, UpgradeVersion,
registry Version), src/ADTD.psd1 (ModuleVersion) and src/ADTD.psm1 ($script:AdtdVersion).
Sign the result if you distribute it:  signtool sign /fd SHA256 /a /tr http://timestamp.digicert.com /td SHA256 ADTD_Modern_Setup.msi
#>
param([string]$Output = (Join-Path $PSScriptRoot '..\dist\ADTD_Modern_Setup_3.0.2.msi'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path (Split-Path $Output -Parent) -Force | Out-Null
$Output = [System.IO.Path]::GetFullPath($Output)
Push-Location $PSScriptRoot
try {
    $wixl = Get-Command wixl -ErrorAction SilentlyContinue
    $candle = Get-Command candle.exe -ErrorAction SilentlyContinue
    if (-not $candle -and $env:WIX) { $candle = Get-Item (Join-Path $env:WIX 'bin\candle.exe') -ErrorAction SilentlyContinue }
    if ($wixl) {
        & wixl -a x64 -o $Output ADTD.wxs
    } elseif ($candle) {
        $bin = Split-Path $candle.Source -Parent
        if (-not $bin) { $bin = Split-Path $candle.FullName -Parent }
        & (Join-Path $bin 'candle.exe') -arch x64 -out ADTD.wixobj ADTD.wxs
        & (Join-Path $bin 'light.exe') -out $Output ADTD.wixobj -sice:ICE38 -sice:ICE43 -sice:ICE57 -sice:ICE64 -sice:ICE91
    } else {
        throw 'Install WiX Toolset 3.14 (https://wixtoolset.org) or run this under WSL with: sudo apt install wixl'
    }
    if ($LASTEXITCODE) { throw "MSI build failed ($LASTEXITCODE)" }
    Write-Host "Built $Output"
} finally { Pop-Location }
