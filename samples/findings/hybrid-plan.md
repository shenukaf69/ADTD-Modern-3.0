# Target topology and roadmap: contoso.com

## Suggested target topology

- **Domain controllers:** Run every DC on Windows Server 2025 (currently 2 of 6). Replace first: EMEADC1, NYDC1.
- **Domain controllers:** emea.contoso.com: add a second writable DC (has 1).
- **Sites:** Keep DCs in 4 site(s) with good connectivity; use a hub-and-spoke site-link design with the hub site(s) at the centre, and remove sites that have no subnets and no DCs.
- **Forest design:** The forest has 2 domains. Each domain adds Tier 0 servers and admins. Consider consolidating child domains into the root domain (ADMT or a third-party tool) before or while moving to Entra ID; sync works with multiple domains, but fewer is simpler and safer.
- **Trusts:** Review the 2 external/forest trust(s) (fabrikam.com, tailspin.local). Cloud Sync can sync disconnected forests to one tenant, which can replace trusts used only for collaboration.
- **Functional level:** Raise domains and the forest to Windows Server 2016 now, and to Windows Server 2025 (level 10) when the last older DC is gone.
- **Identity sync:** Sync engine: keep Connect Sync for now; move to Cloud Sync when you no longer need device sync for hybrid join or advanced sync rules. Fix UPNs first (1 users on non-routable suffixes).
- **Authentication:** Password hash sync as the sign-in method, with Conditional Access and MFA. Move off AD FS with Staged Rollout, then decommission it. Use Windows Hello for Business with cloud Kerberos trust and FIDO2 keys for passwordless sign-in.
- **Devices:** Hybrid join existing domain-joined Windows PCs; enrol new PCs as Microsoft Entra joined with Intune and Autopilot, so the number of domain-joined clients shrinks over time. Manage local admin passwords with Windows LAPS.
- **Security operations:** Deploy Defender for Identity sensors on all DCs, AD FS, AD CS and sync servers; apply the Tier 0 model with separate admin accounts and privileged access workstations.
- **Applications:** Publish internal web apps that use Kerberos or header authentication through Microsoft Entra application proxy or Private Access; move file shares to SharePoint/OneDrive or Azure Files with Entra Kerberos.
- **Exchange:** Complete the move to Exchange Online, then keep only Exchange Server SE (or the management tools) for recipient management while AD is the source of authority.

## What on-premises AD has, and what is missing

| Capability | Status | Evidence | Recommendation | Priority |
|---|---|---|---|---|
| Supported domain controllers | Partial | 4 of 6 DCs supported for at least 12 more months | All DCs on Windows Server 2022/2025 | High |
| Modern functional level | Present | Windows Server 2016 | Windows Server 2016 now; 2025 once every DC runs 2025 | Medium |
| SYSVOL on DFS Replication | Missing | contoso.com: DFSR; emea.contoso.com: FRS | DFSR in every domain | High |
| AD Recycle Bin | Missing |  | Enable it | Medium |
| Windows LAPS | Present |  | Windows LAPS with encryption; back up to Entra ID for Entra-joined devices | High |
| Directory sync to Microsoft Entra ID | Present | Connect Sync: contoso.com\MSOL_1a2b3c4d5e6f (server SYNC01) | Cloud Sync (or Connect Sync where its extra features are needed) | Low |
| Routable UPNs matching email | Partial | 1 users on non-routable suffixes | UPN = primary email on a verified domain | High |
| Cloud authentication (no AD FS) | Missing | AD FS container in contoso.com | Password hash sync + Conditional Access + MFA | Medium |
| Microsoft Entra hybrid join | Present | SCP points to contoso.onmicrosoft.com | Hybrid join existing PCs; Entra join + Intune + Autopilot for new PCs | Medium |
| Microsoft Entra Kerberos (cloud Kerberos trust) | Partial | Missing in emea.contoso.com | Enables Windows Hello for Business and FIDO2 keys for on-premises access | Medium |
| Seamless SSO | Present |  | Only needed for devices that are not hybrid or Entra joined; roll its key every 30 days | Low |
| Entra Password Protection on DCs | Missing |  | Block banned and breached passwords on-premises | Medium |
| Defender for Identity | Not detectable |  | Sensors on every DC, AD FS, AD CS and Entra Connect server | High |
| Conditional Access and MFA | Not detectable |  | Require phishing-resistant MFA for admins and MFA for all users | High |
| Exchange | On-premises | 3 server(s) | Exchange Online; keep Exchange SE or management tools only for recipient management | Medium |
| Certificate services | On-premises | 1 CA(s), 1 risky template(s) | Treat AD CS as Tier 0; cloud Kerberos trust removes the need for WHfB certificates | Medium |

## Roadmap

### Phase 1: Stabilise and secure

_Close the critical gaps attackers use first. (0-3 months)_

- [ ] [S02] krbtgt password is old
- [ ] [S05] Privileged accounts have a service principal name (Kerberoastable)
- [ ] [S10] Accounts do not require Kerberos pre-authentication (AS-REP roasting)
- [ ] [S12] Unconstrained Kerberos delegation on non-DC accounts
- [ ] [S27] Computers run an unsupported Windows version
- [ ] [S30] Certificate templates let requesters choose the subject (possible ESC1)
- [ ] [S31] Seamless SSO key has not been rolled over for more than 30 days
- [ ] [H01] Domain controllers run an unsupported operating system
- [ ] [H06] SYSVOL still replicates with FRS
- [ ] [H07] A domain has only one writable domain controller
- [ ] [H11] A site is not in any site link
- [ ] [H17] Exchange servers are out of support
- [ ] [S01] External trust without SID filtering
- [ ] [S03] Too many accounts are domain or enterprise administrators
- [ ] [S04] Schema Admins or Enterprise Admins have permanent members
- [ ] [S06] Privileged accounts are not protected against delegation
- [ ] [S08] Privileged accounts are not being used
- [ ] [S09] Operator groups have members
- [ ] [S14] Accounts that do not need a password
- [ ] [S22] Any user can join computers to the domain (MachineAccountQuota)
- [ ] [S28] The Guest account is enabled
- [ ] [S29] Pre-Windows 2000 Compatible Access contains Anonymous or Everyone
- [ ] [H09] The Active Directory Recycle Bin is not enabled
- [ ] Deploy Defender for Identity sensors and review its security assessments
- [ ] Confirm offline DC backups and a tested forest recovery plan

### Phase 2: Modernise on-premises AD

_Supported, healthy, well-designed AD ready for sync. (3-6 months)_

- [ ] [S07] Privileged accounts with old or non-expiring passwords
- [ ] [S11] User accounts with service principal names (Kerberoastable)
- [ ] [S17] Accounts limited to RC4 Kerberos encryption
- [ ] [S21] Accounts with SID history
- [ ] [S23] Default domain password policy is weak
- [ ] [S26] Some computers have no LAPS password
- [ ] [H02] Domain controller support ends within 12 months
- [ ] [H04] Forest or domain functional level is below Windows Server 2016
- [ ] [X04] Users have non-routable UPN suffixes
- [ ] [S18] Enabled user accounts that have not signed in for 90 days
- [ ] [S19] Enabled computer accounts that have not signed in for 90 days
- [ ] [S32] DnsAdmins has members
- [ ] [H12] A site has no subnets
- [ ] [H13] A subnet is not assigned to a site
- [ ] [H16] Manually created or disabled replication connections
- [ ] [X05] Enabled users without a UPN
- [ ] [X08] Microsoft Entra Password Protection is not deployed on domain controllers
- [ ] Run IdFix and clean up duplicate or invalid attributes

### Phase 3: Hybrid identity with Microsoft Entra ID

_Sync, cloud authentication, devices and passwordless. (6-12 months)_

- [ ] [X03] AD FS is (or was) deployed
- [ ] [S20] User accounts with passwords that never expire
- [ ] [X02] Microsoft Entra Connect Sync is in use
- [ ] [X07] Microsoft Entra Kerberos (cloud Kerberos trust) is not set up
- [ ] Enable password hash sync, Conditional Access and MFA for all users
- [ ] Windows Hello for Business with cloud Kerberos trust

### Phase 4: Cloud-first and reduce on-premises

_Shrink what depends on AD. (12+ months)_

- [ ] New devices Microsoft Entra joined with Intune and Autopilot
- [ ] Move apps to Entra ID (SAML/OIDC), app proxy or Private Access
- [ ] Retire servers and domains that no longer have a purpose
- [ ] Raise to the Windows Server 2025 functional level after the last pre-2025 DC is gone

## Check by hand (not visible over LDAP)

- [ ] LDAP signing and LDAP channel binding are required on all domain controllers - Blocks NTLM relay to LDAP. ([reference](https://learn.microsoft.com/windows-server/identity/ad-ds/ldap-signing))
- [ ] SMB signing is required and SMBv1 is removed - Blocks relay and old exploits. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure))
- [ ] The Print Spooler service is disabled on domain controllers - Prevents coerced authentication of DC accounts. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure#disable-print-spooler-service-on-domain-controllers))
- [ ] NTLMv1 and LM are blocked (LmCompatibilityLevel 5) - NTLMv1 hashes can be cracked or relayed easily. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure))
- [ ] Microsoft Defender for Identity sensors run on every DC, AD FS, AD CS and Entra Connect server - Detects attacks on AD and adds identity posture assessments. ([reference](https://learn.microsoft.com/defender-for-identity/deploy/deploy-defender-identity))
- [ ] System-state backups of at least two DCs per domain, kept offline, and a tested forest recovery plan - Ransomware targets AD first. ([reference](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-guide))
- [ ] Tier 0 admins use separate accounts, privileged access workstations and phishing-resistant MFA - Stops credential theft from everyday devices. ([reference](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model))
- [ ] Emergency access (break-glass) accounts exist in Microsoft Entra ID and are excluded from Conditional Access - Keeps you in control if MFA or federation fails. ([reference](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access))
- [ ] Entra Connect / Cloud Sync agent servers are managed as Tier 0 - They can change passwords and read hashes for every synced user. ([reference](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide))
