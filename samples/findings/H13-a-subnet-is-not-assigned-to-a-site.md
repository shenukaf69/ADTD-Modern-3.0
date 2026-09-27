# H13: A subnet is not assigned to a site

**Severity:** Low · **Category:** Health · **Area:** Sites · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

Subnets not assigned to a site: 192.168.99.0/24.

## Why it matters

Clients in that subnet can pick any domain controller, including ones across slow WAN links.

## How to fix

1. Assign each subnet to the site of its location.
2. Check the Netlogon.log on DCs for NO_CLIENT_SITE entries to find subnets that are still missing.

## Affected objects (1)

- 192.168.99.0/24

## References

- [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)
