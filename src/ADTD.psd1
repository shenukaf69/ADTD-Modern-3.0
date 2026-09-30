# ADTD Modern - Copyright (c) 2026 Shenuka Fernando. All rights reserved.
# Free to use under the ADTD Modern Licence (LICENSE). Copying, modifying or reselling needs written permission.

@{
    RootModule        = 'ADTD.psm1'
    ModuleVersion     = '3.0.5'
    GUID              = '51198933-11de-4cc3-b34c-26dd01c7f6d6'
    Author            = 'Shenuka Fernando'
    Copyright         = '(c) 2026 Shenuka Fernando. All rights reserved. Free to use under the ADTD Modern Licence.'
    Description       = 'ADTD Modern: draws Active Directory (sites, replication, domains, trusts, OUs, DFS-R, Exchange) up to Windows Server 2025 in draw.io, and assesses health, security and Microsoft Entra ID hybrid readiness with a per-finding report and upgrade roadmap. Read-only.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    FunctionsToExport = @('Invoke-ADTD', 'Show-ADTD', 'Get-AdtdInventory', 'Get-AdtdFindings', 'Get-AdtdTopologyPlan', 'Get-AdtdGapAnalysis', 'New-AdtdDiagram', 'Export-AdtdDrawIo', 'Export-AdtdVisio', 'Export-AdtdHtmlReport', 'Export-AdtdMarkdown', 'Export-AdtdCsv', 'Get-AdtdDrawIoWebUrl', 'Open-AdtdDrawing', 'Get-AdtdSettings', 'Set-AdtdSettings', 'Test-AdtdConnection')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{ PSData = @{ Tags = @('ActiveDirectory', 'drawio', 'Topology', 'Diagram', 'Security', 'EntraID', 'Hybrid', 'Assessment'); LicenseUri = 'https://github.com/shenukaf69/ADTD-Modern-3.0/blob/main/LICENSE'; ProjectUri = 'https://github.com/shenukaf69/ADTD-Modern-3.0' } }
}
