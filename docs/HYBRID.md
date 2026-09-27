# Hybrid identity readiness and the upgrade plan

[Back to README](../README.md)

ADTD Modern answers three questions about moving an on-premises Active Directory to a Microsoft Entra ID hybrid (and eventually cloud-first) design:

1. **What do we have today?** This covers topology, health and security, plus anything already connected to Microsoft Entra ID.
2. **What is on-premises AD missing** compared with a current Microsoft hybrid identity design?
3. **In what order should we fix and modernise it?**

## What ADTD detects

Everything below is read over LDAP with a normal user account:

| Capability | Evidence in Active Directory | Report shows |
|---|---|---|
| Microsoft Entra Connect Sync | `MSOL_*` or `ADSyncMSA*` accounts. The MSOL description names the sync server | Present, with account and server (finding X02) |
| Microsoft Entra Cloud Sync | `pGMSA_*` gMSAs used by provisioning agents | Present, with agent accounts |
| No sync | Neither of the above | Missing (X01) |
| Tenant | `azureADName` / `azureADId` keywords on the device registration SCP | Tenant name on the hybrid drawing |
| Microsoft Entra hybrid join | Device registration SCP in the configuration partition | Present or Missing (X06) |
| Seamless SSO | `AZUREADSSOACC` computer: key age and encryption types | Key older than 30 days (S31), RC4 (S17) |
| Microsoft Entra Kerberos | `AzureADKerberos` object per domain | Present, partial or missing (X07) |
| AD FS | DKM container `CN=ADFS,CN=Microsoft,CN=Program Data,<domain>` | Migrate to cloud auth (X03) |
| Entra Password Protection | DC agent service connection points | Missing (X08) |
| Windows LAPS | Schema attributes and each computer's password expiry | S24 / S25 / S26 |
| UPN readiness | UPN suffixes of enabled users, and users without a UPN | X04 / X05 |
| Exchange | Exchange servers, versions, roles, sites | H17 and the Exchange Online target |

These can't be seen from AD, so the report marks them "not detectable" and puts them in the check-by-hand list:
- Conditional Access and MFA
- Defender for Identity sensors
- Break-glass accounts
- LDAP signing and channel binding, SMB signing, NTLM settings, and Print Spooler on DCs

## How the target topology is chosen

`Get-AdtdTopologyPlan` builds the recommendations from the inventory:

- **Domain controllers:** every DC on Windows Server 2025, with the unsupported ones listed first. At least two writable DCs per domain.
- **Sites:** hub-and-spoke site links. Remove sites that have no subnets and no DCs.
- **Forest design:** if there is more than one domain, consider consolidating child domains to shrink the Tier 0 footprint.
- **Trusts:** review external and forest trusts. Cloud Sync can sync disconnected forests, which can replace trusts that exist only for collaboration.
- **Sync engine:**
  - **Connect Sync** if a domain has more than 150,000 objects, which is over Microsoft's Cloud Sync limit. Also Connect Sync if you need device sync for hybrid join, or advanced sync rules.
  - Otherwise **Cloud Sync**, with agents on two or more servers.
  - If Connect Sync is already in place, keep it for now and review the [decision guide](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide).
- **Authentication:** password hash sync with Conditional Access and MFA. Retire AD FS through [Staged Rollout](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-staged-rollout). Use Windows Hello for Business with [cloud Kerberos trust](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust) and FIDO2 keys.
- **Devices:** hybrid join existing PCs. Enrol new PCs as Microsoft Entra joined with Intune and Autopilot. Manage local admin passwords with Windows LAPS.
- **Security operations:** Defender for Identity sensors on DCs, AD FS, AD CS and sync servers. Tier 0 model and privileged access workstations.
- **Applications:** Kerberos and header-based web apps through Entra application proxy or Private Access. File shares to SharePoint, OneDrive or Azure Files.
- **Exchange:** move mailboxes to Exchange Online. Keep only Exchange Server SE, or the management tools, for recipient management.

## The roadmap

Every finding has a phase in the catalog ([FINDINGS.md](FINDINGS.md)). ADTD adds a few standard tasks to each phase:

| Phase | Goal | Typical content |
|---|---|---|
| 1 Stabilise and secure (0–3 months) | Close what attackers use first | Unsupported DCs, FRS, single-DC domains, krbtgt, Tier 0 clean-up, Kerberoastable admins, AS-REP roasting, unconstrained delegation, LAPS, AD CS ESC1, Seamless SSO key, MachineAccountQuota, Defender for Identity, backups |
| 2 Modernise on-premises AD (3–6 months) | Supported, healthy AD ready for sync | DCs ending support, functional levels, site clean-up, RC4, stale accounts, password policy and Password Protection, UPNs, IdFix |
| 3 Hybrid identity (6–12 months) | Sync, cloud auth, devices, passwordless | Sync engine, AD FS retirement, hybrid join, Entra Kerberos and Windows Hello for Business, MFA and Conditional Access |
| 4 Cloud-first (12+ months) | Shrink what depends on AD | Entra join for new devices, apps to Entra ID, retire servers and domains, functional level 2025 |

## Where to find it

| Output | Content |
|---|---|
| Drawing page **Target hybrid topology** | Today, the identity bridge, and the Entra ID target, coloured by status |
| Drawing page **Upgrade roadmap** | The four phases, and the target topology |
| HTML: **Hybrid plan** tab (or section) | Gap table, target topology, roadmap with links to each finding, check-by-hand list |
| `hybrid-plan.md` (`-Format Markdown`) | The same, as a checklist you can tick off in Git or a wiki |
| `gap-analysis.csv`, `roadmap.csv` | The same, for Excel or Planner |
