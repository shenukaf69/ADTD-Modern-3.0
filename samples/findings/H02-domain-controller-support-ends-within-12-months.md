# H02: Domain controller support ends within 12 months

**Severity:** Medium · **Category:** Health · **Area:** Domain controllers · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 domain controller(s) reach end of support within 12 months: NYDC1 (Windows Server 2016, 2027-01-12).

## Why it matters

Plan now so the replacement is finished before security updates stop.

## How to fix

1. Add Windows Server 2025 domain controllers to each affected site.
2. Transfer roles and demote the old DCs before the end-of-support date.

## Affected objects (1)

- NYDC1 - Windows Server 2016, support ends 2027-01-12

## References

- [Microsoft product lifecycle search](https://learn.microsoft.com/lifecycle/products/)
