# Development

[Back to README](../README.md)

## How it fits together

```
Get-AdtdInventory (ADTD.Collect.ps1)          topology over LDAP
  └─ Get-AdtdDomainSecurity / Get-AdtdForestSecurity (ADTD.Security.ps1)
Get-AdtdFindings, Get-AdtdTopologyPlan (ADTD.Assessment.ps1)   pure functions over the inventory
New-AdtdDiagram (ADTD.Render.ps1)             page model: nodes, containers, edges
  ├─ Export-AdtdDrawIo                        .drawio
  └─ Export-AdtdVisio                         .vsdx via Visio COM (optional)
Export-AdtdHtmlReport / -Tabs, Export-AdtdMarkdown, Export-AdtdCsv (ADTD.Report.ps1)
Invoke-ADTD (ADTD.psm1)                       command
Show-ADTD, About, welcome (ADTD.Gui.ps1)      window (Windows Forms)
ADTD.exe (launcher/ADTD.cs)                   app launcher: hosts PowerShell so the window has its own icon
```

- **All directory reads** go through `Invoke-AdtdLdapSearch` and `Get-AdtdRootDse`. The tests replace these two functions with an in-memory directory.
- **Assessment and rendering never touch LDAP.** Because of that, a saved JSON inventory can be re-assessed anywhere with `-InputFile`.

## Tests

```powershell
pwsh ./tests/Test-ADTD.ps1                     # PowerShell 7 (Windows, Linux, macOS)
powershell -File .\tests\Test-ADTD.ps1         # Windows PowerShell 5.1
```

The test builds a fake Contoso forest: two domains, five sites, six DCs, trusts, OUs and GPOs, DFS-R, Exchange SE and 2019, users, groups and computers with deliberate weaknesses, AD CS templates, and Entra ID objects. It has a tiny LDAP filter engine that supports `&`, `|`, `!`, wildcards and the in-chain matching rule. It runs the full pipeline and checks:
- the inventory
- 43 expected findings, and 7 that must *not* fire
- the gap analysis and roadmap
- the draw.io XML: pages, unique IDs, and no dangling edges
- the HTML and tabbed HTML reports
- the Markdown files and CSVs
- that the draw.io web link decodes back to the file
- a redraw from JSON

GitHub Actions ([`.github/workflows/ci.yml`](../.github/workflows/ci.yml)) runs it on:
- Linux with PowerShell 7
- Windows with PowerShell 7
- Windows PowerShell 5.1

It then builds the MSI as an artifact.

## Adding a check

1. Add a `Register-AdtdCheck` entry in `src/ADTD.Assessment.ps1` with:
   - ID, severity, category and area
   - title and risk
   - steps
   - reference keys from `$script:Refs`, adding the reference first if it's new
   - roadmap phase
2. Add the logic in `Get-AdtdFindings` with `& $add '<ID>' '<what was found>' <evidence list>`. If the check needs new data, collect it in `ADTD.Security.ps1` or `ADTD.Collect.ps1`.
3. Add fixture data and an assertion in `tests/Test-ADTD.ps1`.
4. Regenerate the catalog: `pwsh ./tools/Update-FindingsDoc.ps1`.

## Updating the version tables

Everything release-specific is in `src/ADTD.Versions.ps1`:

| Table | Add a row when |
|---|---|
| `$FunctionalLevels`, `$LatestFunctionalLevel` | A new domain/forest functional level ships |
| `$SchemaVersions` | A new `objectVersion` ships |
| `$WindowsServerBuilds` | A new Windows Server build ships (with its end of extended support date) |
| `$WindowsClientBuilds` | A new Windows 11 release or LTSC ships |
| `$ExchangeSchemaVersions`, `$ExchangeSeFirstBuild` | A new Exchange schema or product line ships |

## Building the MSI

```powershell
pwsh ./setup/build-msi.ps1
```

This uses `wixl` (msitools) on Linux or WSL, or WiX Toolset 3.x (`candle` and `light`) on Windows. The output is `dist/ADTD_Modern_Setup_<version>.msi`. Before a release, bump the version in all of these places:
- `setup/ADTD.wxs`: Product `Version`, `UpgradeVersion` and the registry value
- `src/ADTD.psd1`: `ModuleVersion`
- `src/ADTD.psm1`: `$script:AdtdVersion`
- `launcher/ADTD.cs`: the `Assembly*Version` attributes (then rebuild `ADTD.exe`)
- the MSI file name in `build-msi.ps1` and the docs

Keep the `UpgradeCode` the same so newer MSIs replace older ones.

## Publishing a release

1. Bump the version (see above) and add a section for it at the top of `CHANGELOG.md`.
2. Rebuild the MSI with `setup/build-msi.ps1` and commit it.
3. Push a tag: `git tag v3.0.3` then `git push origin v3.0.3`.

The **Release** workflow (`.github/workflows/release.yml`) then runs the tests, builds the MSI and the offline package (`setup/build-offline-package.ps1`), and publishes a GitHub Release with both files. The release notes come from that version's `CHANGELOG.md` section. You can also run the workflow from the **Actions** tab (Release → Run workflow) and enter a tag such as `v3.0.3`; it creates the tag on the chosen branch if needed.

## Building ADTD.exe

`src/ADTD.exe` is a small launcher (`launcher/ADTD.cs`). It hosts Windows PowerShell 5.1 inside its own process and calls `Show-ADTD`, so Windows shows the ADTD Modern icon on the taskbar and the app can be pinned. It is DPI aware and shows no console. It's checked in so the repository runs as is; rebuild it after changing `ADTD.cs` or `ADTD.ico`:

```powershell
# Windows (.NET Framework 4 compiler, built in)
cd launcher
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /win32icon:..\src\ADTD.ico /r:System.Windows.Forms.dll /out:..\src\ADTD.exe ADTD.cs
# Linux (mono)
mcs -sdk:4.5 -target:winexe -win32icon:../src/ADTD.ico -r:System.Windows.Forms.dll -out:../src/ADTD.exe ADTD.cs
```

Also update the version attributes at the top of `ADTD.cs` for a release.

## Signing

```powershell
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1
Get-ChildItem .\src, .\setup -Include *.ps1, *.psm1, *.psd1, *.exe -Recurse | Set-AuthenticodeSignature -Certificate $cert -TimestampServer http://timestamp.digicert.com
pwsh ./setup/build-msi.ps1
signtool sign /fd SHA256 /a /tr http://timestamp.digicert.com /td SHA256 dist\ADTD_Modern_Setup_3.0.2.msi
```

## Previewing drawings without draw.io

The screenshots in `docs/images` were rendered headlessly with the open-source `mxgraph` library and Chromium. Real draw.io renders labels and swimlane headers slightly differently.
