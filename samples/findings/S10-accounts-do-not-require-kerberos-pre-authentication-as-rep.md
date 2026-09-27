# S10: Accounts do not require Kerberos pre-authentication (AS-REP roasting)

**Severity:** High · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 account(s) don't require Kerberos pre-authentication: contoso.com\asrep.user.

## Why it matters

Anyone can request encrypted data for these accounts without knowing the password, and crack it offline.

## How to fix

1. Remove "Do not require Kerberos preauthentication" from each account (Set-ADAccountControl -DoesNotRequirePreAuth $false).

## Affected objects (1)

- contoso.com\asrep.user

## References

- [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)
