# S21: Accounts with SID history

**Severity:** Medium · **Category:** Security · **Area:** Accounts · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 account(s) carry SID history: contoso.com\migrated.user.

## Why it matters

SID history left after a migration can silently grant access, and is a known privilege-escalation technique.

## How to fix

1. After confirming resource ACLs have been re-permissioned, clear sIDHistory from migrated accounts.

## Affected objects (1)

- contoso.com\migrated.user

## References

- [Unsecure SID History attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-sid-history-attributes)
- [netdom trust (/quarantine and /enablesidhistory)](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust)
