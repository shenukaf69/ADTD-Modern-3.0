# X04: Users have non-routable UPN suffixes

**Severity:** Medium · **Category:** Hybrid · **Area:** Directory sync · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 enabled user(s) have non-routable UPN suffixes: @contoso.local (1).

## Why it matters

Users with UPNs such as user@contoso.local sync to Microsoft Entra ID as user@<tenant>.onmicrosoft.com, so their sign-in name differs from their email.

## How to fix

1. Add a routable UPN suffix that you have verified in Microsoft 365 (Active Directory Domains and Trusts > Properties > UPN Suffixes).
2. Change user UPNs to the new suffix (ideally matching their primary email).
3. Run IdFix to find other sync blockers.

## Affected objects (1)

- @contoso.local - 1 user(s)

## References

- [Prepare a non-routable domain for directory synchronization](https://learn.microsoft.com/microsoft-365/enterprise/prepare-a-non-routable-domain-for-directory-synchronization)
- [Prepare for directory synchronization to Microsoft 365 (IdFix)](https://learn.microsoft.com/microsoft-365/enterprise/prepare-for-directory-synchronization)
