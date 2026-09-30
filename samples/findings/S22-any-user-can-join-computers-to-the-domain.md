# S22: Any user can join computers to the domain (MachineAccountQuota)

**Severity:** Medium · **Category:** Security · **Area:** Domain settings · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

MachineAccountQuota is above 0 in: contoso.com (10).

## Why it matters

By default each user can create 10 computer accounts, which attackers use for relay and delegation attacks.

## How to fix

1. Set ms-DS-MachineAccountQuota to 0 on the domain.
2. Delegate "Create computer objects" on specific OUs to the people or tools that join devices.

## Affected objects (1)

- contoso.com - 10

## References

- [Default limit to number of workstations a user can join to the domain](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/default-workstation-numbers-join-domain)
- [Active Directory domain join permissions](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/active-directory-domain-join-permissions)
