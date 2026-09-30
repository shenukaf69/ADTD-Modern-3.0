# H04: Forest or domain functional level is below Windows Server 2016

**Severity:** Medium · **Category:** Health · **Area:** Forest · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

Functional level below Windows Server 2016: Domain emea.contoso.com: Windows Server 2012 R2.

## Why it matters

Lower levels block newer security features, such as privileged access management with time-bound group membership and automatic NTLM secret rolling for smart-card users.

## How to fix

1. Make sure every DC in the domain runs Windows Server 2016 or later.
2. Raise each domain level (Set-ADDomainMode), then the forest level (Set-ADForestMode).

## Affected objects (1)

- Domain emea.contoso.com: Windows Server 2012 R2

## References

- [Forest and domain functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/active-directory-functional-levels)
- [Raise domain and forest functional levels](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/raise-domain-forest-functional-levels)
