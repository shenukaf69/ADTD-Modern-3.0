# S18: Enabled user accounts that have not signed in for 90 days

**Severity:** Low · **Category:** Security · **Area:** Accounts · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

2 enabled user account(s) have not signed in for 90 days: contoso.com\da.stale, contoso.com\old.user.

## Why it matters

Unused accounts are rarely watched and are a common foothold.

## How to fix

1. Disable the accounts, move them to a quarantine OU, and delete them after your retention period.
2. Automate this with a lifecycle process or Microsoft Entra ID Governance.

## Affected objects (2)

- contoso.com\da.stale
- contoso.com\old.user

## References

- [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#remove-stale-active-directory-accounts)
