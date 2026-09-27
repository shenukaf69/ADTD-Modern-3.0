# S32: DnsAdmins has members

**Severity:** Low · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

DnsAdmins has 1 member(s): contoso.com DnsAdmins: dns.op.

## Why it matters

DnsAdmins members can load code on domain controllers running DNS.

## How to fix

1. Treat DnsAdmins as Tier 0: keep it empty or limited to Tier 0 admins.

## Affected objects (1)

- contoso.com DnsAdmins: dns.op

## References

- [Tier model for Active Directory Domain Services](https://learn.microsoft.com/windows-server/identity/ad-ds/tier-model)
