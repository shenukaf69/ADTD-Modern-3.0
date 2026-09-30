# Findings catalog

Every check ADTD Modern runs, with its severity, what it looks at, why it matters, how to fix it and the Microsoft guidance behind it. Generated from `src/ADTD.Assessment.ps1` by `tools/Update-FindingsDoc.ps1`; do not edit by hand.

IDs: **H** = health and topology, **S** = security, **X** = hybrid identity (Microsoft Entra ID) readiness. The roadmap phase (1-4) decides where the finding lands in the upgrade roadmap.

| ID | Severity | Area | Check | Phase |
|---|---|---|---|---|
| [H01](#h01) | High | Domain controllers | Domain controllers run an unsupported operating system | 1 |
| [H02](#h02) | Medium | Domain controllers | Domain controller support ends within 12 months | 2 |
| [H03](#h03) | Low | Domain controllers | Some domain controllers' operating system could not be read | 1 |
| [H04](#h04) | Medium | Forest | Forest or domain functional level is below Windows Server 2016 | 2 |
| [H05](#h05) | Low | Forest | All DCs run Windows Server 2025 but the forest is not at the 2025 level | 4 |
| [H06](#h06) | High | Domains | SYSVOL still replicates with FRS | 1 |
| [H07](#h07) | High | Domains | A domain has only one writable domain controller | 1 |
| [H08](#h08) | Medium | Domains | A domain could not be read | 1 |
| [H09](#h09) | Medium | Forest | The Active Directory Recycle Bin is not enabled | 1 |
| [H10](#h10) | Low | Forest | Tombstone lifetime is shorter than 180 days | 2 |
| [H11](#h11) | High | Sites | A site is not in any site link | 1 |
| [H12](#h12) | Low | Sites | A site has no subnets | 2 |
| [H13](#h13) | Low | Sites | A subnet is not assigned to a site | 2 |
| [H14](#h14) | Low | Sites | A site link has fewer than two sites | 2 |
| [H15](#h15) | Medium | Sites | A site link uses SMTP replication | 2 |
| [H16](#h16) | Low | Replication | Manually created or disabled replication connections | 2 |
| [H17](#h17) | High | Exchange | Exchange servers are out of support | 1 |
| [H18](#h18) | Low | Trusts | Downlevel (NT4-style) trusts exist | 3 |
| [S01](#s01) | Medium | Trusts | External trust without SID filtering | 1 |
| [S02](#s02) | High | Kerberos | krbtgt password is old | 1 |
| [S03](#s03) | Medium | Privileged access | Too many accounts are domain or enterprise administrators | 1 |
| [S04](#s04) | Medium | Privileged access | Schema Admins or Enterprise Admins have permanent members | 1 |
| [S05](#s05) | High | Privileged access | Privileged accounts have a service principal name (Kerberoastable) | 1 |
| [S06](#s06) | Medium | Privileged access | Privileged accounts are not protected against delegation | 1 |
| [S07](#s07) | Medium | Privileged access | Privileged accounts with old or non-expiring passwords | 2 |
| [S08](#s08) | Medium | Privileged access | Privileged accounts are not being used | 1 |
| [S09](#s09) | Medium | Privileged access | Operator groups have members | 1 |
| [S10](#s10) | High | Kerberos | Accounts do not require Kerberos pre-authentication (AS-REP roasting) | 1 |
| [S11](#s11) | Medium | Kerberos | User accounts with service principal names (Kerberoastable) | 2 |
| [S12](#s12) | High | Kerberos | Unconstrained Kerberos delegation on non-DC accounts | 1 |
| [S13](#s13) | Medium | Kerberos | Accounts trusted to authenticate for delegation (protocol transition) | 2 |
| [S14](#s14) | Medium | Accounts | Accounts that do not need a password | 1 |
| [S15](#s15) | High | Accounts | Passwords stored with reversible encryption | 1 |
| [S16](#s16) | High | Kerberos | Accounts limited to DES encryption | 1 |
| [S17](#s17) | Medium | Kerberos | Accounts limited to RC4 Kerberos encryption | 2 |
| [S18](#s18) | Low | Accounts | Enabled user accounts that have not signed in for 90 days | 2 |
| [S19](#s19) | Low | Accounts | Enabled computer accounts that have not signed in for 90 days | 2 |
| [S20](#s20) | Low | Accounts | User accounts with passwords that never expire | 3 |
| [S21](#s21) | Medium | Accounts | Accounts with SID history | 2 |
| [S22](#s22) | Medium | Domain settings | Any user can join computers to the domain (MachineAccountQuota) | 1 |
| [S23](#s23) | Medium | Domain settings | Default domain password policy is weak | 2 |
| [S24](#s24) | High | Local admin passwords | No LAPS is deployed | 1 |
| [S25](#s25) | Medium | Local admin passwords | Only legacy Microsoft LAPS is deployed | 2 |
| [S26](#s26) | Medium | Local admin passwords | Some computers have no LAPS password | 2 |
| [S27](#s27) | High | Devices | Computers run an unsupported Windows version | 1 |
| [S28](#s28) | Medium | Accounts | The Guest account is enabled | 1 |
| [S29](#s29) | Medium | Domain settings | Pre-Windows 2000 Compatible Access contains Anonymous or Everyone | 1 |
| [S30](#s30) | High | Certificate services | Certificate templates let requesters choose the subject (possible ESC1) | 1 |
| [S31](#s31) | Medium | Hybrid identity | Seamless SSO key has not been rolled over for more than 30 days | 1 |
| [S32](#s32) | Low | Privileged access | DnsAdmins has members | 2 |
| [X01](#x01) | Medium | Directory sync | No Microsoft Entra Connect or Cloud Sync detected | 2 |
| [X02](#x02) | Low | Directory sync | Microsoft Entra Connect Sync is in use | 3 |
| [X03](#x03) | Medium | Authentication | AD FS is (or was) deployed | 3 |
| [X04](#x04) | Medium | Directory sync | Users have non-routable UPN suffixes | 2 |
| [X05](#x05) | Low | Directory sync | Enabled users without a UPN | 2 |
| [X06](#x06) | Low | Devices | Microsoft Entra hybrid join is not configured | 3 |
| [X07](#x07) | Low | Authentication | Microsoft Entra Kerberos (cloud Kerberos trust) is not set up | 3 |
| [X08](#x08) | Low | Authentication | Microsoft Entra Password Protection is not deployed on domain controllers | 2 |

## Health and topology

### H01

**Domain controllers run an unsupported operating system** · High · Domain controllers · roadmap phase 1

*Why it matters:* Out-of-support servers get no security updates. A domain controller holds every password hash in the domain, so one unpatched DC exposes the whole forest.

*How to fix:*

1. Build replacement domain controllers on Windows Server 2025 (or 2022) in the same sites.
2. Move any FSMO roles off the old DCs (Move-ADDirectoryServerOperationMasterRole).
3. Update DNS forwarders, DHCP options and hard-coded DC names that point at the old servers.
4. Demote the old DCs with Uninstall-ADDSDomainController and clean up their metadata.
5. Raise the domain and forest functional levels when the last old DC is gone.

*References:* [Microsoft product lifecycle search](https://learn.microsoft.com/lifecycle/products/) · [What's new in Windows Server 2025](https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025)

### H02

**Domain controller support ends within 12 months** · Medium · Domain controllers · roadmap phase 2

*Why it matters:* Plan now so the replacement is finished before security updates stop.

*How to fix:*

1. Add Windows Server 2025 domain controllers to each affected site.
2. Transfer roles and demote the old DCs before the end-of-support date.

*References:* [Microsoft product lifecycle search](https://learn.microsoft.com/lifecycle/products/)

### H03

**Some domain controllers' operating system could not be read** · Low · Domain controllers · roadmap phase 1

*Why it matters:* ADTD reads the OS from the computer object through a global catalog. Missing values usually mean a permissions or connectivity problem.

*How to fix:*

1. Run ADTD against a global catalog in the same site, or with an account that can read computer objects.

### H04

**Forest or domain functional level is below Windows Server 2016** · Medium · Forest · roadmap phase 2

*Why it matters:* Lower levels block newer security features, such as privileged access management with time-bound group membership and automatic NTLM secret rolling for smart-card users.

*How to fix:*

1. Make sure every DC in the domain runs Windows Server 2016 or later.
2. Raise each domain level (Set-ADDomainMode), then the forest level (Set-ADForestMode).

*References:* [Forest and domain functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/active-directory-functional-levels) · [Raise domain and forest functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/raise-domain-forest-functional-levels)

### H05

**All DCs run Windows Server 2025 but the forest is not at the 2025 level** · Low · Forest · roadmap phase 4

*Why it matters:* Level 10 enables Windows Server 2025 features such as the 32k database page size optional feature.

*How to fix:*

1. Raise the domain functional levels to Windows Server 2025, then the forest level.
2. Consider enabling the 32k database page size optional feature after testing (it can't be turned off).

*References:* [Forest and domain functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/active-directory-functional-levels) · [Raise domain and forest functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/raise-domain-forest-functional-levels) · [What's new in Windows Server 2025](https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025)

### H06

**SYSVOL still replicates with FRS** · High · Domains · roadmap phase 1

*Why it matters:* FRS is removed from Windows Server 2019 and later. You cannot add a newer domain controller to this domain until SYSVOL uses DFS Replication.

*How to fix:*

1. Check that all DCs replicate cleanly (repadmin /replsummary).
2. Run dfsrmig /setglobalstate 1, 2 and 3 in turn, waiting for every DC to reach each state (dfsrmig /getmigrationstate).
3. Confirm SYSVOL is shared from the SYSVOL_DFSR folder on every DC.

*References:* [Migrate SYSVOL replication to DFS Replication](https://learn.microsoft.com/windows-server/storage/dfs-replication/migrate-sysvol-to-dfsr)

### H07

**A domain has only one writable domain controller** · High · Domains · roadmap phase 1

*Why it matters:* If that server fails, the domain is down and must be restored from backup.

*How to fix:*

1. Add a second writable domain controller, preferably in a different site or host.
2. Make sure both are global catalogs and DNS servers.
3. Keep a tested system-state backup of at least one DC per domain.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H08

**A domain could not be read** · Medium · Domains · roadmap phase 1

*Why it matters:* That domain is missing from the drawing and from the security checks.

*How to fix:*

1. Run ADTD with an account from that domain or forest, or use -Server to point at one of its domain controllers.

### H09

**The Active Directory Recycle Bin is not enabled** · Medium · Forest · roadmap phase 1

*Why it matters:* Without it, restoring a deleted user, group or OU needs an authoritative restore from backup.

*How to fix:*

1. Run: Enable-ADOptionalFeature "Recycle Bin Feature" -Scope ForestOrConfigurationSet -Target <forest>.
2. It cannot be turned off, and objects deleted before it was enabled cannot be recovered with it.

*References:* [Enable and use Active Directory Recycle Bin](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/adac/active-directory-recycle-bin)

### H10

**Tombstone lifetime is shorter than 180 days** · Low · Forest · roadmap phase 2

*Why it matters:* Backups older than the tombstone lifetime cannot be restored, and DCs offline longer than that must be rebuilt.

*How to fix:*

1. Set tombstoneLifetime to 180 on CN=Directory Service,CN=Windows NT,CN=Services in the configuration partition.

*References:* [Enable and use Active Directory Recycle Bin](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/adac/active-directory-recycle-bin)

### H11

**A site is not in any site link** · High · Sites · roadmap phase 1

*Why it matters:* Domain controllers in that site cannot replicate with other sites.

*How to fix:*

1. Add the site to an IP site link (Active Directory Sites and Services > Inter-Site Transports > IP).

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H12

**A site has no subnets** · Low · Sites · roadmap phase 2

*Why it matters:* Clients never land in that site, so its domain controllers only serve clients by accident.

*How to fix:*

1. Assign the IP subnets of that location to the site, or delete the site if it is no longer used.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H13

**A subnet is not assigned to a site** · Low · Sites · roadmap phase 2

*Why it matters:* Clients in that subnet can pick any domain controller, including ones across slow WAN links.

*How to fix:*

1. Assign each subnet to the site of its location.
2. Check the Netlogon.log on DCs for NO_CLIENT_SITE entries to find subnets that are still missing.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H14

**A site link has fewer than two sites** · Low · Sites · roadmap phase 2

*Why it matters:* A link with one site does nothing and confuses troubleshooting.

*How to fix:*

1. Add the missing site or delete the site link.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H15

**A site link uses SMTP replication** · Medium · Sites · roadmap phase 2

*Why it matters:* SMTP replication is deprecated and cannot replicate domain partitions.

*How to fix:*

1. Recreate the link under the IP transport and delete the SMTP link.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H16

**Manually created or disabled replication connections** · Low · Replication · roadmap phase 2

*Why it matters:* Manual connections are not maintained by the KCC and often outlive the reason they were created. Disabled connections can hide replication gaps.

*How to fix:*

1. Review each manual connection; delete it unless there is a documented reason, and let the KCC build the topology.
2. Check replication health with repadmin /replsummary and repadmin /showrepl.

*References:* [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)

### H17

**Exchange servers are out of support** · High · Exchange · roadmap phase 1

*Why it matters:* Unsupported Exchange servers get no security updates and are a common attack entry point.

*How to fix:*

1. Upgrade to Exchange Server Subscription Edition, or move mailboxes to Exchange Online.
2. If all mailboxes are in Exchange Online, keep only the Exchange Management Tools for recipient management and remove the last servers.

*References:* [Exchange Server supportability matrix](https://learn.microsoft.com/exchange/plan-and-deploy/supportability-matrix) · [Exchange Server 2019 and 2016 end of support roadmap](https://learn.microsoft.com/troubleshoot/exchange/administration/exchange-2019-2016-end-of-support)

### H18

**Downlevel (NT4-style) trusts exist** · Low · Trusts · roadmap phase 3

*Why it matters:* Downlevel trusts use NTLM only and usually point at systems that no longer exist.

*How to fix:*

1. Confirm the trusted domain still exists and is needed; remove the trust if not.

## Security

### S01

**External trust without SID filtering** · Medium · Trusts · roadmap phase 1

*Why it matters:* Without SID filtering an administrator in the trusted domain can add privileged SIDs to SID history and become an admin in your domain.

*How to fix:*

1. Turn quarantine back on: netdom trust <trusting> /domain:<trusted> /quarantine:yes.
2. Only leave it off during a migration that needs SID history, and turn it on afterwards.

*References:* [netdom trust (/quarantine and /enablesidhistory)](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust)

### S02

**krbtgt password is old** · High · Kerberos · roadmap phase 1

*Why it matters:* The krbtgt key signs every Kerberos ticket. If it was ever stolen, attackers can forge tickets (Golden Ticket) until it is changed twice.

*How to fix:*

1. Reset the krbtgt password twice, at least 10 hours apart (longer than the maximum ticket lifetime), using Microsoft's documented procedure or script.
2. Check replication between the two resets.
3. Repeat at least every 180 days.

*References:* [Change password for krbtgt account (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#change-password-for-krbtgt-account) · [Reset the krbtgt password](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-reset-the-krbtgt-password)

### S03

**Too many accounts are domain or enterprise administrators** · Medium · Privileged access · roadmap phase 1

*Why it matters:* Every Tier 0 account is a path to full control of the forest. Microsoft suggests fewer than five people with Domain Admins-equivalent access and no service accounts in Domain Admins.

*How to fix:*

1. List every member, including nested groups, and remove anyone who doesn't need permanent Tier 0 rights.
2. Delegate day-to-day tasks with scoped groups instead of Domain Admins.
3. Use separate admin accounts and privileged access workstations for Tier 0.

*References:* [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model) · [Enterprise access model](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model)

### S04

**Schema Admins or Enterprise Admins have permanent members** · Medium · Privileged access · roadmap phase 1

*Why it matters:* These groups are only needed for schema changes and forest-wide changes, and should normally be empty.

*How to fix:*

1. Remove all members, and add an account only for the duration of a planned change.

*References:* [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)

### S05

**Privileged accounts have a service principal name (Kerberoastable)** · High · Privileged access · roadmap phase 1

*Why it matters:* Any domain user can request a ticket for an account with an SPN and crack its password offline. If it is an admin, cracking it gives Tier 0 access.

*How to fix:*

1. Move the service to a group managed service account (gMSA) and remove the SPN from the admin account.
2. If the account must stay, give it a long random password (25+ characters) and remove it from privileged groups.

*References:* [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes) · [Identify service accounts in privileged groups](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#identify-service-accounts-in-privileged-groups)

### S06

**Privileged accounts are not protected against delegation** · Medium · Privileged access · roadmap phase 1

*Why it matters:* Admin accounts that are not marked "sensitive and cannot be delegated" (or in Protected Users) can be impersonated through Kerberos delegation.

*How to fix:*

1. Add human admin accounts to the Protected Users group (test first: it blocks NTLM, DES/RC4 and delegation for them).
2. For other privileged accounts, set "Account is sensitive and cannot be delegated".

*References:* [Ensure privileged accounts are not delegated](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#ensure-privileged-accounts-are-not-delegated) · [Protected Users security group](https://learn.microsoft.com/windows-server/security/credentials-protection-and-management/protected-users-security-group)

### S07

**Privileged accounts with old or non-expiring passwords** · Medium · Privileged access · roadmap phase 2

*Why it matters:* Old admin passwords are more likely to have been exposed and reused.

*How to fix:*

1. Rotate the passwords of these accounts.
2. Remove "password never expires" from admin accounts, or better, use long passphrases with MFA-backed access (smart card, Windows Hello for Business).

*References:* [Change password of built-in domain Administrator account (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#change-password-of-built-in-domain-administrator-account) · [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)

### S08

**Privileged accounts are not being used** · Medium · Privileged access · roadmap phase 1

*Why it matters:* Enabled admin accounts that no one signs in with are an easy target nobody watches.

*How to fix:*

1. Disable these accounts, wait a few weeks for anything that breaks, then delete them.

*References:* [Dormant entities in sensitive groups (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#dormant-entities-in-sensitive-groups) · [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#remove-stale-active-directory-accounts)

### S09

**Operator groups have members** · Medium · Privileged access · roadmap phase 1

*Why it matters:* Account, Server, Backup and Print Operators can log on to DCs or edit privileged objects, so they are effectively Tier 0.

*How to fix:*

1. Empty these groups and delegate the specific tasks with scoped permissions instead.

*References:* [Locate accounts in built-in Operator Groups (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#locate-accounts-in-built-in-operator-groups) · [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)

### S10

**Accounts do not require Kerberos pre-authentication (AS-REP roasting)** · High · Kerberos · roadmap phase 1

*Why it matters:* Anyone can request encrypted data for these accounts without knowing the password, and crack it offline.

*How to fix:*

1. Remove "Do not require Kerberos preauthentication" from each account (Set-ADAccountControl -DoesNotRequirePreAuth $false).

*References:* [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)

### S11

**User accounts with service principal names (Kerberoastable)** · Medium · Kerberos · roadmap phase 2

*Why it matters:* Service accounts with SPNs can be attacked offline; weak or old passwords are cracked quickly.

*How to fix:*

1. Replace these accounts with group managed service accounts (gMSA), which have 120-character rotating passwords.
2. Where that is not possible, set passwords of 25+ random characters and enable AES encryption on the account.

*References:* [Investigate and protect service accounts](https://learn.microsoft.com/defender-for-identity/service-account-discovery) · [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)

### S12

**Unconstrained Kerberos delegation on non-DC accounts** · High · Kerberos · roadmap phase 1

*Why it matters:* A server trusted for unconstrained delegation stores the TGT of everyone who connects to it. Compromise of that server exposes those users, including admins.

*How to fix:*

1. Change each account to constrained or resource-based constrained delegation to the specific services it needs.
2. If delegation is not needed, turn it off.

*References:* [Unsecure Kerberos delegation (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-kerberos-delegation)

### S13

**Accounts trusted to authenticate for delegation (protocol transition)** · Medium · Kerberos · roadmap phase 2

*Why it matters:* Protocol transition lets the service get tickets for any user to its target services without that user's password.

*How to fix:*

1. Confirm each one is needed and limited to the right target services; remove it otherwise.

*References:* [Unsecure Kerberos delegation (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-kerberos-delegation)

### S14

**Accounts that do not need a password** · Medium · Accounts · roadmap phase 1

*Why it matters:* PASSWD_NOTREQD lets the account have an empty password.

*How to fix:*

1. Remove the flag (Set-ADUser -PasswordNotRequired $false) and set a password.

*References:* [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)

### S15

**Passwords stored with reversible encryption** · High · Accounts · roadmap phase 1

*Why it matters:* The password can be decrypted by anyone who reads the directory database or a backup.

*How to fix:*

1. Remove "Store password using reversible encryption" from the accounts and the password policy, then reset their passwords.

*References:* [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)

### S16

**Accounts limited to DES encryption** · High · Kerberos · roadmap phase 1

*Why it matters:* DES can be broken in hours; modern Windows disables it.

*How to fix:*

1. Remove "Use Kerberos DES encryption types for this account" and reset the password.

*References:* [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)

### S17

**Accounts limited to RC4 Kerberos encryption** · Medium · Kerberos · roadmap phase 2

*Why it matters:* Windows Server updates from July 2026 change the default Kerberos encryption type from RC4 to AES-256. Accounts limited to RC4 are easier to crack and may fail to authenticate.

*How to fix:*

1. Enable AES 128/256 on each account (msDS-SupportedEncryptionTypes = 0x18 or 0x1C during migration) and reset the password so AES keys exist.
2. For the AZUREADSSOACC account, roll over its key first, then switch it to AES.

*References:* [Detect and remediate RC4 usage in Kerberos](https://learn.microsoft.com/windows-server/security/kerberos/detect-remediate-rc4-kerberos) · [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes) · [Seamless SSO technical deep dive (AES and RC4)](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works)

### S18

**Enabled user accounts that have not signed in for 90 days** · Low · Accounts · roadmap phase 2

*Why it matters:* Unused accounts are rarely watched and are a common foothold.

*How to fix:*

1. Disable the accounts, move them to a quarantine OU, and delete them after your retention period.
2. Automate this with a lifecycle process or Microsoft Entra ID Governance.

*References:* [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#remove-stale-active-directory-accounts)

### S19

**Enabled computer accounts that have not signed in for 90 days** · Low · Accounts · roadmap phase 2

*Why it matters:* Stale computer accounts clutter the directory and can be reused by attackers.

*How to fix:*

1. Disable, then delete, computer accounts that no longer exist.

*References:* [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#remove-stale-active-directory-accounts)

### S20

**User accounts with passwords that never expire** · Low · Accounts · roadmap phase 3

*Why it matters:* Long-lived passwords are more likely to be leaked and reused. Microsoft no longer recommends forced periodic change for users with MFA, but "never expires" on shared or service accounts hides old passwords.

*How to fix:*

1. Review the list: convert service accounts to gMSA, and for people rely on MFA and banned-password checks instead of the flag.

*References:* [Password policy recommendations](https://learn.microsoft.com/microsoft-365/admin/misc/password-policy-recommendations)

### S21

**Accounts with SID history** · Medium · Accounts · roadmap phase 2

*Why it matters:* SID history left after a migration can silently grant access, and is a known privilege-escalation technique.

*How to fix:*

1. After confirming resource ACLs have been re-permissioned, clear sIDHistory from migrated accounts.

*References:* [Unsecure SID History attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-sid-history-attributes) · [netdom trust (/quarantine and /enablesidhistory)](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust)

### S22

**Any user can join computers to the domain (MachineAccountQuota)** · Medium · Domain settings · roadmap phase 1

*Why it matters:* By default each user can create 10 computer accounts, which attackers use for relay and delegation attacks.

*How to fix:*

1. Set ms-DS-MachineAccountQuota to 0 on the domain.
2. Delegate "Create computer objects" on specific OUs to the people or tools that join devices.

*References:* [Default limit to number of workstations a user can join to the domain](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/default-workstation-numbers-join-domain) · [Active Directory domain join permissions](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/active-directory-domain-join-permissions)

### S23

**Default domain password policy is weak** · Medium · Domain settings · roadmap phase 2

*Why it matters:* Short passwords and no lockout make password spraying easy.

*How to fix:*

1. Set a minimum length of at least 14 characters (fine-grained policies for admins can require more).
2. Set an account lockout threshold (for example 10 attempts) to slow down guessing.
3. Add Microsoft Entra Password Protection to block common and breached passwords on-premises.

*References:* [Password policy recommendations](https://learn.microsoft.com/microsoft-365/admin/misc/password-policy-recommendations) · [Plan and deploy on-premises Microsoft Entra Password Protection](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy)

### S24

**No LAPS is deployed** · High · Local admin passwords · roadmap phase 1

*Why it matters:* Without LAPS, local administrator passwords are usually identical on many computers, so one stolen hash lets an attacker move to all of them.

*How to fix:*

1. Deploy Windows LAPS (built into Windows 10/11 and Server 2019+ with current updates): run Update-LapsADSchema, grant computers permission with Set-LapsADComputerSelfPermission, and enable it with Group Policy or Intune.
2. Back up passwords to Microsoft Entra ID for Entra-joined devices.

*References:* [What is Windows LAPS?](https://learn.microsoft.com/windows-server/identity/laps/laps-overview) · [Microsoft LAPS usage (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#microsoft-laps-usage)

### S25

**Only legacy Microsoft LAPS is deployed** · Medium · Local admin passwords · roadmap phase 2

*Why it matters:* Legacy LAPS stores passwords in clear text attributes and is no longer developed.

*How to fix:*

1. Extend the schema for Windows LAPS and move policies to Windows LAPS; you can run it in legacy-emulation mode during the move.
2. Enable password encryption and DSRM password backup.

*References:* [What is Windows LAPS?](https://learn.microsoft.com/windows-server/identity/laps/laps-overview)

### S26

**Some computers have no LAPS password** · Medium · Local admin passwords · roadmap phase 2

*Why it matters:* Computers without a managed password still share local admin credentials.

*How to fix:*

1. Check that the LAPS policy reaches these computers (event log Microsoft-Windows-LAPS/Operational).
2. Retire or fix computers that no longer apply policy.

*References:* [What is Windows LAPS?](https://learn.microsoft.com/windows-server/identity/laps/laps-overview) · [Microsoft LAPS usage (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#microsoft-laps-usage)

### S27

**Computers run an unsupported Windows version** · High · Devices · roadmap phase 1

*Why it matters:* Unsupported systems get no security fixes and are the easiest way in.

*How to fix:*

1. Upgrade or retire these computers; isolate any that must stay on a restricted network segment.

*References:* [Microsoft product lifecycle search](https://learn.microsoft.com/lifecycle/products/)

### S28

**The Guest account is enabled** · Medium · Accounts · roadmap phase 1

*Why it matters:* Guest allows unauthenticated-style access to resources shared with Everyone.

*How to fix:*

1. Disable the Guest account.

### S29

**Pre-Windows 2000 Compatible Access contains Anonymous or Everyone** · Medium · Domain settings · roadmap phase 1

*Why it matters:* Lets anonymous users read user and group information from the directory.

*How to fix:*

1. Remove Anonymous Logon and Everyone from the group; leave Authenticated Users only if old applications need it.

*References:* [Identity infrastructure security assessments](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure)

### S30

**Certificate templates let requesters choose the subject (possible ESC1)** · High · Certificate services · roadmap phase 1

*Why it matters:* If low-privileged users can enroll, anyone can get a certificate that signs in as a domain admin.

*How to fix:*

1. Check enrollment permissions on each template listed. ADTD does not read ACLs.
2. Turn off "Supply in the request", or require CA manager approval, or remove authentication EKUs, or stop publishing the template.

*References:* [Certificate template assessments (ESC1)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/certificates#prevent-users-to-request-a-certificate-valid-for-arbitrary-users-based-on-the-certificate-template-esc1-preview) · [Certificate templates with Any Purpose or no EKU (ESC2)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/certificates#edit-overly-permissive-certificate-template-with-privileged-eku-any-purpose-eku-or-no-eku-esc2)

### S31

**Seamless SSO key has not been rolled over for more than 30 days** · Medium · Hybrid identity · roadmap phase 1

*Why it matters:* The AZUREADSSOACC key lets anyone who steals it create Kerberos tickets that sign in as any synced user to Microsoft Entra ID.

*How to fix:*

1. Roll over the key with Update-AzureADSSOForest on the Entra Connect server (once per forest).
2. Schedule the rollover every 30 days.
3. Switch the account to AES after rolling the key.

*References:* [Roll over the Seamless SSO Kerberos decryption key](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-faq) · [Seamless SSO technical deep dive (AES and RC4)](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works)

### S32

**DnsAdmins has members** · Low · Privileged access · roadmap phase 2

*Why it matters:* DnsAdmins members can load code on domain controllers running DNS.

*How to fix:*

1. Treat DnsAdmins as Tier 0: keep it empty or limited to Tier 0 admins.

*References:* [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)

## Hybrid identity readiness

### X01

**No Microsoft Entra Connect or Cloud Sync detected** · Medium · Directory sync · roadmap phase 2

*Why it matters:* Without sync, users have separate cloud and on-premises identities, and you can't use single sign-on, Conditional Access for on-premises users, or cloud security signals.

*How to fix:*

1. Clean up the directory first (IdFix, routable UPNs, duplicate proxyAddresses).
2. Choose Microsoft Entra Cloud Sync unless you need features only Connect Sync has (device sync for hybrid join, advanced sync rules, more than 150,000 objects per domain).
3. Enable password hash synchronization, even if you also use another sign-in method, for leaked credential detection and as a backup.

*References:* [What is Microsoft Entra Cloud Sync?](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/what-is-cloud-sync) · [Connect Sync to Cloud Sync decision guide](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide) · [Prepare for directory synchronization to Microsoft 365 (IdFix)](https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization)

### X02

**Microsoft Entra Connect Sync is in use** · Low · Directory sync · roadmap phase 3

*Why it matters:* Connect Sync is a full sync server that must be patched and protected as Tier 0. Microsoft is putting new sync features into Cloud Sync.

*How to fix:*

1. Keep Connect Sync on the latest version and protect the server as Tier 0.
2. Review the decision guide: move to Cloud Sync if you don't need device sync, advanced sync rules or more than 150,000 objects per domain.

*References:* [Connect Sync to Cloud Sync decision guide](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide) · [What is Microsoft Entra Cloud Sync?](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/what-is-cloud-sync)

### X03

**AD FS is (or was) deployed** · Medium · Authentication · roadmap phase 3

*Why it matters:* AD FS adds servers to patch and protect as Tier 0, and makes cloud sign-in depend on on-premises availability. Microsoft recommends password hash sync for cloud authentication.

*How to fix:*

1. Inventory the relying parties in AD FS; move apps to Microsoft Entra ID enterprise apps.
2. Enable password hash sync and test with Staged Rollout.
3. Convert the federated domains to managed, then decommission AD FS and its DKM container.

*References:* [Migrate from federation to cloud authentication](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication) · [Migrate to cloud authentication using Staged Rollout](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-staged-rollout)

### X04

**Users have non-routable UPN suffixes** · Medium · Directory sync · roadmap phase 2

*Why it matters:* Users with UPNs such as user@contoso.local sync to Microsoft Entra ID as user@<tenant>.onmicrosoft.com, so their sign-in name differs from their email.

*How to fix:*

1. Add a routable UPN suffix that you have verified in Microsoft 365 (Active Directory Domains and Trusts > Properties > UPN Suffixes).
2. Change user UPNs to the new suffix (ideally matching their primary email).
3. Run IdFix to find other sync blockers.

*References:* [Prepare a non-routable domain for directory synchronization](https://learn.microsoft.com/microsoft-365/enterprise/prepare-a-non-routable-domain-for-directory-synchronization) · [Prepare for directory synchronization to Microsoft 365 (IdFix)](https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization)

### X05

**Enabled users without a UPN** · Low · Directory sync · roadmap phase 2

*Why it matters:* Accounts without a userPrincipalName sync with a generated name and are harder to manage.

*How to fix:*

1. Set a UPN on each account that will be synced.

*References:* [Prepare for directory synchronization to Microsoft 365 (IdFix)](https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization)

### X06

**Microsoft Entra hybrid join is not configured** · Low · Devices · roadmap phase 3

*Why it matters:* Domain-joined Windows devices can't get a Primary Refresh Token, so Conditional Access device rules and SSO to cloud apps don't apply to them.

*How to fix:*

1. Configure the service connection point (Entra Connect device options, or PowerShell).
2. For new devices, prefer Microsoft Entra join with Intune and Windows Autopilot instead of domain join.

*References:* [Configure Microsoft Entra hybrid join: service connection point](https://learn.microsoft.com/entra/identity/devices/hybrid-join-manual#configure-a-service-connection-point)

### X07

**Microsoft Entra Kerberos (cloud Kerberos trust) is not set up** · Low · Authentication · roadmap phase 3

*Why it matters:* Cloud Kerberos trust is the recommended way to deploy Windows Hello for Business and FIDO2 security keys for on-premises access, without a PKI.

*How to fix:*

1. Create the Microsoft Entra Kerberos server object for each domain (Set-AzureADKerberosServer).
2. Enable Windows Hello for Business with "Use cloud trust for on-premises authentication".

*References:* [Windows Hello for Business cloud Kerberos trust](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust)

### X08

**Microsoft Entra Password Protection is not deployed on domain controllers** · Low · Authentication · roadmap phase 2

*Why it matters:* On-premises password changes aren't checked against the global banned password list.

*How to fix:*

1. Install the Password Protection proxy on member servers and the DC agent on every DC; start in audit mode, then enforce.

*References:* [Plan and deploy on-premises Microsoft Entra Password Protection](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy)

## Checked by hand

These can't be read over LDAP, so the report lists them as a checklist:

- **LDAP signing and LDAP channel binding are required on all domain controllers**: Blocks NTLM relay to LDAP. ([reference](https://learn.microsoft.com/windows-server/identity/ad-ds/ldap-signing))
- **SMB signing is required and SMBv1 is removed**: Blocks relay and old exploits. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure))
- **The Print Spooler service is disabled on domain controllers**: Prevents coerced authentication of DC accounts. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure#disable-print-spooler-service-on-domain-controllers))
- **NTLMv1 and LM are blocked (LmCompatibilityLevel 5)**: NTLMv1 hashes can be cracked or relayed easily. ([reference](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure))
- **Microsoft Defender for Identity sensors run on every DC, AD FS, AD CS and Entra Connect server**: Detects attacks on AD and adds identity posture assessments. ([reference](https://learn.microsoft.com/defender-for-identity/deploy/deploy-defender-identity))
- **System-state backups of at least two DCs per domain, kept offline, and a tested forest recovery plan**: Ransomware targets AD first. ([reference](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-guide))
- **Tier 0 admins use separate accounts, privileged access workstations and phishing-resistant MFA**: Stops credential theft from everyday devices. ([reference](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model))
- **Emergency access (break-glass) accounts exist in Microsoft Entra ID and are excluded from Conditional Access**: Keeps you in control if MFA or federation fails. ([reference](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access))
- **Entra Connect / Cloud Sync agent servers are managed as Tier 0**: They can change passwords and read hashes for every synced user. ([reference](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide))
