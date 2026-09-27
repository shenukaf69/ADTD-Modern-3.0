# H16: Manually created or disabled replication connections

**Severity:** Low · **Category:** Health · **Area:** Replication · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 replication connection(s) are manual or disabled: DC02 -> NYDC1.

## Why it matters

Manual connections are not maintained by the KCC and often outlive the reason they were created. Disabled connections can hide replication gaps.

## How to fix

1. Review each manual connection; delete it unless there is a documented reason, and let the KCC build the topology.
2. Check replication health with repadmin /replsummary and repadmin /showrepl.

## Affected objects (1)

- DC02 -> NYDC1 (manual)

## References

- [Designing the site topology](https://learn.microsoft.com/windows-server/identity/ad-ds/plan/designing-the-site-topology)
