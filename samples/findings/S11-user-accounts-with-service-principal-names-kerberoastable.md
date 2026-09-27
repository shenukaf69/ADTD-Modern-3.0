# S11: User accounts with service principal names (Kerberoastable)

**Severity:** Medium · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 user account(s) have SPNs: contoso.com\svc.web.

## Why it matters

Service accounts with SPNs can be attacked offline; weak or old passwords are cracked quickly.

## How to fix

1. Replace these accounts with group managed service accounts (gMSA), which have 120-character rotating passwords.
2. Where that is not possible, set passwords of 25+ random characters and enable AES encryption on the account.

## Affected objects (1)

- contoso.com\svc.web

## References

- [Investigate and protect service accounts](https://learn.microsoft.com/defender-for-identity/service-account-discovery)
- [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)
