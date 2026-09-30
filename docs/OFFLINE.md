# Running ADTD Modern in an environment without internet access

[Back to README](../README.md)

ADTD Modern needs **no internet access** to collect, assess, draw or report:
- It reads Active Directory over LDAP inside your network.
- The HTML reports have a **built-in diagram viewer** (mxGraph, bundled in `src/lib`). Diagrams display with no network access.
- Nothing is uploaded anywhere.

The only optional online pieces are draw.io on the web (app.diagrams.net) and downloading installers. The offline package and the `-Offline` switch avoid both.

## Where to run it

On **any domain-joined Windows computer** in the forest:
- An admin workstation, or a management or jump server, is ideal.
- A domain controller also works, but it isn't needed. Microsoft recommends not installing extra tools on DCs.
- A computer that is **not** domain-joined works too, if it can reach a DC. Run it with `-Server dc01.contoso.com -Credential (Get-Credential)`.

| Prerequisite | Needed? | Notes |
|---|---|---|
| Windows 10/11 or Windows Server 2016+ (64-bit) | Yes | |
| Windows PowerShell 5.1 | Yes | Built into Windows. PowerShell 7 is optional |
| Domain user account | Yes | **Read-only**: ordinary Domain Users rights are enough. No admin rights in AD |
| Network to a domain controller | Yes | TCP 389 (LDAP) and TCP 3268 (global catalog), plus DNS to find DCs |
| Local admin on the computer | Only for the MSI | Or use `Install-ADTD.ps1` (per user, no admin) or run from the folder |
| draw.io desktop | Recommended | To open and edit the `.drawio` file. The reports show diagrams without it |
| Internet access | No | |
| RSAT / ActiveDirectory PowerShell module | No | |
| Visio | No | Optional, for `.vsdx` output only |

## Step by step

### 1. On a computer with internet access

1. Download the ADTD offline package, `ADTD-Modern-3.0-offline.zip`. You can also make it yourself by downloading this repository as a ZIP.
2. **Optional, recommended:** download the draw.io desktop installer from [github.com/jgraph/drawio-desktop/releases](https://github.com/jgraph/drawio-desktop/releases). Pick `draw.io-<version>-windows-installer.exe` for a per-user install, or `draw.io-<version>.msi` to install for all users. Put the file in the package's `drawio` folder.
3. Copy the folder to the target computer, for example with a USB drive or an approved file transfer.

### 2. On the domain-joined computer

1. Right-click the zip → **Properties** → **Unblock** → **OK**, then extract it. You can also unblock after extracting: `Get-ChildItem -Recurse | Unblock-File`.
2. Install ADTD, either:
   - **with admin rights:** double-click `ADTD_Modern_Setup_3.0.5.msi`, or
   - **without admin rights:** run `powershell -ExecutionPolicy Bypass -File .\setup\Install-ADTD.ps1`.
3. Check the prerequisites and install draw.io:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup\Install-Prerequisites.ps1
   ```

   The status table shows:
   - whether you can read AD
   - whether LDAP and the global catalog are reachable
   - whether a draw.io installer was found in the `drawio` folder

   Choose **1** to install draw.io desktop from that file. The script checks the file's digital signature before running it.
4. Run ADTD:
   - **Window:** Start → **ADTD Modern**. In step 3, tick **No internet on this computer (offline mode)**, then click **Draw my Active Directory**.
   - **PowerShell:** run the command below.

   ```powershell
   Invoke-ADTD -All -Format DrawIo, Html, HtmlTabs, Markdown, Csv, Json -Offline -Open
   ```

5. Results are in `Documents\ADTD`:
   - `...-tabs.html`: the tabbed report, with diagrams viewable offline
   - `...html`: the single-page report
   - `...drawio`: the drawing, for draw.io desktop
   - `...-findings\`: one Markdown report per finding
   - `...-csv\`, `.json` and `.log`

`-Offline` leaves out the draw.io web links and opens drawings in draw.io desktop. Without draw.io desktop, open the report's **Diagrams** tab instead.

### Running without installing anything

```powershell
cd <extracted folder>
powershell -ExecutionPolicy Bypass -File .\src\ADTD.ps1 -All -Format DrawIo, HtmlTabs, Csv -Offline
```

### Taking the results out

The report files are self-contained, so you can copy them to any computer. The JSON inventory can be re-assessed and redrawn elsewhere:

```powershell
Invoke-ADTD -InputFile .\ADTD-contoso.com-20260927-1015.json -All -Format HtmlTabs, Markdown
```

> The files list account names, server names and security weaknesses. Store and share them like any other sensitive security document.
