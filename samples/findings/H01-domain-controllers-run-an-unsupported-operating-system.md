# H01: Domain controllers run an unsupported operating system

**Severity:** High · **Category:** Health · **Area:** Domain controllers · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 domain controller(s) run an unsupported OS: EMEADC1 (Windows Server 2012 R2).

## Why it matters

Out-of-support servers get no security updates. A domain controller holds every password hash in the domain, so one unpatched DC exposes the whole forest.

## How to fix

1. Build replacement domain controllers on Windows Server 2025 (or 2022) in the same sites.
2. Move any FSMO roles off the old DCs (Move-ADDirectoryServerOperationMasterRole).
3. Update DNS forwarders, DHCP options and hard-coded DC names that point at the old servers.
4. Demote the old DCs with Uninstall-ADDSDomainController and clean up their metadata.
5. Raise the domain and forest functional levels when the last old DC is gone.

## Affected objects (1)

- EMEADC1 - Windows Server 2012 R2, support ended 2023-10-10, site Frankfurt, domain emea.contoso.com

## References

- [Microsoft product lifecycle search](https://learn.microsoft.com/lifecycle/products/)
- [What's new in Windows Server 2025](https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025)
