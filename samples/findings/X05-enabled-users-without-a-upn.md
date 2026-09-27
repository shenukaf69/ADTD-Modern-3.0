# X05: Enabled users without a UPN

**Severity:** Low · **Category:** Hybrid · **Area:** Directory sync · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 enabled user(s) have no UPN.

## Why it matters

Accounts without a userPrincipalName sync with a generated name and are harder to manage.

## How to fix

1. Set a UPN on each account that will be synced.

## References

- [Prepare for directory synchronization to Microsoft 365 (IdFix)](https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization)
