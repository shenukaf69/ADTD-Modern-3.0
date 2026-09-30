# S07: Privileged accounts with old or non-expiring passwords

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

2 privileged account(s) have a password older than a year or set to never expire: contoso.com\Administrator, contoso.com\svc.sql.

## Why it matters

Old admin passwords are more likely to have been exposed and reused.

## How to fix

1. Rotate the passwords of these accounts.
2. Remove "password never expires" from admin accounts, or better, use long passphrases with MFA-backed access (smart card, Windows Hello for Business).

## Affected objects (2)

- contoso.com\Administrator - password age 800 days, never expires
- contoso.com\svc.sql - password age 30 days, never expires

## References

- [Change password of built-in domain Administrator account (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#change-password-of-built-in-domain-administrator-account)
- [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)
