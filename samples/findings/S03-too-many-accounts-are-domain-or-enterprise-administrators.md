# S03: Too many accounts are domain or enterprise administrators

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

More than five enabled administrators: contoso.com Domain Admins: 8 enabled members.

## Why it matters

Every Tier 0 account is a path to full control of the forest. Microsoft suggests fewer than five people with Domain Admins-equivalent access and no service accounts in Domain Admins.

## How to fix

1. List every member, including nested groups, and remove anyone who doesn't need permanent Tier 0 rights.
2. Delegate day-to-day tasks with scoped groups instead of Domain Admins.
3. Use separate admin accounts and privileged access workstations for Tier 0.

## Affected objects (8)

- contoso.com Domain Admins: Administrator
- contoso.com Domain Admins: admin.jane
- contoso.com Domain Admins: svc.sql
- contoso.com Domain Admins: da1
- contoso.com Domain Admins: da2
- contoso.com Domain Admins: da3
- contoso.com Domain Admins: da4
- contoso.com Domain Admins: da.stale

## References

- [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)
- [Enterprise access model](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model)
