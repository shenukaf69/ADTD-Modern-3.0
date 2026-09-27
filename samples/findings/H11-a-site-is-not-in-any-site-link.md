# H11: A site is not in any site link

**Severity:** High · **Category:** Health · **Area:** Sites · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

Not in any site link: Auckland.

## Why it matters

Domain controllers in that site cannot replicate with other sites.

## How to fix

1. Add the site to an IP site link (Active Directory Sites and Services > Inter-Site Transports > IP).

## Affected objects (1)

- Auckland

## References

- [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)
