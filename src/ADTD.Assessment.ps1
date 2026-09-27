# ADTD Modern - assessment: findings catalog, health/security/hybrid checks, gap analysis and the
# suggested target topology and roadmap. Pure functions over the inventory, so a saved JSON
# inventory can be re-assessed offline.

function New-AdtdRef { param([string]$Title, [string]$Url) [pscustomobject]@{ Title = $Title; Url = $Url } }

$script:Refs = @{
    FunctionalLevels = New-AdtdRef 'Forest and domain functional levels' 'https://learn.microsoft.com/windows-server/identity/ad-ds/active-directory-functional-levels'
    WhatsNew2025     = New-AdtdRef "What's new in Windows Server 2025" 'https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025'
    SysvolDfsr       = New-AdtdRef 'Migrate SYSVOL replication to DFS Replication' 'https://learn.microsoft.com/windows-server/storage/dfs-replication/migrate-sysvol-to-dfsr'
    RecycleBin       = New-AdtdRef 'Enable and use Active Directory Recycle Bin' 'https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/adac/active-directory-recycle-bin'
    Sites            = New-AdtdRef 'Designing the site topology' 'https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology'
    Krbtgt           = New-AdtdRef 'Change password for krbtgt account (Defender for Identity)' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#change-password-for-krbtgt-account'
    KrbtgtReset      = New-AdtdRef 'Reset the krbtgt password' 'https://learn.microsoft.com/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-reset-the-krbtgt-password'
    Delegation       = New-AdtdRef 'Unsecure Kerberos delegation (Defender for Identity)' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-kerberos-delegation'
    NotDelegated     = New-AdtdRef 'Ensure privileged accounts are not delegated' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#ensure-privileged-accounts-are-not-delegated'
    AccountAttrs     = New-AdtdRef 'Unsecure account attributes (Defender for Identity)' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes'
    Stale            = New-AdtdRef 'Remove stale Active Directory accounts' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts'
    PrivServiceAcct  = New-AdtdRef 'Identify service accounts in privileged groups' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#identify-service-accounts-in-privileged-groups'
    ServiceAccounts  = New-AdtdRef 'Investigate and protect service accounts' 'https://learn.microsoft.com/defender-for-identity/service-account-discovery'
    ProtectedUsers   = New-AdtdRef 'Protected Users security group' 'https://learn.microsoft.com/windows-server/security/credentials-protection-and-management/protected-users-security-group'
    TierModel        = New-AdtdRef 'Tier model for Active Directory Domain Services' 'https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model'
    AccessModel      = New-AdtdRef 'Enterprise access model' 'https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model'
    Laps             = New-AdtdRef 'What is Windows LAPS?' 'https://learn.microsoft.com/windows-server/identity/laps/laps-overview'
    Adcs             = New-AdtdRef 'Certificate template assessments (ESC1)' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/certificates#prevent-users-to-request-a-certificate-valid-for-arbitrary-users-based-on-the-certificate-template-esc1-preview'
    MaqDefault       = New-AdtdRef 'Default limit to number of workstations a user can join to the domain' 'https://learn.microsoft.com/troubleshoot/windows-server/active-directory/default-workstation-numbers-join-domain'
    Mdi              = New-AdtdRef 'Microsoft Defender for Identity deployment overview' 'https://learn.microsoft.com/defender-for-identity/deploy/deploy-defender-identity'
    MdiInfra         = New-AdtdRef 'Identity infrastructure security assessments' 'https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure'
    SsoFaq           = New-AdtdRef 'Roll over the Seamless SSO Kerberos decryption key' 'https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-faq'
    SsoHowItWorks    = New-AdtdRef 'Seamless SSO technical deep dive (AES and RC4)' 'https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works'
    FedToCloud       = New-AdtdRef 'Migrate from federation to cloud authentication' 'https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication'
    StagedRollout    = New-AdtdRef 'Migrate to cloud authentication using Staged Rollout' 'https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-staged-rollout'
    CloudSync        = New-AdtdRef 'What is Microsoft Entra Cloud Sync?' 'https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/what-is-cloud-sync'
    SyncDecision     = New-AdtdRef 'Connect Sync to Cloud Sync decision guide' 'https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide'
    NonRoutable      = New-AdtdRef 'Prepare a non-routable domain for directory synchronization' 'https://learn.microsoft.com/microsoft-365/enterprise/prepare-a-non-routable-domain-for-directory-synchronization'
    PrepSync         = New-AdtdRef 'Prepare for directory synchronization to Microsoft 365 (IdFix)' 'https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization'
    HybridJoin       = New-AdtdRef 'Configure Microsoft Entra hybrid join: service connection point' 'https://learn.microsoft.com/entra/identity/devices/hybrid-join-manual#configure-a-service-connection-point'
    CloudKerberos    = New-AdtdRef 'Windows Hello for Business cloud Kerberos trust' 'https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust'
    PwdProtection    = New-AdtdRef 'Plan and deploy on-premises Microsoft Entra Password Protection' 'https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy'
    AppProxy         = New-AdtdRef 'Microsoft Entra application proxy' 'https://learn.microsoft.com/entra/identity/app-proxy/overview-what-is-app-proxy'
    ExchangeHybrid   = New-AdtdRef 'Exchange Server 2019 and 2016 end of support roadmap' 'https://learn.microsoft.com/troubleshoot/exchange/administration/exchange-2019-2016-end-of-support'
    ExchangeLifecycle = New-AdtdRef 'Exchange Server supportability matrix' 'https://learn.microsoft.com/exchange/plan-and-deploy/supportability-matrix'
    Trusts           = New-AdtdRef 'netdom trust (/quarantine and /enablesidhistory)' 'https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust'
    Lifecycle        = New-AdtdRef 'Microsoft product lifecycle search' 'https://learn.microsoft.com/lifecycle/products/'
    PwdPolicy        = New-AdtdRef 'Password policy recommendations' 'https://learn.microsoft.com/microsoft-365/admin/misc/password-policy-recommendations'
}

# ---------------------------------------------------------------- Catalog
# Each check: Severity, Category (Health | Security | Hybrid), Area, Title, Risk, Steps, Refs, Phase (roadmap 1-4).
$script:AdtdChecks = [ordered]@{}
function Register-AdtdCheck {
    param([string]$Id, [string]$Severity, [string]$Category, [string]$Area, [string]$Title, [string]$Risk, [string[]]$Steps, [string[]]$Refs, [int]$Phase = 1)
    $script:AdtdChecks[$Id] = [pscustomobject]@{ Id = $Id; Severity = $Severity; Category = $Category; Area = $Area; Title = $Title; Risk = $Risk; Steps = $Steps; Refs = @($Refs | ForEach-Object { $script:Refs[$_] }); Phase = $Phase }
}

# ---- Health
Register-AdtdCheck 'H01' High Health 'Domain controllers' 'Domain controllers run an unsupported operating system' `
    'Out-of-support servers get no security updates. A domain controller holds every password hash in the domain, so one unpatched DC exposes the whole forest.' `
    @('Build replacement domain controllers on Windows Server 2025 (or 2022) in the same sites.', 'Move any FSMO roles off the old DCs (Move-ADDirectoryServerOperationMasterRole).', 'Update DNS forwarders, DHCP options and hard-coded DC names that point at the old servers.', 'Demote the old DCs with Uninstall-ADDSDomainController and clean up their metadata.', 'Raise the domain and forest functional levels when the last old DC is gone.') `
    @('Lifecycle', 'WhatsNew2025') 1
Register-AdtdCheck 'H02' Medium Health 'Domain controllers' 'Domain controller support ends within 12 months' `
    'Plan now so the replacement is finished before security updates stop.' `
    @('Add Windows Server 2025 domain controllers to each affected site.', 'Transfer roles and demote the old DCs before the end-of-support date.') @('Lifecycle') 2
Register-AdtdCheck 'H03' Low Health 'Domain controllers' "Some domain controllers' operating system could not be read" `
    'ADTD reads the OS from the computer object through a global catalog. Missing values usually mean a permissions or connectivity problem.' `
    @('Run ADTD against a global catalog in the same site, or with an account that can read computer objects.') @() 1
Register-AdtdCheck 'H04' Medium Health 'Forest' 'Forest or domain functional level is below Windows Server 2016' `
    'Lower levels block newer security features, such as privileged access management with time-bound group membership and automatic NTLM secret rolling for smart-card users.' `
    @('Make sure every DC in the domain runs Windows Server 2016 or later.', 'Raise each domain level (Set-ADDomainMode), then the forest level (Set-ADForestMode).') @('FunctionalLevels') 2
Register-AdtdCheck 'H05' Low Health 'Forest' 'All DCs run Windows Server 2025 but the forest is not at the 2025 level' `
    'Level 10 enables Windows Server 2025 features such as the 32k database page size optional feature.' `
    @('Raise the domain functional levels to Windows Server 2025, then the forest level.', 'Consider enabling the 32k database page size optional feature after testing (it can''t be turned off).') @('FunctionalLevels', 'WhatsNew2025') 4
Register-AdtdCheck 'H06' High Health 'Domains' 'SYSVOL still replicates with FRS' `
    'FRS is removed from Windows Server 2019 and later. You cannot add a newer domain controller to this domain until SYSVOL uses DFS Replication.' `
    @('Check that all DCs replicate cleanly (repadmin /replsummary).', 'Run dfsrmig /setglobalstate 1, 2 and 3 in turn, waiting for every DC to reach each state (dfsrmig /getmigrationstate).', 'Confirm SYSVOL is shared from the SYSVOL_DFSR folder on every DC.') @('SysvolDfsr') 1
Register-AdtdCheck 'H07' High Health 'Domains' 'A domain has only one writable domain controller' `
    'If that server fails, the domain is down and must be restored from backup.' `
    @('Add a second writable domain controller, preferably in a different site or host.', 'Make sure both are global catalogs and DNS servers.', 'Keep a tested system-state backup of at least one DC per domain.') @('Sites') 1
Register-AdtdCheck 'H08' Medium Health 'Domains' 'A domain could not be read' `
    'That domain is missing from the drawing and from the security checks.' `
    @('Run ADTD with an account from that domain or forest, or use -Server to point at one of its domain controllers.') @() 1
Register-AdtdCheck 'H09' Medium Health 'Forest' 'The Active Directory Recycle Bin is not enabled' `
    'Without it, restoring a deleted user, group or OU needs an authoritative restore from backup.' `
    @('Run: Enable-ADOptionalFeature "Recycle Bin Feature" -Scope ForestOrConfigurationSet -Target <forest>.', 'It cannot be turned off, and objects deleted before it was enabled cannot be recovered with it.') @('RecycleBin') 1
Register-AdtdCheck 'H10' Low Health 'Forest' 'Tombstone lifetime is shorter than 180 days' `
    'Backups older than the tombstone lifetime cannot be restored, and DCs offline longer than that must be rebuilt.' `
    @('Set tombstoneLifetime to 180 on CN=Directory Service,CN=Windows NT,CN=Services in the configuration partition.') @('RecycleBin') 2
Register-AdtdCheck 'H11' High Health 'Sites' 'A site is not in any site link' `
    'Domain controllers in that site cannot replicate with other sites.' `
    @('Add the site to an IP site link (Active Directory Sites and Services > Inter-Site Transports > IP).') @('Sites') 1
Register-AdtdCheck 'H12' Low Health 'Sites' 'A site has no subnets' `
    'Clients never land in that site, so its domain controllers only serve clients by accident.' `
    @('Assign the IP subnets of that location to the site, or delete the site if it is no longer used.') @('Sites') 2
Register-AdtdCheck 'H13' Low Health 'Sites' 'A subnet is not assigned to a site' `
    'Clients in that subnet can pick any domain controller, including ones across slow WAN links.' `
    @('Assign each subnet to the site of its location.', 'Check the Netlogon.log on DCs for NO_CLIENT_SITE entries to find subnets that are still missing.') @('Sites') 2
Register-AdtdCheck 'H14' Low Health 'Sites' 'A site link has fewer than two sites' `
    'A link with one site does nothing and confuses troubleshooting.' `
    @('Add the missing site or delete the site link.') @('Sites') 2
Register-AdtdCheck 'H15' Medium Health 'Sites' 'A site link uses SMTP replication' `
    'SMTP replication is deprecated and cannot replicate domain partitions.' `
    @('Recreate the link under the IP transport and delete the SMTP link.') @('Sites') 2
Register-AdtdCheck 'H16' Low Health 'Replication' 'Manually created or disabled replication connections' `
    'Manual connections are not maintained by the KCC and often outlive the reason they were created. Disabled connections can hide replication gaps.' `
    @('Review each manual connection; delete it unless there is a documented reason, and let the KCC build the topology.', 'Check replication health with repadmin /replsummary and repadmin /showrepl.') @('Sites') 2
Register-AdtdCheck 'H17' High Health 'Exchange' 'Exchange servers are out of support' `
    'Unsupported Exchange servers get no security updates and are a common attack entry point.' `
    @('Upgrade to Exchange Server Subscription Edition, or move mailboxes to Exchange Online.', 'If all mailboxes are in Exchange Online, keep only the Exchange Management Tools for recipient management and remove the last servers.') @('ExchangeLifecycle', 'ExchangeHybrid') 1
Register-AdtdCheck 'H18' Low Health 'Trusts' 'Downlevel (NT4-style) trusts exist' `
    'Downlevel trusts use NTLM only and usually point at systems that no longer exist.' `
    @('Confirm the trusted domain still exists and is needed; remove the trust if not.') @() 3

# ---- Security
Register-AdtdCheck 'S01' Medium Security 'Trusts' 'External trust without SID filtering' `
    'Without SID filtering an administrator in the trusted domain can add privileged SIDs to SID history and become an admin in your domain.' `
    @('Turn quarantine back on: netdom trust <trusting> /domain:<trusted> /quarantine:yes.', 'Only leave it off during a migration that needs SID history, and turn it on afterwards.') @('Trusts') 1
Register-AdtdCheck 'S02' High Security 'Kerberos' 'krbtgt password is old' `
    'The krbtgt key signs every Kerberos ticket. If it was ever stolen, attackers can forge tickets (Golden Ticket) until it is changed twice.' `
    @('Reset the krbtgt password twice, at least 10 hours apart (longer than the maximum ticket lifetime), using Microsoft''s documented procedure or script.', 'Check replication between the two resets.', 'Repeat at least every 180 days.') @('Krbtgt', 'KrbtgtReset') 1
Register-AdtdCheck 'S03' Medium Security 'Privileged access' 'Too many accounts are domain or enterprise administrators' `
    'Every Tier 0 account is a path to full control of the forest. Microsoft suggests fewer than five people with Domain Admins-equivalent access and no service accounts in Domain Admins.' `
    @('List every member, including nested groups, and remove anyone who doesn''t need permanent Tier 0 rights.', 'Delegate day-to-day tasks with scoped groups instead of Domain Admins.', 'Use separate admin accounts and privileged access workstations for Tier 0.') @('TierModel', 'AccessModel') 1
Register-AdtdCheck 'S04' Medium Security 'Privileged access' 'Schema Admins or Enterprise Admins have permanent members' `
    'These groups are only needed for schema changes and forest-wide changes, and should normally be empty.' `
    @('Remove all members, and add an account only for the duration of a planned change.') @('TierModel') 1
Register-AdtdCheck 'S05' High Security 'Privileged access' 'Privileged accounts have a service principal name (Kerberoastable)' `
    'Any domain user can request a ticket for an account with an SPN and crack its password offline. If it is an admin, cracking it gives Tier 0 access.' `
    @('Move the service to a group managed service account (gMSA) and remove the SPN from the admin account.', 'If the account must stay, give it a long random password (25+ characters) and remove it from privileged groups.') @('AccountAttrs', 'PrivServiceAcct') 1
Register-AdtdCheck 'S06' Medium Security 'Privileged access' 'Privileged accounts are not protected against delegation' `
    'Admin accounts that are not marked "sensitive and cannot be delegated" (or in Protected Users) can be impersonated through Kerberos delegation.' `
    @('Add human admin accounts to the Protected Users group (test first: it blocks NTLM, DES/RC4 and delegation for them).', 'For other privileged accounts, set "Account is sensitive and cannot be delegated".') @('NotDelegated', 'ProtectedUsers') 1
Register-AdtdCheck 'S07' Medium Security 'Privileged access' 'Privileged accounts with old or non-expiring passwords' `
    'Old admin passwords are more likely to have been exposed and reused.' `
    @('Rotate the passwords of these accounts.', 'Remove "password never expires" from admin accounts, or better, use long passphrases with MFA-backed access (smart card, Windows Hello for Business).') @('TierModel') 2
Register-AdtdCheck 'S08' Medium Security 'Privileged access' 'Privileged accounts are not being used' `
    'Enabled admin accounts that no one signs in with are an easy target nobody watches.' `
    @('Disable these accounts, wait a few weeks for anything that breaks, then delete them.') @('Stale') 1
Register-AdtdCheck 'S09' Medium Security 'Privileged access' 'Operator groups have members' `
    'Account, Server, Backup and Print Operators can log on to DCs or edit privileged objects, so they are effectively Tier 0.' `
    @('Empty these groups and delegate the specific tasks with scoped permissions instead.') @('TierModel') 1
Register-AdtdCheck 'S10' High Security 'Kerberos' 'Accounts do not require Kerberos pre-authentication (AS-REP roasting)' `
    'Anyone can request encrypted data for these accounts without knowing the password, and crack it offline.' `
    @('Remove "Do not require Kerberos preauthentication" from each account (Set-ADAccountControl -DoesNotRequirePreAuth $false).') @('AccountAttrs') 1
Register-AdtdCheck 'S11' Medium Security 'Kerberos' 'User accounts with service principal names (Kerberoastable)' `
    'Service accounts with SPNs can be attacked offline; weak or old passwords are cracked quickly.' `
    @('Replace these accounts with group managed service accounts (gMSA), which have 120-character rotating passwords.', 'Where that is not possible, set passwords of 25+ random characters and enable AES encryption on the account.') @('ServiceAccounts', 'AccountAttrs') 2
Register-AdtdCheck 'S12' High Security 'Kerberos' 'Unconstrained Kerberos delegation on non-DC accounts' `
    'A server trusted for unconstrained delegation stores the TGT of everyone who connects to it. Compromise of that server exposes those users, including admins.' `
    @('Change each account to constrained or resource-based constrained delegation to the specific services it needs.', 'If delegation is not needed, turn it off.') @('Delegation') 1
Register-AdtdCheck 'S13' Medium Security 'Kerberos' 'Accounts trusted to authenticate for delegation (protocol transition)' `
    'Protocol transition lets the service get tickets for any user to its target services without that user''s password.' `
    @('Confirm each one is needed and limited to the right target services; remove it otherwise.') @('Delegation') 2
Register-AdtdCheck 'S14' Medium Security 'Accounts' 'Accounts that do not need a password' `
    'PASSWD_NOTREQD lets the account have an empty password.' `
    @('Remove the flag (Set-ADUser -PasswordNotRequired $false) and set a password.') @('AccountAttrs') 1
Register-AdtdCheck 'S15' High Security 'Accounts' 'Passwords stored with reversible encryption' `
    'The password can be decrypted by anyone who reads the directory database or a backup.' `
    @('Remove "Store password using reversible encryption" from the accounts and the password policy, then reset their passwords.') @('AccountAttrs') 1
Register-AdtdCheck 'S16' High Security 'Kerberos' 'Accounts limited to DES encryption' `
    'DES can be broken in hours; modern Windows disables it.' `
    @('Remove "Use Kerberos DES encryption types for this account" and reset the password.') @('AccountAttrs') 1
Register-AdtdCheck 'S17' Medium Security 'Kerberos' 'Accounts limited to RC4 Kerberos encryption' `
    'Windows Server updates from July 2026 change the default Kerberos encryption type from RC4 to AES-256. Accounts limited to RC4 are easier to crack and may fail to authenticate.' `
    @('Enable AES 128/256 on each account (msDS-SupportedEncryptionTypes = 0x18 or 0x1C during migration) and reset the password so AES keys exist.', 'For the AZUREADSSOACC account, roll over its key first, then switch it to AES.') @('AccountAttrs', 'SsoHowItWorks') 2
Register-AdtdCheck 'S18' Low Security 'Accounts' 'Enabled user accounts that have not signed in for 90 days' `
    'Unused accounts are rarely watched and are a common foothold.' `
    @('Disable the accounts, move them to a quarantine OU, and delete them after your retention period.', 'Automate this with a lifecycle process or Microsoft Entra ID Governance.') @('Stale') 2
Register-AdtdCheck 'S19' Low Security 'Accounts' 'Enabled computer accounts that have not signed in for 90 days' `
    'Stale computer accounts clutter the directory and can be reused by attackers.' `
    @('Disable, then delete, computer accounts that no longer exist.') @('Stale') 2
Register-AdtdCheck 'S20' Low Security 'Accounts' 'User accounts with passwords that never expire' `
    'Long-lived passwords are more likely to be leaked and reused. Microsoft no longer recommends forced periodic change for users with MFA, but "never expires" on shared or service accounts hides old passwords.' `
    @('Review the list: convert service accounts to gMSA, and for people rely on MFA and banned-password checks instead of the flag.') @('PwdPolicy') 3
Register-AdtdCheck 'S21' Medium Security 'Accounts' 'Accounts with SID history' `
    'SID history left after a migration can silently grant access, and is a known privilege-escalation technique.' `
    @('After confirming resource ACLs have been re-permissioned, clear sIDHistory from migrated accounts.') @('Trusts') 2
Register-AdtdCheck 'S22' Medium Security 'Domain settings' 'Any user can join computers to the domain (MachineAccountQuota)' `
    'By default each user can create 10 computer accounts, which attackers use for relay and delegation attacks.' `
    @('Set ms-DS-MachineAccountQuota to 0 on the domain.', 'Delegate "Create computer objects" on specific OUs to the people or tools that join devices.') @('MaqDefault') 1
Register-AdtdCheck 'S23' Medium Security 'Domain settings' 'Default domain password policy is weak' `
    'Short passwords and no lockout make password spraying easy.' `
    @('Set a minimum length of at least 14 characters (fine-grained policies for admins can require more).', 'Set an account lockout threshold (for example 10 attempts) to slow down guessing.', 'Add Microsoft Entra Password Protection to block common and breached passwords on-premises.') @('PwdPolicy', 'PwdProtection') 2
Register-AdtdCheck 'S24' High Security 'Local admin passwords' 'No LAPS is deployed' `
    'Without LAPS, local administrator passwords are usually identical on many computers, so one stolen hash lets an attacker move to all of them.' `
    @('Deploy Windows LAPS (built into Windows 10/11 and Server 2019+ with current updates): run Update-LapsADSchema, grant computers permission with Set-LapsADComputerSelfPermission, and enable it with Group Policy or Intune.', 'Back up passwords to Microsoft Entra ID for Entra-joined devices.') @('Laps') 1
Register-AdtdCheck 'S25' Medium Security 'Local admin passwords' 'Only legacy Microsoft LAPS is deployed' `
    'Legacy LAPS stores passwords in clear text attributes and is no longer developed.' `
    @('Extend the schema for Windows LAPS and move policies to Windows LAPS; you can run it in legacy-emulation mode during the move.', 'Enable password encryption and DSRM password backup.') @('Laps') 2
Register-AdtdCheck 'S26' Medium Security 'Local admin passwords' 'Some computers have no LAPS password' `
    'Computers without a managed password still share local admin credentials.' `
    @('Check that the LAPS policy reaches these computers (event log Microsoft-Windows-LAPS/Operational).', 'Retire or fix computers that no longer apply policy.') @('Laps') 2
Register-AdtdCheck 'S27' High Security 'Devices' 'Computers run an unsupported Windows version' `
    'Unsupported systems get no security fixes and are the easiest way in.' `
    @('Upgrade or retire these computers; isolate any that must stay on a restricted network segment.') @('Lifecycle') 1
Register-AdtdCheck 'S28' Medium Security 'Accounts' 'The Guest account is enabled' `
    'Guest allows unauthenticated-style access to resources shared with Everyone.' `
    @('Disable the Guest account.') @() 1
Register-AdtdCheck 'S29' Medium Security 'Domain settings' 'Pre-Windows 2000 Compatible Access contains Anonymous or Everyone' `
    'Lets anonymous users read user and group information from the directory.' `
    @('Remove Anonymous Logon and Everyone from the group; leave Authenticated Users only if old applications need it.') @('MdiInfra') 1
Register-AdtdCheck 'S30' High Security 'Certificate services' 'Certificate templates let requesters choose the subject (possible ESC1)' `
    'If low-privileged users can enroll, anyone can get a certificate that signs in as a domain admin.' `
    @('Check enrollment permissions on each template listed. ADTD does not read ACLs.', 'Turn off "Supply in the request", or require CA manager approval, or remove authentication EKUs, or stop publishing the template.') @('Adcs') 1
Register-AdtdCheck 'S31' Medium Security 'Hybrid identity' 'Seamless SSO key has not been rolled over for more than 30 days' `
    'The AZUREADSSOACC key lets anyone who steals it create Kerberos tickets that sign in as any synced user to Microsoft Entra ID.' `
    @('Roll over the key with Update-AzureADSSOForest on the Entra Connect server (once per forest).', 'Schedule the rollover every 30 days.', 'Switch the account to AES after rolling the key.') @('SsoFaq', 'SsoHowItWorks') 1
Register-AdtdCheck 'S32' Low Security 'Privileged access' 'DnsAdmins has members' `
    'DnsAdmins members can load code on domain controllers running DNS.' `
    @('Treat DnsAdmins as Tier 0: keep it empty or limited to Tier 0 admins.') @('TierModel') 2

# ---- Hybrid
Register-AdtdCheck 'X01' Medium Hybrid 'Directory sync' 'No Microsoft Entra Connect or Cloud Sync detected' `
    'Without sync, users have separate cloud and on-premises identities, and you can''t use single sign-on, Conditional Access for on-premises users, or cloud security signals.' `
    @('Clean up the directory first (IdFix, routable UPNs, duplicate proxyAddresses).', 'Choose Microsoft Entra Cloud Sync unless you need features only Connect Sync has (device sync for hybrid join, advanced sync rules, more than 150,000 objects per domain).', 'Enable password hash synchronization, even if you also use another sign-in method, for leaked credential detection and as a backup.') @('CloudSync', 'SyncDecision', 'PrepSync') 2
Register-AdtdCheck 'X02' Low Hybrid 'Directory sync' 'Microsoft Entra Connect Sync is in use' `
    'Connect Sync is a full sync server that must be patched and protected as Tier 0. Microsoft is putting new sync features into Cloud Sync.' `
    @('Keep Connect Sync on the latest version and protect the server as Tier 0.', 'Review the decision guide: move to Cloud Sync if you don''t need device sync, advanced sync rules or more than 150,000 objects per domain.') @('SyncDecision', 'CloudSync') 3
Register-AdtdCheck 'X03' Medium Hybrid 'Authentication' 'AD FS is (or was) deployed' `
    'AD FS adds servers to patch and protect as Tier 0, and makes cloud sign-in depend on on-premises availability. Microsoft recommends password hash sync for cloud authentication.' `
    @('Inventory the relying parties in AD FS; move apps to Microsoft Entra ID enterprise apps.', 'Enable password hash sync and test with Staged Rollout.', 'Convert the federated domains to managed, then decommission AD FS and its DKM container.') @('FedToCloud', 'StagedRollout') 3
Register-AdtdCheck 'X04' Medium Hybrid 'Directory sync' 'Users have non-routable UPN suffixes' `
    'Users with UPNs such as user@contoso.local sync to Microsoft Entra ID as user@<tenant>.onmicrosoft.com, so their sign-in name differs from their email.' `
    @('Add a routable UPN suffix that you have verified in Microsoft 365 (Active Directory Domains and Trusts > Properties > UPN Suffixes).', 'Change user UPNs to the new suffix (ideally matching their primary email).', 'Run IdFix to find other sync blockers.') @('NonRoutable', 'PrepSync') 2
Register-AdtdCheck 'X05' Low Hybrid 'Directory sync' 'Enabled users without a UPN' `
    'Accounts without a userPrincipalName sync with a generated name and are harder to manage.' `
    @('Set a UPN on each account that will be synced.') @('PrepSync') 2
Register-AdtdCheck 'X06' Low Hybrid 'Devices' 'Microsoft Entra hybrid join is not configured' `
    'Domain-joined Windows devices can''t get a Primary Refresh Token, so Conditional Access device rules and SSO to cloud apps don''t apply to them.' `
    @('Configure the service connection point (Entra Connect device options, or PowerShell).', 'For new devices, prefer Microsoft Entra join with Intune and Windows Autopilot instead of domain join.') @('HybridJoin') 3
Register-AdtdCheck 'X07' Low Hybrid 'Authentication' 'Microsoft Entra Kerberos (cloud Kerberos trust) is not set up' `
    'Cloud Kerberos trust is the recommended way to deploy Windows Hello for Business and FIDO2 security keys for on-premises access, without a PKI.' `
    @('Create the Microsoft Entra Kerberos server object for each domain (Set-AzureADKerberosServer).', 'Enable Windows Hello for Business with "Use cloud trust for on-premises authentication".') @('CloudKerberos') 3
Register-AdtdCheck 'X08' Low Hybrid 'Authentication' 'Microsoft Entra Password Protection is not deployed on domain controllers' `
    'On-premises password changes aren''t checked against the global banned password list.' `
    @('Install the Password Protection proxy on member servers and the DC agent on every DC; start in audit mode, then enforce.') @('PwdProtection') 2

$script:AdtdVerifyManually = @(
    [pscustomobject]@{ Item = 'LDAP signing and LDAP channel binding are required on all domain controllers'; Why = 'Blocks NTLM relay to LDAP.'; Ref = $script:Refs.MdiInfra }
    [pscustomobject]@{ Item = 'SMB signing is required and SMBv1 is removed'; Why = 'Blocks relay and old exploits.'; Ref = $script:Refs.MdiInfra }
    [pscustomobject]@{ Item = 'The Print Spooler service is disabled on domain controllers'; Why = 'Prevents coerced authentication of DC accounts.'; Ref = $script:Refs.MdiInfra }
    [pscustomobject]@{ Item = 'NTLMv1 and LM are blocked (LmCompatibilityLevel 5)'; Why = 'NTLMv1 hashes can be cracked or relayed easily.'; Ref = $script:Refs.MdiInfra }
    [pscustomobject]@{ Item = 'Microsoft Defender for Identity sensors run on every DC, AD FS, AD CS and Entra Connect server'; Why = 'Detects attacks on AD and adds identity posture assessments.'; Ref = $script:Refs.Mdi }
    [pscustomobject]@{ Item = 'System-state backups of at least two DCs per domain, kept offline, and a tested forest recovery plan'; Why = 'Ransomware targets AD first.'; Ref = $script:Refs.KrbtgtReset }
    [pscustomobject]@{ Item = 'Tier 0 admins use separate accounts, privileged access workstations and phishing-resistant MFA'; Why = 'Stops credential theft from everyday devices.'; Ref = $script:Refs.AccessModel }
    [pscustomobject]@{ Item = 'Emergency access (break-glass) accounts exist in Microsoft Entra ID and are excluded from Conditional Access'; Why = 'Keeps you in control if MFA or federation fails.'; Ref = $script:Refs.AccessModel }
    [pscustomobject]@{ Item = 'Entra Connect / Cloud Sync agent servers are managed as Tier 0'; Why = 'They can change passwords and read hashes for every synced user.'; Ref = $script:Refs.SyncDecision }
)

# ---------------------------------------------------------------- Findings

function Get-AdtdFindings {
    <# Runs every check against the inventory. Returns one finding per check that fails, with evidence. #>
    param($Inventory, [datetime]$Today = (Get-Date))
    $out = New-Object System.Collections.ArrayList
    $add = {
        param([string]$Id, [string]$Text, $Evidence, [string]$SeverityOverride)
        $c = $script:AdtdChecks[$Id]
        $ev = @($Evidence | Where-Object { $null -ne $_ -and "$_" -ne '' })
        [void]$out.Add([pscustomobject]@{
                Id = $Id; Severity = if ($SeverityOverride) { $SeverityOverride } else { $c.Severity }
                Category = $c.Category; Area = $c.Area; Title = $c.Title
                Finding = $Text
                Recommendation = $c.Steps[0]
                Risk = $c.Risk; Steps = @($c.Steps); References = @($c.Refs); Phase = $c.Phase
                EvidenceCount = $ev.Count; Evidence = @($ev | Select-Object -First $script:MaxEvidence)
            })
    }
    $names = { param($list, [int]$n = 5) $l = @($list); if (-not $l.Count) { return '' }; $s = ($l | Select-Object -First $n) -join ', '; if ($l.Count -gt $n) { $s += " and $($l.Count - $n) more" }; $s }
    $inv = $Inventory
    $dcs = @($inv.DomainControllers)

    # ---- Health
    $bad = @($dcs | Where-Object OSSupportState -eq 'Unsupported')
    if ($bad.Count) { & $add 'H01' "$($bad.Count) domain controller(s) run an unsupported OS: $(& $names ($bad | ForEach-Object { "$($_.Name) ($($_.OperatingSystem))" }))." @($bad | ForEach-Object { "$($_.Name) - $($_.OperatingSystem), support ended $($_.OSEndOfSupport), site $($_.Site), domain $($_.Domain)" }) }
    $soon = @($dcs | Where-Object OSSupportState -eq 'EndingSoon')
    if ($soon.Count) { & $add 'H02' "$($soon.Count) domain controller(s) reach end of support within 12 months: $(& $names ($soon | ForEach-Object { "$($_.Name) ($($_.OperatingSystem), $($_.OSEndOfSupport))" }))." @($soon | ForEach-Object { "$($_.Name) - $($_.OperatingSystem), support ends $($_.OSEndOfSupport)" }) }
    $unk = @($dcs | Where-Object OSSupportState -eq 'Unknown')
    if ($unk.Count) { & $add 'H03' "The OS of $($unk.Count) domain controller(s) could not be read: $(& $names ($unk | ForEach-Object Name))." @($unk | ForEach-Object Name) }

    $lowFl = @()
    if ($null -ne $inv.Forest.FunctionalLevel -and $inv.Forest.FunctionalLevel -lt $script:RecommendedMinimumLevel) { $lowFl += "Forest $($inv.Forest.Name): $($inv.Forest.FunctionalLevelName)" }
    foreach ($d in $inv.Domains) { if ($d.Reachable -and $null -ne $d.FunctionalLevel -and $d.FunctionalLevel -lt $script:RecommendedMinimumLevel) { $lowFl += "Domain $($d.Name): $($d.FunctionalLevelName)" } }
    if ($lowFl.Count) { & $add 'H04' "Functional level below Windows Server 2016: $(& $names $lowFl)." $lowFl }
    $allDcs2025 = $dcs.Count -gt 0 -and -not ($dcs | Where-Object { -not $_.OSBuild -or $_.OSBuild -lt 26100 })
    if ($allDcs2025 -and $inv.Forest.FunctionalLevel -lt $script:LatestFunctionalLevel) { & $add 'H05' "Every DC runs Windows Server 2025, but the forest is at $($inv.Forest.FunctionalLevelName)." @() }

    $frs = @($inv.Domains | Where-Object { $_.Reachable -and $_.SysvolReplication -eq 'FRS' })
    if ($frs.Count) { & $add 'H06' "SYSVOL uses FRS in: $(& $names ($frs | ForEach-Object Name))." @($frs | ForEach-Object Name) }
    $single = @($inv.Domains | Where-Object { $d = $_; $_.Reachable -and @($dcs | Where-Object { $_.Domain -eq $d.Name -and -not $_.IsReadOnly }).Count -eq 1 })
    if ($single.Count) { & $add 'H07' "Only one writable DC in: $(& $names ($single | ForEach-Object Name))." @($single | ForEach-Object { $d = $_; "$($d.Name) - $(@($dcs | Where-Object { $_.Domain -eq $d.Name -and -not $_.IsReadOnly })[0].Name)" }) }
    $unreach = @($inv.Domains | Where-Object { -not $_.Reachable })
    if ($unreach.Count) { & $add 'H08' "Could not read: $(& $names ($unreach | ForEach-Object Name))." @($unreach | ForEach-Object Name) }

    $rb = @($inv.Forest.OptionalFeatures) | Where-Object { $_.Name -eq 'Recycle Bin Feature' }
    if ($rb -and -not $rb.Enabled) { & $add 'H09' 'The Active Directory Recycle Bin is not enabled.' @() }
    if ($inv.Forest.TombstoneLifetimeDays -lt 180) { & $add 'H10' "Tombstone lifetime is $($inv.Forest.TombstoneLifetimeDays) days." @() }

    $siteNames = @($inv.Sites | ForEach-Object Name)
    if ($siteNames.Count -gt 1) {
        $nolink = @($inv.Sites | Where-Object { $n = $_.Name; -not @($inv.SiteLinks | Where-Object { $_.Sites -contains $n }).Count })
        if ($nolink.Count) { & $add 'H11' "Not in any site link: $(& $names ($nolink | ForEach-Object Name))." @($nolink | ForEach-Object Name) }
    }
    $nosub = @($inv.Sites | Where-Object { $n = $_.Name; -not @($inv.Subnets | Where-Object { $_.Site -eq $n }).Count })
    if ($nosub.Count) { & $add 'H12' "Sites without subnets: $(& $names ($nosub | ForEach-Object Name))." @($nosub | ForEach-Object Name) }
    $orphan = @($inv.Subnets | Where-Object { -not $_.Site })
    if ($orphan.Count) { & $add 'H13' "Subnets not assigned to a site: $(& $names ($orphan | ForEach-Object Name))." @($orphan | ForEach-Object Name) }
    $few = @($inv.SiteLinks | Where-Object { @($_.Sites).Count -lt 2 })
    if ($few.Count) { & $add 'H14' "Site links with fewer than two sites: $(& $names ($few | ForEach-Object Name))." @($few | ForEach-Object Name) }
    $smtp = @($inv.SiteLinks | Where-Object Transport -eq 'SMTP')
    if ($smtp.Count) { & $add 'H15' "SMTP site links: $(& $names ($smtp | ForEach-Object Name))." @($smtp | ForEach-Object Name) }
    $manual = @($inv.Connections | Where-Object { -not $_.Automatic -or -not $_.Enabled })
    if ($manual.Count) { & $add 'H16' "$($manual.Count) replication connection(s) are manual or disabled: $(& $names ($manual | ForEach-Object { "$($_.From) -> $($_.To)" }))." @($manual | ForEach-Object { "$($_.From) -> $($_.To) ($(if (-not $_.Enabled) { 'disabled' } else { 'manual' }))" }) }
    if ($inv.Exchange) {
        $exBad = @($inv.Exchange.Servers | Where-Object { -not $_.Supported })
        if ($exBad.Count) { & $add 'H17' "$($exBad.Count) Exchange server(s) out of support: $(& $names ($exBad | ForEach-Object { "$($_.Name) ($($_.Product))" }))." @($exBad | ForEach-Object { "$($_.Name) - $($_.Product) $($_.Version), site $($_.Site)" }) }
    }
    $dl = @($inv.Trusts | Where-Object Kind -eq 'Downlevel (NT4)')
    if ($dl.Count) { & $add 'H18' "Downlevel trusts: $(& $names ($dl | ForEach-Object { "$($_.Source) -> $($_.Target)" }))." @($dl | ForEach-Object { "$($_.Source) -> $($_.Target)" }) }

    # ---- Security: trusts
    $nosid = @($inv.Trusts | Where-Object { $_.Kind -eq 'External' -and -not ($_.Attributes -band 0x4) -and $_.Direction -ne 'Inbound' })
    if ($nosid.Count) { & $add 'S01' "External trusts without SID filtering: $(& $names ($nosid | ForEach-Object { "$($_.Source) -> $($_.Target)" }))." @($nosid | ForEach-Object { "$($_.Source) -> $($_.Target) ($($_.Direction))" }) }

    # ---- Security: per-domain scan
    $sec = $inv.Security
    if ($sec) {
        $doms = @($sec.Domains)
        $collect = { param([scriptblock]$sb) @(foreach ($d in $doms) { foreach ($x in @(& $sb $d)) { if ($null -ne $x -and "$x" -ne '') { "$($d.Domain)\$x" } } }) }

        $krb = @($doms | Where-Object { $null -ne $_.KrbtgtPasswordAgeDays -and $_.KrbtgtPasswordAgeDays -gt 180 })
        if ($krb.Count) {
            $sev = if (@($krb | Where-Object { $_.KrbtgtPasswordAgeDays -gt 365 }).Count) { 'High' } else { 'Medium' }
            & $add 'S02' "krbtgt password is older than 180 days in: $(& $names ($krb | ForEach-Object { "$($_.Domain) ($($_.KrbtgtPasswordAgeDays) days)" }))." @($krb | ForEach-Object { "$($_.Domain) - $($_.KrbtgtPasswordAgeDays) days" }) $sev
        }
        $tier0 = @(foreach ($d in $doms) { foreach ($g in @($d.Groups | Where-Object { $_.Key -in 'DomainAdmins', 'EnterpriseAdmins' -and $_.EnabledMembers -gt 5 })) { "$($d.Domain) $($g.Name): $($g.EnabledMembers) enabled members" } })
        if ($tier0.Count) { & $add 'S03' "More than five enabled administrators: $(& $names $tier0)." @(foreach ($d in $doms) { foreach ($g in @($d.Groups | Where-Object { $_.Key -in 'DomainAdmins', 'EnterpriseAdmins' -and $_.EnabledMembers -gt 5 })) { foreach ($m in $g.Members) { "$($d.Domain) $($g.Name): $m" } } }) }
        $saea = @(foreach ($d in $doms) { foreach ($g in @($d.Groups | Where-Object { $_.Key -in 'SchemaAdmins', 'EnterpriseAdmins' -and $_.EnabledMembers -gt 0 })) { foreach ($m in $g.Members) { "$($g.Name): $m" } } })
        if ($saea.Count) { & $add 'S04' "Schema/Enterprise Admins have $($saea.Count) permanent member(s): $(& $names $saea)." $saea }

        $priv = @(foreach ($d in $doms) { foreach ($p in @($d.Users.Privileged)) { $p | Add-Member -NotePropertyName Domain -NotePropertyValue $d.Domain -Force -PassThru } })
        $pspn = @($priv | Where-Object HasSpn)
        if ($pspn.Count) { & $add 'S05' "$($pspn.Count) privileged account(s) have an SPN: $(& $names ($pspn | ForEach-Object { "$($_.Domain)\$($_.Name)" }))." @($pspn | ForEach-Object { "$($_.Domain)\$($_.Name)" }) }
        $pdel = @($priv | Where-Object { -not $_.SensitiveNotDelegated -and -not $_.InProtectedUsers -and -not $_.BuiltinAdministrator })
        if ($pdel.Count) { & $add 'S06' "$($pdel.Count) privileged account(s) are neither in Protected Users nor marked sensitive: $(& $names ($pdel | ForEach-Object { "$($_.Domain)\$($_.Name)" }))." @($pdel | ForEach-Object { "$($_.Domain)\$($_.Name)" }) }
        $pold = @($priv | Where-Object { $_.PwdNeverExpires -or ($null -ne $_.PwdAgeDays -and $_.PwdAgeDays -gt 365) })
        if ($pold.Count) { & $add 'S07' "$($pold.Count) privileged account(s) have a password older than a year or set to never expire: $(& $names ($pold | ForEach-Object { "$($_.Domain)\$($_.Name)" }))." @($pold | ForEach-Object { "$($_.Domain)\$($_.Name) - password age $($_.PwdAgeDays) days$(if ($_.PwdNeverExpires) { ', never expires' })" }) }
        $pstale = @($priv | Where-Object Stale)
        if ($pstale.Count) { & $add 'S08' "$($pstale.Count) enabled privileged account(s) have not signed in for 90 days: $(& $names ($pstale | ForEach-Object { "$($_.Domain)\$($_.Name)" }))." @($pstale | ForEach-Object { "$($_.Domain)\$($_.Name)" }) }
        $ops = @(foreach ($d in $doms) { foreach ($g in @($d.Groups | Where-Object { $_.Key -in 'AccountOperators', 'ServerOperators', 'BackupOperators', 'PrintOperators' -and $_.EnabledMembers -gt 0 })) { foreach ($m in $g.Members) { "$($d.Domain) $($g.Name): $m" } } })
        if ($ops.Count) { & $add 'S09' "Operator groups have $($ops.Count) member(s): $(& $names $ops)." $ops }

        $e = & $collect { param($d) $d.Users.NoPreauth }; if ($e.Count) { & $add 'S10' "$($e.Count) account(s) don't require Kerberos pre-authentication: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.ServiceAccountsWithSpn }; if ($e.Count) { & $add 'S11' "$($e.Count) user account(s) have SPNs: $(& $names $e)." $e }
        $e = @(@(& $collect { param($d) $d.Computers.TrustedForDelegation }) + @(& $collect { param($d) $d.Users.TrustedForDelegation })); if ($e.Count) { & $add 'S12' "$($e.Count) non-DC account(s) are trusted for unconstrained delegation: $(& $names $e)." $e }
        $e = @(@(& $collect { param($d) $d.Computers.TrustedToAuth }) + @(& $collect { param($d) $d.Users.TrustedToAuth })); if ($e.Count) { & $add 'S13' "$($e.Count) account(s) use protocol transition: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.PwdNotRequired }; if ($e.Count) { & $add 'S14' "$($e.Count) account(s) don't require a password: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.Reversible }
        $revPol = @($doms | Where-Object { $_.PasswordPolicy.ReversibleEncryption } | ForEach-Object { "$($_.Domain) default password policy" })
        if ($e.Count -or $revPol.Count) { & $add 'S15' "Reversible encryption is set on $($e.Count) account(s)$(if ($revPol.Count) { " and in the password policy of $(& $names ($revPol))" }): $(& $names $e)." @($revPol + $e) }
        $e = & $collect { param($d) $d.Users.DesOnly }; if ($e.Count) { & $add 'S16' "$($e.Count) account(s) are limited to DES: $(& $names $e)." $e }
        $e = @(@(& $collect { param($d) $d.Users.Rc4Only }) + @(& $collect { param($d) $d.Computers.Rc4Only }))
        $ssoRc4 = @($doms | Where-Object { $_.Hybrid.SeamlessSsoRc4 } | ForEach-Object { "$($_.Domain)\AZUREADSSOACC" })
        $e = @(@($e) + @($ssoRc4) | Where-Object { $_ })
        if ($e.Count) { & $add 'S17' "$($e.Count) account(s) only allow RC4 for Kerberos: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.Stale }; if ($e.Count) { & $add 'S18' "$($e.Count) enabled user account(s) have not signed in for 90 days$(if ($e.Count -ge $script:MaxEvidence) { ' (list capped)' }): $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Computers.Stale }; if ($e.Count) { & $add 'S19' "$($e.Count) enabled computer account(s) have not signed in for 90 days: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.PwdNeverExpires }; if ($e.Count) { & $add 'S20' "$($e.Count) user account(s) have passwords that never expire: $(& $names $e)." $e }
        $e = & $collect { param($d) $d.Users.SidHistory }; if ($e.Count) { & $add 'S21' "$($e.Count) account(s) carry SID history: $(& $names $e)." $e }
        $maq = @($doms | Where-Object { $_.MachineAccountQuota -gt 0 })
        if ($maq.Count) { & $add 'S22' "MachineAccountQuota is above 0 in: $(& $names ($maq | ForEach-Object { "$($_.Domain) ($($_.MachineAccountQuota))" }))." @($maq | ForEach-Object { "$($_.Domain) - $($_.MachineAccountQuota)" }) }
        $weak = @(foreach ($d in $doms) {
                $p = $d.PasswordPolicy; $why = @()
                if ($p.MinLength -lt 14) { $why += "minimum length $($p.MinLength)" }
                if ($p.LockoutThreshold -eq 0) { $why += 'no lockout' }
                if (-not $p.Complexity) { $why += 'complexity off' }
                if ($why.Count) { "$($d.Domain): $($why -join ', ')" }
            })
        if ($weak.Count) { & $add 'S23' "Weak default password policy: $(& $names $weak)." $weak }

        $fs = $sec.Forest
        if ($fs) {
            $eligible = ($doms | Measure-Object -Property { $_.Computers.LapsEligible } -Sum).Sum
            $winCov = ($doms | ForEach-Object { $_.Computers.WindowsLapsCovered } | Measure-Object -Sum).Sum
            $legCov = ($doms | ForEach-Object { $_.Computers.LegacyLapsCovered } | Measure-Object -Sum).Sum
            if (-not $fs.WindowsLapsSchema -and -not $fs.LegacyLapsSchema) { & $add 'S24' 'Neither Windows LAPS nor legacy Microsoft LAPS is in the schema.' @() }
            elseif (-not $fs.WindowsLapsSchema) { & $add 'S25' "Only legacy Microsoft LAPS is deployed ($legCov computer(s) covered)." @() }
            if (($fs.WindowsLapsSchema -or $fs.LegacyLapsSchema) -and $eligible -gt 0) {
                $miss = & $collect { param($d) $d.Computers.NoLaps }
                $pct = [math]::Round(100 * ($winCov + $legCov) / $eligible)
                if ($pct -lt 95) { & $add 'S26' "$pct% of $eligible Windows member computers have a LAPS password; $($eligible - $winCov - $legCov) don't: $(& $names $miss)." $miss }
            }
            if (@($fs.RiskyTemplates).Count) { & $add 'S30' "$(@($fs.RiskyTemplates).Count) published certificate template(s) let the requester set the subject and can be used to sign in: $(& $names ($fs.RiskyTemplates | ForEach-Object Name))." @($fs.RiskyTemplates | ForEach-Object { "$($_.Name) - $($_.Reason)" }) }
        }
        $e = & $collect { param($d) $d.Computers.Unsupported }; if ($e.Count) { & $add 'S27' "$($e.Count) computer(s) run an unsupported Windows version: $(& $names $e)." $e }
        $g = @($doms | Where-Object GuestEnabled | ForEach-Object Domain); if ($g.Count) { & $add 'S28' "Guest is enabled in: $(& $names $g)." $g }
        $pw = @($doms | Where-Object { @($_.Groups | Where-Object { $_.Key -eq 'PreWin2000' -and $_.HasAnonymousOrEveryone }).Count } | ForEach-Object Domain)
        if ($pw.Count) { & $add 'S29' "Pre-Windows 2000 Compatible Access includes Anonymous or Everyone in: $(& $names $pw)." $pw }
        $sso = @($doms | Where-Object { $null -ne $_.Hybrid.SeamlessSsoPasswordAgeDays -and $_.Hybrid.SeamlessSsoPasswordAgeDays -gt 30 })
        if ($sso.Count) {
            $sev = if (@($sso | Where-Object { $_.Hybrid.SeamlessSsoPasswordAgeDays -gt 90 }).Count) { 'High' } else { 'Medium' }
            & $add 'S31' "AZUREADSSOACC key age: $(& $names ($sso | ForEach-Object { "$($_.Domain) $($_.Hybrid.SeamlessSsoPasswordAgeDays) days" }))." @($sso | ForEach-Object { "$($_.Domain) - $($_.Hybrid.SeamlessSsoPasswordAgeDays) days" }) $sev
        }
        $dnsA = @(foreach ($d in $doms) { foreach ($gg in @($d.Groups | Where-Object { $_.Key -eq 'DnsAdmins' -and $_.EnabledMembers -gt 0 })) { foreach ($m in $gg.Members) { "$($d.Domain) DnsAdmins: $m" } } })
        if ($dnsA.Count) { & $add 'S32' "DnsAdmins has $($dnsA.Count) member(s): $(& $names $dnsA)." $dnsA }

        # ---- Hybrid
        $h = Get-AdtdHybridState $inv
        if (-not $h.ConnectSync -and -not $h.CloudSync) { & $add 'X01' 'No sign of Microsoft Entra Connect Sync or Cloud Sync in the directory.' @() }
        if ($h.ConnectSync) { & $add 'X02' "Microsoft Entra Connect Sync accounts found: $(& $names $h.ConnectAccounts)." $h.ConnectAccounts }
        if ($h.Adfs) { & $add 'X03' "AD FS configuration container found in: $(& $names $h.AdfsDomains)." $h.AdfsDomains }
        if ($h.NonRoutableUsers -gt 0) { & $add 'X04' "$($h.NonRoutableUsers) enabled user(s) have non-routable UPN suffixes: $(& $names ($h.NonRoutableSuffixes | ForEach-Object { "@$($_.Name) ($($_.Count))" }))." @($h.NonRoutableSuffixes | ForEach-Object { "@$($_.Name) - $($_.Count) user(s)" }) }
        if ($h.UsersWithoutUpn -gt 0) { & $add 'X05' "$($h.UsersWithoutUpn) enabled user(s) have no UPN." @() }
        if (($h.ConnectSync -or $h.CloudSync) -and -not $h.HybridJoinScp) { & $add 'X06' 'Directory sync is in place but there is no device registration service connection point.' @() }
        if (($h.ConnectSync -or $h.CloudSync) -and @($h.DomainsWithoutEntraKerberos).Count) { & $add 'X07' "No AzureADKerberos object in: $(& $names $h.DomainsWithoutEntraKerberos)." $h.DomainsWithoutEntraKerberos }
        if (-not $h.PasswordProtection) { & $add 'X08' 'No Microsoft Entra Password Protection DC agents are registered.' @() }
    }

    $order = @{ High = 0; Medium = 1; Low = 2 }
    return @($out | Sort-Object @{ E = { $order[$_.Severity] } }, @{ E = { @{ Security = 0; Health = 1; Hybrid = 2 }[$_.Category] } }, Id)
}

# ---------------------------------------------------------------- Hybrid state, gaps and plan

function Get-AdtdHybridState {
    param($Inventory)
    $doms = @($Inventory.Security.Domains)
    $fs = $Inventory.Security.Forest
    $connect = @(foreach ($d in $doms) { foreach ($a in @($d.Hybrid.ConnectSyncAccounts)) { "$($d.Domain)\$($a.Account)$(if ($a.Server) { " (server $($a.Server))" })" } })
    $cloud = @(foreach ($d in $doms) { foreach ($a in @($d.Hybrid.CloudSyncAgents)) { "$($d.Domain)\$a" } })
    $suffixes = @{}
    foreach ($d in $doms) { foreach ($s in @($d.Users.UpnSuffixes)) { if (Test-AdtdNonRoutableSuffix $s.Name) { $suffixes[$s.Name] = [int]$suffixes[$s.Name] + [int]$s.Count } } }
    $nr = @($suffixes.Keys | Sort-Object | ForEach-Object { [pscustomobject]@{ Name = $_; Count = $suffixes[$_] } })
    $objects = @($doms | ForEach-Object { [pscustomobject]@{ Domain = $_.Domain; Objects = [int]$_.Users.Total + [int]$_.Computers.Total } })
    [pscustomobject]@{
        ConnectSync = [bool]$connect.Count
        ConnectAccounts = $connect
        CloudSync = [bool]$cloud.Count
        CloudSyncAgents = $cloud
        Adfs = [bool]@($doms | Where-Object { $_.Hybrid.AdfsDkmContainer }).Count
        AdfsDomains = @($doms | Where-Object { $_.Hybrid.AdfsDkmContainer } | ForEach-Object Domain)
        SeamlessSso = [bool]@($doms | Where-Object { $null -ne $_.Hybrid.SeamlessSsoPasswordAgeDays }).Count
        EntraKerberos = [bool]@($doms | Where-Object { $_.Hybrid.EntraKerberos }).Count
        DomainsWithoutEntraKerberos = @($doms | Where-Object { -not $_.Hybrid.EntraKerberos } | ForEach-Object Domain)
        HybridJoinScp = [bool]($fs -and $fs.DeviceRegistrationScp)
        TenantName = if ($fs) { $fs.TenantName } else { $null }
        PasswordProtection = [bool](($doms | ForEach-Object { [int]$_.Hybrid.PasswordProtectionAgents } | Measure-Object -Sum).Sum)
        WindowsLaps = [bool]($fs -and $fs.WindowsLapsSchema)
        LegacyLaps = [bool]($fs -and $fs.LegacyLapsSchema)
        CertificateServices = [bool]($fs -and @($fs.CertificateAuthorities).Count)
        NonRoutableUsers = ($nr | Measure-Object -Property Count -Sum).Sum
        NonRoutableSuffixes = $nr
        UsersWithoutUpn = ($doms | ForEach-Object { [int]$_.Users.NoUpn } | Measure-Object -Sum).Sum
        LargestDomainObjects = ($objects | Measure-Object -Property Objects -Maximum).Maximum
        ExchangeOnPrem = [bool]($Inventory.Exchange -and @($Inventory.Exchange.Servers).Count)
    }
}

function Get-AdtdGapAnalysis {
    <# What the on-premises environment has, and what a modern hybrid identity setup would add. #>
    param($Inventory)
    if (-not $Inventory.Security) { return @() }
    $h = Get-AdtdHybridState $Inventory
    $row = { param($cap, $status, $evidence, $rec, $pri) [pscustomobject]@{ Capability = $cap; Status = $status; Evidence = $evidence; Recommendation = $rec; Priority = $pri } }
    $dcs = @($Inventory.DomainControllers)
    $old = @($dcs | Where-Object { $_.OSSupportState -ne 'Supported' }).Count
    @(
        & $row 'Supported domain controllers' $(if ($old) { 'Partial' } else { 'Present' }) "$($dcs.Count - $old) of $($dcs.Count) DCs supported for at least 12 more months" 'All DCs on Windows Server 2022/2025' $(if ($old) { 'High' } else { 'Low' })
        & $row 'Modern functional level' $(if ($Inventory.Forest.FunctionalLevel -ge 7) { 'Present' } else { 'Missing' }) $Inventory.Forest.FunctionalLevelName 'Windows Server 2016 now; 2025 once every DC runs 2025' 'Medium'
        & $row 'SYSVOL on DFS Replication' $(if (@($Inventory.Domains | Where-Object SysvolReplication -eq 'FRS').Count) { 'Missing' } else { 'Present' }) (($Inventory.Domains | ForEach-Object { "$($_.Name): $($_.SysvolReplication)" }) -join '; ') 'DFSR in every domain' 'High'
        & $row 'AD Recycle Bin' $(if (@($Inventory.Forest.OptionalFeatures | Where-Object { $_.Name -eq 'Recycle Bin Feature' -and $_.Enabled }).Count) { 'Present' } else { 'Missing' }) '' 'Enable it' 'Medium'
        & $row 'Windows LAPS' $(if ($h.WindowsLaps) { 'Present' } elseif ($h.LegacyLaps) { 'Partial' } else { 'Missing' }) $(if ($h.LegacyLaps -and -not $h.WindowsLaps) { 'Legacy LAPS only' } else { '' }) 'Windows LAPS with encryption; back up to Entra ID for Entra-joined devices' 'High'
        & $row 'Directory sync to Microsoft Entra ID' $(if ($h.CloudSync) { 'Present' } elseif ($h.ConnectSync) { 'Present' } else { 'Missing' }) $(if ($h.CloudSync) { "Cloud Sync: $($h.CloudSyncAgents -join ', ')" } elseif ($h.ConnectSync) { "Connect Sync: $($h.ConnectAccounts -join ', ')" } else { 'No sync accounts found' }) 'Cloud Sync (or Connect Sync where its extra features are needed)' $(if ($h.ConnectSync -or $h.CloudSync) { 'Low' } else { 'High' })
        & $row 'Routable UPNs matching email' $(if ($h.NonRoutableUsers -gt 0) { 'Partial' } else { 'Present' }) $(if ($h.NonRoutableUsers) { "$($h.NonRoutableUsers) users on non-routable suffixes" } else { 'All UPN suffixes routable' }) 'UPN = primary email on a verified domain' 'High'
        & $row 'Cloud authentication (no AD FS)' $(if ($h.Adfs) { 'Missing' } else { 'Present' }) $(if ($h.Adfs) { "AD FS container in $($h.AdfsDomains -join ', ')" } else { 'No AD FS configuration found' }) 'Password hash sync + Conditional Access + MFA' 'Medium'
        & $row 'Microsoft Entra hybrid join' $(if ($h.HybridJoinScp) { 'Present' } else { 'Missing' }) $(if ($h.TenantName) { "SCP points to $($h.TenantName)" } else { 'No service connection point' }) 'Hybrid join existing PCs; Entra join + Intune + Autopilot for new PCs' 'Medium'
        & $row 'Microsoft Entra Kerberos (cloud Kerberos trust)' $(if (-not $h.EntraKerberos) { 'Missing' } elseif (@($h.DomainsWithoutEntraKerberos).Count) { 'Partial' } else { 'Present' }) $(if ($h.EntraKerberos -and @($h.DomainsWithoutEntraKerberos).Count) { "Missing in $($h.DomainsWithoutEntraKerberos -join ', ')" } else { '' }) 'Enables Windows Hello for Business and FIDO2 keys for on-premises access' 'Medium'
        & $row 'Seamless SSO' $(if ($h.SeamlessSso) { 'Present' } else { 'Not used' }) '' 'Only needed for devices that are not hybrid or Entra joined; roll its key every 30 days' 'Low'
        & $row 'Entra Password Protection on DCs' $(if ($h.PasswordProtection) { 'Present' } else { 'Missing' }) '' 'Block banned and breached passwords on-premises' 'Medium'
        & $row 'Defender for Identity' 'Not detectable' '' 'Sensors on every DC, AD FS, AD CS and Entra Connect server' 'High'
        & $row 'Conditional Access and MFA' 'Not detectable' '' 'Require phishing-resistant MFA for admins and MFA for all users' 'High'
        & $row 'Exchange' $(if ($h.ExchangeOnPrem) { 'On-premises' } else { 'None / online' }) $(if ($Inventory.Exchange) { "$(@($Inventory.Exchange.Servers).Count) server(s)" } else { '' }) 'Exchange Online; keep Exchange SE or management tools only for recipient management' 'Medium'
        & $row 'Certificate services' $(if ($h.CertificateServices) { 'On-premises' } else { 'None found' }) $(if ($h.CertificateServices) { "$(@($Inventory.Security.Forest.CertificateAuthorities).Count) CA(s), $(@($Inventory.Security.Forest.RiskyTemplates).Count) risky template(s)" } else { '' }) 'Treat AD CS as Tier 0; cloud Kerberos trust removes the need for WHfB certificates' 'Medium'
    )
}

function Get-AdtdTopologyPlan {
    <# Suggested target topology and a four-phase roadmap built from the inventory and findings. #>
    param($Inventory)
    $inv = $Inventory
    $f = @($inv.Findings)
    $has = { param($id) [bool]@($f | Where-Object Id -eq $id).Count }
    $dcs = @($inv.DomainControllers)
    $h = if ($inv.Security) { Get-AdtdHybridState $inv } else { $null }

    $target = New-Object System.Collections.ArrayList
    $add = { param($area, $text) [void]$target.Add([pscustomobject]@{ Area = $area; Recommendation = $text }) }
    $old = @($dcs | Where-Object { $_.OSSupportState -ne 'Supported' })
    & $add 'Domain controllers' "Run every DC on Windows Server 2025 (currently $(@($dcs | Where-Object { $_.OSBuild -ge 26100 }).Count) of $($dcs.Count)). $(if ($old.Count) { "Replace first: $(($old | ForEach-Object Name) -join ', ')." })"
    foreach ($d in $inv.Domains) {
        $w = @($dcs | Where-Object { $_.Domain -eq $d.Name -and -not $_.IsReadOnly }).Count
        if ($w -lt 2) { & $add 'Domain controllers' "$($d.Name): add a second writable DC (has $w)." }
    }
    $dcSites = @($dcs | Group-Object Site)
    & $add 'Sites' "Keep DCs in $($dcSites.Count) site(s) with good connectivity; use a hub-and-spoke site-link design with the hub site(s) at the centre, and remove sites that have no subnets and no DCs."
    if (@($inv.Domains).Count -gt 1) {
        & $add 'Forest design' "The forest has $(@($inv.Domains).Count) domains. Each domain adds Tier 0 servers and admins. Consider consolidating child domains into the root domain (ADMT or a third-party tool) before or while moving to Entra ID; sync works with multiple domains, but fewer is simpler and safer."
    }
    $ext = @($inv.Trusts | Where-Object { $_.Kind -in 'External', 'Forest' } | ForEach-Object Target | Sort-Object -Unique)
    if ($ext.Count) { & $add 'Trusts' "Review the $($ext.Count) external/forest trust(s) ($($ext -join ', ')). Cloud Sync can sync disconnected forests to one tenant, which can replace trusts used only for collaboration." }
    & $add 'Functional level' 'Raise domains and the forest to Windows Server 2016 now, and to Windows Server 2025 (level 10) when the last older DC is gone.'
    if ($h) {
        $syncChoice = if ($h.LargestDomainObjects -gt 150000) { 'Microsoft Entra Connect Sync (a domain has more than 150,000 objects, over the Cloud Sync limit)' }
        elseif ($h.ConnectSync) { 'keep Connect Sync for now; move to Cloud Sync when you no longer need device sync for hybrid join or advanced sync rules' }
        else { 'Microsoft Entra Cloud Sync, with agents on at least two servers (use Connect Sync only if you need device sync for hybrid join or advanced sync rules)' }
        & $add 'Identity sync' "Sync engine: $syncChoice. Fix UPNs first$(if ($h.NonRoutableUsers) { " ($($h.NonRoutableUsers) users on non-routable suffixes)" })."
        & $add 'Authentication' "Password hash sync as the sign-in method, with Conditional Access and MFA. $(if ($h.Adfs) { 'Move off AD FS with Staged Rollout, then decommission it.' } else { '' }) Use Windows Hello for Business with cloud Kerberos trust and FIDO2 keys for passwordless sign-in."
        & $add 'Devices' 'Hybrid join existing domain-joined Windows PCs; enrol new PCs as Microsoft Entra joined with Intune and Autopilot, so the number of domain-joined clients shrinks over time. Manage local admin passwords with Windows LAPS.'
        & $add 'Security operations' 'Deploy Defender for Identity sensors on all DCs, AD FS, AD CS and sync servers; apply the Tier 0 model with separate admin accounts and privileged access workstations.'
        & $add 'Applications' 'Publish internal web apps that use Kerberos or header authentication through Microsoft Entra application proxy or Private Access; move file shares to SharePoint/OneDrive or Azure Files with Entra Kerberos.'
        if ($h.ExchangeOnPrem) { & $add 'Exchange' 'Complete the move to Exchange Online, then keep only Exchange Server SE (or the management tools) for recipient management while AD is the source of authority.' }
    }

    $phase = { param($n, $name, $goal) [pscustomobject]@{ Number = $n; Name = $name; Goal = $goal; Tasks = New-Object System.Collections.ArrayList } }
    $phases = @(
        (& $phase 1 'Stabilise and secure' 'Close the critical gaps attackers use first. (0-3 months)')
        (& $phase 2 'Modernise on-premises AD' 'Supported, healthy, well-designed AD ready for sync. (3-6 months)')
        (& $phase 3 'Hybrid identity with Microsoft Entra ID' 'Sync, cloud authentication, devices and passwordless. (6-12 months)')
        (& $phase 4 'Cloud-first and reduce on-premises' 'Shrink what depends on AD. (12+ months)')
    )
    foreach ($x in $f) { [void]$phases[$x.Phase - 1].Tasks.Add("[$($x.Id)] $($x.Title)") }
    [void]$phases[0].Tasks.Add('Deploy Defender for Identity sensors and review its security assessments')
    [void]$phases[0].Tasks.Add('Confirm offline DC backups and a tested forest recovery plan')
    [void]$phases[1].Tasks.Add('Run IdFix and clean up duplicate or invalid attributes')
    [void]$phases[2].Tasks.Add('Enable password hash sync, Conditional Access and MFA for all users')
    [void]$phases[2].Tasks.Add('Windows Hello for Business with cloud Kerberos trust')
    [void]$phases[3].Tasks.Add('New devices Microsoft Entra joined with Intune and Autopilot')
    [void]$phases[3].Tasks.Add('Move apps to Entra ID (SAML/OIDC), app proxy or Private Access')
    [void]$phases[3].Tasks.Add('Retire servers and domains that no longer have a purpose')
    if (-not (& $has 'H05') -and $inv.Forest.FunctionalLevel -lt 10) { [void]$phases[3].Tasks.Add('Raise to the Windows Server 2025 functional level after the last pre-2025 DC is gone') }

    [pscustomobject]@{ Target = $target.ToArray(); Phases = $phases; Gaps = @(Get-AdtdGapAnalysis $inv); VerifyManually = $script:AdtdVerifyManually }
}
