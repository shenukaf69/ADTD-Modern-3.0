# S29: Pre-Windows 2000 Compatible Access contains Anonymous or Everyone

**Severity:** Medium · **Category:** Security · **Area:** Domain settings · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

Pre-Windows 2000 Compatible Access includes Anonymous or Everyone in: contoso.com.

## Why it matters

Lets anonymous users read user and group information from the directory.

## How to fix

1. Remove Anonymous Logon and Everyone from the group; leave Authenticated Users only if old applications need it.

## Affected objects (1)

- contoso.com

## References

- [Identity infrastructure security assessments](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/identity-infrastructure)
