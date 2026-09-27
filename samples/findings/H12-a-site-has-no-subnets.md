# H12: A site has no subnets

**Severity:** Low · **Category:** Health · **Area:** Sites · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

Sites without subnets: Auckland.

## Why it matters

Clients never land in that site, so its domain controllers only serve clients by accident.

## How to fix

1. Assign the IP subnets of that location to the site, or delete the site if it is no longer used.

## Affected objects (1)

- Auckland

## References

- [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)
