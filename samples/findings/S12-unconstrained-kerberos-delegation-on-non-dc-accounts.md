# S12: Unconstrained Kerberos delegation on non-DC accounts

**Severity:** High · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 non-DC account(s) are trusted for unconstrained delegation: contoso.com\APP01.

## Why it matters

A server trusted for unconstrained delegation stores the TGT of everyone who connects to it. Compromise of that server exposes those users, including admins.

## How to fix

1. Change each account to constrained or resource-based constrained delegation to the specific services it needs.
2. If delegation is not needed, turn it off.

## Affected objects (1)

- contoso.com\APP01

## References

- [Unsecure Kerberos delegation (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-kerberos-delegation)
