# X02: Microsoft Entra Connect Sync is in use

**Severity:** Low · **Category:** Hybrid · **Area:** Directory sync · **Roadmap phase:** 3 · **Forest:** contoso.com

## What ADTD found

Microsoft Entra Connect Sync accounts found: contoso.com\MSOL_1a2b3c4d5e6f (server SYNC01).

## Why it matters

Connect Sync is a full sync server that must be patched and protected as Tier 0. Microsoft is putting new sync features into Cloud Sync.

## How to fix

1. Keep Connect Sync on the latest version and protect the server as Tier 0.
2. Review the decision guide: move to Cloud Sync if you don't need device sync, advanced sync rules or more than 150,000 objects per domain.

## Affected objects (1)

- contoso.com\MSOL_1a2b3c4d5e6f (server SYNC01)

## References

- [Connect Sync to Cloud Sync decision guide](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/connect-to-cloud-sync-decision-guide)
- [What is Microsoft Entra Cloud Sync?](https://learn.microsoft.com/entra/identity/hybrid/cloud-sync/what-is-cloud-sync)
