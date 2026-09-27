<#
.SYNOPSIS
ADTD Modern - draws and assesses your Active Directory (topology, security, hybrid Entra ID readiness).

.DESCRIPTION
Run with no parameters (or -Gui) to open the window. Any other parameter runs it from the command line;
the parameters are those of Invoke-ADTD (Get-Help Invoke-ADTD -Full).

.EXAMPLE
.\ADTD.ps1
.\ADTD.ps1 -All -Format DrawIo, Html, Markdown, Csv -Open -DrawIoViewer Web
.\ADTD.ps1 -Server dc01.contoso.com -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [switch]$Gui,
    [string]$Server,
    [pscredential]$Credential,
    [string[]]$Drawings,
    [switch]$All,
    [string[]]$Format,
    [string]$OutputFolder,
    [string]$InputFile,
    [int]$MaxOUs,
    [string]$DrawIoViewer,
    [switch]$SkipSecurityScan,
    [switch]$NoDrawIoWeb,
    [switch]$Open
)
Import-Module (Join-Path $PSScriptRoot 'ADTD.psd1') -Force
$p = @{}
foreach ($k in $PSBoundParameters.Keys) { if ($k -ne 'Gui') { $p[$k] = $PSBoundParameters[$k] } }
# "powershell -File ADTD.ps1 -Drawings Sites,OUs" passes one string; split it (Invoke-ADTD validates the names).
foreach ($k in 'Drawings', 'Format') { if ($p.ContainsKey($k)) { $p[$k] = @($p[$k] | ForEach-Object { $_ -split '\s*,\s*' } | Where-Object { $_ }) } }
if ($Gui -or $p.Count -eq 0) { Show-ADTD; return }
Invoke-ADTD @p
