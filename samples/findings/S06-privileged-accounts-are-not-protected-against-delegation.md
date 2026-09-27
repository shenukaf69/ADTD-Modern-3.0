# S06: Privileged accounts are not protected against delegation

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

8 privileged account(s) are neither in Protected Users nor marked sensitive: contoso.com\svc.sql, contoso.com\da1, contoso.com\da2, contoso.com\da3, contoso.com\da4 and 3 more.

## Why it matters

Admin accounts that are not marked "sensitive and cannot be delegated" (or in Protected Users) can be impersonated through Kerberos delegation.

## How to fix

1. Add human admin accounts to the Protected Users group (test first: it blocks NTLM, DES/RC4 and delegation for them).
2. For other privileged accounts, set "Account is sensitive and cannot be delegated".

## Affected objects (8)

- contoso.com\svc.sql
- contoso.com\da1
- contoso.com\da2
- contoso.com\da3
- contoso.com\da4
- contoso.com\da.stale
- contoso.com\helpdesk1
- emea.contoso.com\emea.admin

## References

- [Ensure privileged accounts are not delegated](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#ensure-privileged-accounts-are-not-delegated)
- [Protected Users security group](https://learn.microsoft.com/windows-server/security/credentials-protection-and-management/protected-users-security-group)
