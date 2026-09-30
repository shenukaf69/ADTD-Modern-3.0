# S08: Privileged accounts are not being used

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 enabled privileged account(s) have not signed in for 90 days: contoso.com\da.stale.

## Why it matters

Enabled admin accounts that no one signs in with are an easy target nobody watches.

## How to fix

1. Disable these accounts, wait a few weeks for anything that breaks, then delete them.

## Affected objects (1)

- contoso.com\da.stale

## References

- [Dormant entities in sensitive groups (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#dormant-entities-in-sensitive-groups)
- [Remove stale Active Directory accounts](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#remove-stale-active-directory-accounts)
