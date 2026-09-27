@{
    RootModule        = 'ADTD.psm1'
    ModuleVersion     = '3.0.1'
    GUID              = '51198933-11de-4cc3-b34c-26dd01c7f6d6'
    Author            = 'Shenuka Fernando'
    Description       = 'ADTD Modern: draws Active Directory (sites, replication, domains, trusts, OUs, DFS-R, Exchange) up to Windows Server 2025 in draw.io, and assesses health, security and Microsoft Entra ID hybrid readiness with a per-finding report and upgrade roadmap. Read-only.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    FunctionsToExport = @('Invoke-ADTD', 'Show-ADTD', 'Get-AdtdInventory', 'Get-AdtdFindings', 'Get-AdtdTopologyPlan', 'Get-AdtdGapAnalysis', 'New-AdtdDiagram', 'Export-AdtdDrawIo', 'Export-AdtdVisio', 'Export-AdtdHtmlReport', 'Export-AdtdMarkdown', 'Export-AdtdCsv', 'Get-AdtdDrawIoWebUrl', 'Open-AdtdDrawing', 'Get-AdtdSettings', 'Set-AdtdSettings')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{ PSData = @{ Tags = @('ActiveDirectory', 'drawio', 'Topology', 'Diagram', 'Security', 'EntraID', 'Hybrid', 'Assessment') } }
}
