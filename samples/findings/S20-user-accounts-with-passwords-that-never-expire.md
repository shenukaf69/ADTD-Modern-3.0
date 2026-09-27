# S20: User accounts with passwords that never expire

**Severity:** Low · **Category:** Security · **Area:** Accounts · **Roadmap phase:** 3 · **Forest:** contoso.com

## What ADTD found

3 user account(s) have passwords that never expire: contoso.com\Administrator, contoso.com\svc.sql, contoso.com\MSOL_1a2b3c4d5e6f.

## Why it matters

Long-lived passwords are more likely to be leaked and reused. Microsoft no longer recommends forced periodic change for users with MFA, but "never expires" on shared or service accounts hides old passwords.

## How to fix

1. Review the list: convert service accounts to gMSA, and for people rely on MFA and banned-password checks instead of the flag.

## Affected objects (3)

- contoso.com\Administrator
- contoso.com\svc.sql
- contoso.com\MSOL_1a2b3c4d5e6f

## References

- [Password policy recommendations](https://learn.microsoft.com/microsoft-365/admin/misc/password-policy-recommendations)
