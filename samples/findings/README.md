# Active Directory assessment: contoso.com

Collected 2026-09-27 09:51 from dc01.contoso.com with ADTD Modern 3.0.1. Read-only: nothing in Active Directory was changed.

- **High**: 12
- **Medium**: 21
- **Low**: 11

| ID | Severity | Category | Finding | Affected |
|---|---|---|---|---|
| [S02](S02-krbtgt-password-is-old.md) | High | Security | krbtgt password is old | 1 |
| [S05](S05-privileged-accounts-have-a-service-principal-name.md) | High | Security | Privileged accounts have a service principal name (Kerberoastable) | 1 |
| [S10](S10-accounts-do-not-require-kerberos-pre-authentication-as-rep.md) | High | Security | Accounts do not require Kerberos pre-authentication (AS-REP roasting) | 1 |
| [S12](S12-unconstrained-kerberos-delegation-on-non-dc-accounts.md) | High | Security | Unconstrained Kerberos delegation on non-DC accounts | 1 |
| [S27](S27-computers-run-an-unsupported-windows-version.md) | High | Security | Computers run an unsupported Windows version | 2 |
| [S30](S30-certificate-templates-let-requesters-choose-the-subject.md) | High | Security | Certificate templates let requesters choose the subject (possible ESC1) | 1 |
| [S31](S31-seamless-sso-key-has-not-been-rolled-over-for-more-than-30.md) | High | Security | Seamless SSO key has not been rolled over for more than 30 days | 1 |
| [H01](H01-domain-controllers-run-an-unsupported-operating-system.md) | High | Health | Domain controllers run an unsupported operating system | 1 |
| [H06](H06-sysvol-still-replicates-with-frs.md) | High | Health | SYSVOL still replicates with FRS | 1 |
| [H07](H07-a-domain-has-only-one-writable-domain-controller.md) | High | Health | A domain has only one writable domain controller | 1 |
| [H11](H11-a-site-is-not-in-any-site-link.md) | High | Health | A site is not in any site link | 1 |
| [H17](H17-exchange-servers-are-out-of-support.md) | High | Health | Exchange servers are out of support | 1 |
| [S01](S01-external-trust-without-sid-filtering.md) | Medium | Security | External trust without SID filtering | 1 |
| [S03](S03-too-many-accounts-are-domain-or-enterprise-administrators.md) | Medium | Security | Too many accounts are domain or enterprise administrators | 8 |
| [S04](S04-schema-admins-or-enterprise-admins-have-permanent-members.md) | Medium | Security | Schema Admins or Enterprise Admins have permanent members | 2 |
| [S06](S06-privileged-accounts-are-not-protected-against-delegation.md) | Medium | Security | Privileged accounts are not protected against delegation | 8 |
| [S07](S07-privileged-accounts-with-old-or-non-expiring-passwords.md) | Medium | Security | Privileged accounts with old or non-expiring passwords | 2 |
| [S08](S08-privileged-accounts-are-not-being-used.md) | Medium | Security | Privileged accounts are not being used | 1 |
| [S09](S09-operator-groups-have-members.md) | Medium | Security | Operator groups have members | 1 |
| [S11](S11-user-accounts-with-service-principal-names-kerberoastable.md) | Medium | Security | User accounts with service principal names (Kerberoastable) | 1 |
| [S14](S14-accounts-that-do-not-need-a-password.md) | Medium | Security | Accounts that do not need a password | 1 |
| [S17](S17-accounts-limited-to-rc4-kerberos-encryption.md) | Medium | Security | Accounts limited to RC4 Kerberos encryption | 2 |
| [S21](S21-accounts-with-sid-history.md) | Medium | Security | Accounts with SID history | 1 |
| [S22](S22-any-user-can-join-computers-to-the-domain.md) | Medium | Security | Any user can join computers to the domain (MachineAccountQuota) | 1 |
| [S23](S23-default-domain-password-policy-is-weak.md) | Medium | Security | Default domain password policy is weak | 1 |
| [S26](S26-some-computers-have-no-laps-password.md) | Medium | Security | Some computers have no LAPS password | 1 |
| [S28](S28-the-guest-account-is-enabled.md) | Medium | Security | The Guest account is enabled | 1 |
| [S29](S29-pre-windows-2000-compatible-access-contains-anonymous-or.md) | Medium | Security | Pre-Windows 2000 Compatible Access contains Anonymous or Everyone | 1 |
| [H02](H02-domain-controller-support-ends-within-12-months.md) | Medium | Health | Domain controller support ends within 12 months | 1 |
| [H04](H04-forest-or-domain-functional-level-is-below-windows-server.md) | Medium | Health | Forest or domain functional level is below Windows Server 2016 | 1 |
| [H09](H09-the-active-directory-recycle-bin-is-not-enabled.md) | Medium | Health | The Active Directory Recycle Bin is not enabled | 0 |
| [X03](X03-ad-fs-is-or-was-deployed.md) | Medium | Hybrid | AD FS is (or was) deployed | 1 |
| [X04](X04-users-have-non-routable-upn-suffixes.md) | Medium | Hybrid | Users have non-routable UPN suffixes | 1 |
| [S18](S18-enabled-user-accounts-that-have-not-signed-in-for-90-days.md) | Low | Security | Enabled user accounts that have not signed in for 90 days | 2 |
| [S19](S19-enabled-computer-accounts-that-have-not-signed-in-for-90.md) | Low | Security | Enabled computer accounts that have not signed in for 90 days | 1 |
| [S20](S20-user-accounts-with-passwords-that-never-expire.md) | Low | Security | User accounts with passwords that never expire | 3 |
| [S32](S32-dnsadmins-has-members.md) | Low | Security | DnsAdmins has members | 1 |
| [H12](H12-a-site-has-no-subnets.md) | Low | Health | A site has no subnets | 1 |
| [H13](H13-a-subnet-is-not-assigned-to-a-site.md) | Low | Health | A subnet is not assigned to a site | 1 |
| [H16](H16-manually-created-or-disabled-replication-connections.md) | Low | Health | Manually created or disabled replication connections | 1 |
| [X02](X02-microsoft-entra-connect-sync-is-in-use.md) | Low | Hybrid | Microsoft Entra Connect Sync is in use | 1 |
| [X05](X05-enabled-users-without-a-upn.md) | Low | Hybrid | Enabled users without a UPN | 0 |
| [X07](X07-microsoft-entra-kerberos-cloud-kerberos-trust-is-not-set-up.md) | Low | Hybrid | Microsoft Entra Kerberos (cloud Kerberos trust) is not set up | 1 |
| [X08](X08-microsoft-entra-password-protection-is-not-deployed-on.md) | Low | Hybrid | Microsoft Entra Password Protection is not deployed on domain controllers | 0 |

See [hybrid-plan.md](hybrid-plan.md) for the target topology, gap analysis and roadmap.
