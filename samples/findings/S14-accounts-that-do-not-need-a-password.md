# S14: Accounts that do not need a password

**Severity:** Medium · **Category:** Security · **Area:** Accounts · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 account(s) don't require a password: contoso.com\nopwd.user.

## Why it matters

PASSWD_NOTREQD lets the account have an empty password.

## How to fix

1. Remove the flag (Set-ADUser -PasswordNotRequired $false) and set a password.

## Affected objects (1)

- contoso.com\nopwd.user

## References

- [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)
