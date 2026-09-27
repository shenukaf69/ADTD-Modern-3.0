# S19: Enabled computer accounts that have not signed in for 90 days

**Severity:** Low · **Category:** Security · **Area:** Accounts · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 enabled computer account(s) have not signed in for 90 days: contoso.com\OLD01.

## Why it matters

Stale computer accounts clutter the directory and can be reused by attackers.

## How to fix

1. Disable, then delete, computer accounts that no longer exist.

## Affected objects (1)

- contoso.com\OLD01

## References

- [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts)
