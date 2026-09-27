# Installing ADTD Modern

[Back to README](../README.md)

## Requirements

| Needed | Details |
|---|---|
| Windows | 64-bit Windows 10/11 or Windows Server 2016 or later |
| PowerShell | Windows PowerShell 5.1 (built in) or PowerShell 7 |
| Network | LDAP (TCP 389) and global catalog (TCP 3268) to a domain controller |
| Account | Any domain user. ADTD only reads. For another forest, use `-Server` and `-Credential` |
| Viewer | **draw.io desktop** or **draw.io on the web** (both free). Visio 2013+ is optional |
| Not needed | RSAT, the ActiveDirectory PowerShell module, .NET 2.0, Visio |

## Option 1: MSI (recommended, needs admin)

1. Download [`dist/ADTD_Modern_Setup_3.0.2.msi`](../dist/ADTD_Modern_Setup_3.0.2.msi).
2. Right-click it → **Properties** → tick **Unblock** → **OK**. The MSI isn't code-signed yet.
3. Double-click it and approve the UAC prompt.

The MSI installs ADTD Modern for all users in **`C:\Program Files\WindowsPowerShell\Modules\ADTD`**. This folder holds the app (`ADTD.exe`, with the ADTD Modern icon) and the PowerShell module, so `Invoke-ADTD` works in every PowerShell window.

When the install finishes, ADTD Modern opens a **welcome screen** that shows where it was installed and offers:
- **Add a shortcut to my desktop**
- **Pin to the taskbar** (on Windows 10 1809+ and 11, Windows only allows this by hand; the screen shows the two clicks it takes)
- **Open ADTD Modern now**

You can change these later in **About**. Silent installs (`/qn`) skip the welcome screen; it then appears the first time someone opens ADTD Modern.

The MSI also adds these Start menu shortcuts:

| Shortcut | Opens |
|---|---|
| **ADTD Modern** | The app (`ADTD.exe`) |
| **ADTD Modern (PowerShell)** | PowerShell with the commands loaded and examples shown |
| **ADTD Modern - Prerequisites (draw.io, Visio)** | The prerequisites checker and installer |
| **ADTD Modern - Read me** | The installed read-me |

Other ways to install and remove it:
- **Silent install:** `msiexec /i ADTD_Modern_Setup_3.0.2.msi /qn`
- **Upgrade:** install a newer MSI, which replaces the old version automatically.
- **Find the install folder:** **About → Installed in**, or Settings → Apps → **ADTD Modern 3.0** (shows the icon, publisher Shenuka Fernando and the project links).
- **Remove:** Settings → Apps → **ADTD Modern 3.0**, or `msiexec /x ADTD_Modern_Setup_3.0.2.msi /qn`.

## Option 2: current user, no admin rights

Download or clone the repository, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\Install-ADTD.ps1
```

This copies ADTD Modern to your Documents folder (`Documents\WindowsPowerShell\Modules\ADTD`, plus a copy for PowerShell 7), adds **ADTD Modern** and **ADTD Modern - Prerequisites** to your Start menu, and opens the welcome screen (install location, desktop shortcut, pin to taskbar).

- `-DesktopShortcut` adds the desktop shortcut straight away.
- `-NoWelcome` skips the welcome screen.
- `-Uninstall` removes ADTD Modern, its Start menu folder and the desktop shortcut.

## Option 3: run without installing

```powershell
.\src\ADTD.exe                                                     # the app
powershell -ExecutionPolicy Bypass -File .\src\ADTD.ps1            # window, through PowerShell
powershell -ExecutionPolicy Bypass -File .\src\ADTD.ps1 -All -Open # command line
```

## Prerequisites: draw.io desktop, draw.io web, PowerShell 7, Visio

Run **Start → ADTD Modern - Prerequisites**, or:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup\Install-Prerequisites.ps1
```

It shows a status table:
- Windows version and PowerShell versions
- Domain membership, and LDAP / global catalog reachability to a DC
- draw.io desktop, and whether draw.io on the web is reachable
- winget and Visio
- The ADTD module, execution policy, and whether you are running as admin

Then it offers a menu:

| Choice | Switch | What happens |
|---|---|---|
| 1 Install draw.io desktop | `-DrawIoDesktop` | Installs with winget (`JGraph.Draw`, per user if you are not admin). If winget isn't available, it downloads the latest Windows installer from [github.com/jgraph/drawio-desktop](https://github.com/jgraph/drawio-desktop/releases), checks its Authenticode signature, and runs it silently. ADTD then opens drawings in the desktop app. |
| 2 Use draw.io on the web | `-DrawIoWeb` | Nothing to install. Checks that `app.diagrams.net` is reachable and sets ADTD to open drawings there. |
| 3 Install PowerShell 7 | `-PowerShell7` | winget `Microsoft.PowerShell`. Optional, because Windows PowerShell 5.1 is enough. |
| 4 Install Visio desktop | `-Visio` | Optional, and **needs a Visio licence**. Downloads Microsoft's Office Deployment Tool, checks its signature, and installs Visio with `setup.exe /configure`. Details below. |

Non-interactive examples:

```powershell
.\Install-Prerequisites.ps1 -CheckOnly
.\Install-Prerequisites.ps1 -DrawIoDesktop -Quiet
.\Install-Prerequisites.ps1 -DrawIoWeb
.\Install-Prerequisites.ps1 -Visio -VisioEdition Plan2                  # subscription
.\Install-Prerequisites.ps1 -Visio -VisioEdition Professional2024 -VisioProductKey XXXXX-...   # volume licence (MAK)
```

### Visio details (optional)

| Edition | Office Deployment Tool product ID | Licence |
|---|---|---|
| `Plan2` (default) | `VisioProRetail` | Visio Plan 2 assigned to the user in Microsoft 365. Sign in after install |
| `Professional2024` | `VisioPro2024Volume`, channel `PerpetualVL2024` | Volume licence, activated with KMS or MAK (`-VisioProductKey`) |
| `Standard2024` | `VisioStd2024Volume`, channel `PerpetualVL2024` | Volume licence |

Things to know:
- The script needs an elevated PowerShell.
- It matches the bitness of Office if Office is already installed.
- It shows the Office installer UI, where you accept the licence terms.
- Setup logs are written to `%TEMP%`.

Microsoft's guidance: [Deployment guide for Visio](https://learn.microsoft.com/microsoft-365-apps/deploy/deployment-guide-for-visio).

You don't need Visio to use ADTD: draw.io opens every drawing. If you need a `.vsdx` file without Visio, open the `.drawio` file in draw.io and choose **File → Export as → VSDX**.

## Execution policy and signing

`ADTD.exe` and the Start menu shortcuts run with `-ExecutionPolicy Bypass` for their own process only; they don't change the machine policy. Files installed by the MSI don't carry the "downloaded from the internet" mark, so `RemoteSigned` machines can run `Invoke-ADTD` directly. If your organisation enforces `AllSigned`, sign the scripts with your code-signing certificate: see [DEVELOPMENT.md](DEVELOPMENT.md#signing).

## Troubleshooting

| Problem | Fix |
|---|---|
| `Could not read RootDSE` | The computer can't reach a DC. Use `-Server dc01.contoso.com`, check TCP 389, or run from a domain-joined machine |
| Some DCs show "OS could not be read" | The global catalog (TCP 3268) isn't reachable. Run ADTD in a site with a GC |
| A domain shows "could not be read" | Your account can't reach that domain. Run again from that forest, or with `-Credential` |
| draw.io web link doesn't open | Your browser or proxy blocks app.diagrams.net. Install draw.io desktop instead |
| Report shows "viewer could not load" | No internet access. The rest of the report works; open the `.drawio` file in draw.io desktop |
| Visio output fails | Visio isn't installed, or runs as a different user. Use draw.io, or install Visio with the prerequisites script |
| Taskbar shows the PowerShell icon | You started `ADTD.ps1`. Start **ADTD Modern** from the Start menu or run `ADTD.exe` instead |
| `ADTD.exe` says Windows PowerShell 5.1 is missing | Turn on the Windows PowerShell 2.0/5.1 feature, or use `ADTD.ps1` with PowerShell 7 |
| Large domain is slow | The security scan reads every user and computer once. Use `-SkipSecurityScan` for a topology-only run |
