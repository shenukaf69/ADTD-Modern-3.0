# H09: The Active Directory Recycle Bin is not enabled

**Severity:** Medium · **Category:** Health · **Area:** Forest · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

The Active Directory Recycle Bin is not enabled.

## Why it matters

Without it, restoring a deleted user, group or OU needs an authoritative restore from backup.

## How to fix

1. Run: Enable-ADOptionalFeature "Recycle Bin Feature" -Scope ForestOrConfigurationSet -Target <forest>.
2. It cannot be turned off, and objects deleted before it was enabled cannot be recovered with it.

## References

- [Enable and use Active Directory Recycle Bin](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/adac/active-directory-recycle-bin)
