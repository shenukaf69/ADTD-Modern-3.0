# H07: A domain has only one writable domain controller

**Severity:** High · **Category:** Health · **Area:** Domains · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

Only one writable DC in: emea.contoso.com.

## Why it matters

If that server fails, the domain is down and must be restored from backup.

## How to fix

1. Add a second writable domain controller, preferably in a different site or host.
2. Make sure both are global catalogs and DNS servers.
3. Keep a tested system-state backup of at least one DC per domain.

## Affected objects (1)

- emea.contoso.com - EMEADC1

## References

- [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)
