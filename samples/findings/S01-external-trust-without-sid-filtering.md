# S01: External trust without SID filtering

**Severity:** Medium · **Category:** Security · **Area:** Trusts · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

External trusts without SID filtering: emea.contoso.com -> tailspin.local.

## Why it matters

Without SID filtering an administrator in the trusted domain can add privileged SIDs to SID history and become an admin in your domain.

## How to fix

1. Turn quarantine back on: netdom trust <trusting> /domain:<trusted> /quarantine:yes.
2. Only leave it off during a migration that needs SID history, and turn it on afterwards.

## Affected objects (1)

- emea.contoso.com -> tailspin.local (Outbound)

## References

- [netdom trust (/quarantine and /enablesidhistory)](https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust)
