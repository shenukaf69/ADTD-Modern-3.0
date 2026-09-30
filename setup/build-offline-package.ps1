# ADTD Modern - Copyright (c) 2026 Shenuka Fernando. All rights reserved.
# Free to use under the ADTD Modern Licence (LICENSE). Copying, modifying or reselling needs written permission.

<#
.SYNOPSIS
Builds dist\ADTD-Modern-<version>-offline.zip: the MSI plus everything needed on a computer without internet.

.DESCRIPTION
Run setup\build-msi.ps1 first. The zip holds the MSI, START-HERE.txt, the per-user installer and
prerequisites script, src, docs, samples and an empty drawio folder for the draw.io desktop installer.
#>
param([string]$OutputFolder = (Join-Path $PSScriptRoot '..\dist'))
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$version = (Import-PowerShellDataFile (Join-Path $root 'src\ADTD.psd1')).ModuleVersion
$msi = Join-Path $root "dist\ADTD_Modern_Setup_$version.msi"
if (-not (Test-Path $msi)) { throw "Build the MSI first: $msi was not found." }
$name = "ADTD-Modern-$version-offline"
$stage = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$pkg = Join-Path $stage $name
New-Item -ItemType Directory -Path (Join-Path $pkg 'setup'), (Join-Path $pkg 'drawio') -Force | Out-Null
Copy-Item $msi, (Join-Path $root 'setup\START-HERE.txt'), (Join-Path $root 'README.md'), (Join-Path $root 'CHANGELOG.md'), (Join-Path $root 'COPYRIGHT'), (Join-Path $root 'LICENSE') $pkg
Copy-Item (Join-Path $root 'setup\Install-ADTD.ps1'), (Join-Path $root 'setup\Install-Prerequisites.ps1') (Join-Path $pkg 'setup')
foreach ($d in 'src', 'docs', 'samples') { Copy-Item (Join-Path $root $d) $pkg -Recurse }
@'
Put the draw.io desktop installer in this folder, for example
  draw.io-<version>-windows-installer.exe   (per-user install)
  draw.io-<version>.msi                     (all users, needs admin)

Download it on a computer with internet access from:
  https://github.com/jgraph/drawio-desktop/releases

Then run ..\setup\Install-Prerequisites.ps1 and choose 1.
The script checks the installer's digital signature before running it.

draw.io desktop is optional: the HTML reports show the diagrams without it.
'@ | Set-Content -Path (Join-Path $pkg 'drawio\PUT-DRAWIO-INSTALLER-HERE.txt') -Encoding UTF8
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
$zip = Join-Path (Resolve-Path $OutputFolder).Path "$name.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $pkg -DestinationPath $zip
Remove-Item $stage -Recurse -Force
Write-Host "Built $zip"
