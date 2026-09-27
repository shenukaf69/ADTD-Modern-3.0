# S04: Schema Admins or Enterprise Admins have permanent members

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

Schema/Enterprise Admins have 2 permanent member(s): Enterprise Admins: Administrator, Schema Admins: Administrator.

## Why it matters

These groups are only needed for schema changes and forest-wide changes, and should normally be empty.

## How to fix

1. Remove all members, and add an account only for the duration of a planned change.

## Affected objects (2)

- Enterprise Admins: Administrator
- Schema Admins: Administrator

## References

- [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)
