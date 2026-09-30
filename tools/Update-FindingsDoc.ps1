# ADTD Modern - Copyright (c) 2026 Shenuka Fernando. All rights reserved.
# Free to use under the ADTD Modern Licence (LICENSE). Copying, modifying or reselling needs written permission.

<#
Regenerates docs/FINDINGS.md from the check catalog in src/ADTD.Assessment.ps1, so the documentation always
matches the code:  pwsh ./tools/Update-FindingsDoc.ps1
#>
$mod = Import-Module (Join-Path $PSScriptRoot '..\src\ADTD.psd1') -Force -PassThru
$md = & $mod {
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# Findings catalog')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('Every check ADTD Modern runs, with its severity, what it looks at, why it matters, how to fix it and the Microsoft guidance behind it. Generated from `src/ADTD.Assessment.ps1` by `tools/Update-FindingsDoc.ps1`; do not edit by hand.')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('IDs: **H** = health and topology, **S** = security, **X** = hybrid identity (Microsoft Entra ID) readiness. The roadmap phase (1-4) decides where the finding lands in the upgrade roadmap.')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('| ID | Severity | Area | Check | Phase |')
    [void]$sb.AppendLine('|---|---|---|---|---|')
    foreach ($c in $script:AdtdChecks.Values) { [void]$sb.AppendLine("| [$($c.Id)](#$($c.Id.ToLower())) | $($c.Severity) | $($c.Area) | $($c.Title) | $($c.Phase) |") }
    foreach ($cat in 'Health', 'Security', 'Hybrid') {
        [void]$sb.AppendLine(''); [void]$sb.AppendLine("## $(@{ Health = 'Health and topology'; Security = 'Security'; Hybrid = 'Hybrid identity readiness' }[$cat])")
        foreach ($c in @($script:AdtdChecks.Values | Where-Object Category -eq $cat)) {
            [void]$sb.AppendLine(''); [void]$sb.AppendLine("### $($c.Id)"); [void]$sb.AppendLine('')
            [void]$sb.AppendLine("**$($c.Title)** · $($c.Severity) · $($c.Area) · roadmap phase $($c.Phase)"); [void]$sb.AppendLine('')
            [void]$sb.AppendLine("*Why it matters:* $($c.Risk)"); [void]$sb.AppendLine('')
            [void]$sb.AppendLine('*How to fix:*'); [void]$sb.AppendLine('')
            $i = 1; foreach ($st in $c.Steps) { [void]$sb.AppendLine("$i. $st"); $i++ }
            if (@($c.Refs).Count) { [void]$sb.AppendLine(''); [void]$sb.AppendLine('*References:* ' + ((@($c.Refs) | ForEach-Object { "[$($_.Title)]($($_.Url))" }) -join ' · ')) }
        }
    }
    [void]$sb.AppendLine(''); [void]$sb.AppendLine('## Checked by hand'); [void]$sb.AppendLine('')
    [void]$sb.AppendLine('These can''t be read over LDAP, so the report lists them as a checklist:'); [void]$sb.AppendLine('')
    foreach ($v in $script:AdtdVerifyManually) { [void]$sb.AppendLine("- **$($v.Item)**: $($v.Why) ([reference]($($v.Ref.Url)))") }
    $sb.ToString()
}
$out = Join-Path $PSScriptRoot '..\docs\FINDINGS.md'
[System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($out), $md, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Wrote $out"
