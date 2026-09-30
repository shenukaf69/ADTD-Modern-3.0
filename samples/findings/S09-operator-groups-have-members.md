# S09: Operator groups have members

**Severity:** Medium · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

Operator groups have 1 member(s): contoso.com Account Operators: helpdesk1.

## Why it matters

Account, Server, Backup and Print Operators can log on to DCs or edit privileged objects, so they are effectively Tier 0.

## How to fix

1. Empty these groups and delegate the specific tasks with scoped permissions instead.

## Affected objects (1)

- contoso.com Account Operators: helpdesk1

## References

- [Locate accounts in built-in Operator Groups (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#locate-accounts-in-built-in-operator-groups)
- [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)
