# H17: Exchange servers are out of support

**Severity:** High · **Category:** Health · **Area:** Exchange · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 Exchange server(s) out of support: EX2019 (Exchange 2019).

## Why it matters

Unsupported Exchange servers get no security updates and are a common attack entry point.

## How to fix

1. Upgrade to Exchange Server Subscription Edition, or move mailboxes to Exchange Online.
2. If all mailboxes are in Exchange Online, keep only the Exchange Management Tools for recipient management and remove the last servers.

## Affected objects (1)

- EX2019 - Exchange 2019 15.2.1748, site NewYork

## References

- [Exchange Server supportability matrix](https://learn.microsoft.com/exchange/plan-and-deploy/supportability-matrix)
- [Exchange Server 2019 and 2016 end of support roadmap](https://learn.microsoft.com/troubleshoot/exchange/administration/exchange-2019-2016-end-of-support)
