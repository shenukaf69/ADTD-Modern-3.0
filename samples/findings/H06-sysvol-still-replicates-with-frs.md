# H06: SYSVOL still replicates with FRS

**Severity:** High · **Category:** Health · **Area:** Domains · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

SYSVOL uses FRS in: emea.contoso.com.

## Why it matters

FRS is removed from Windows Server 2019 and later. You cannot add a newer domain controller to this domain until SYSVOL uses DFS Replication.

## How to fix

1. Check that all DCs replicate cleanly (repadmin /replsummary).
2. Run dfsrmig /setglobalstate 1, 2 and 3 in turn, waiting for every DC to reach each state (dfsrmig /getmigrationstate).
3. Confirm SYSVOL is shared from the SYSVOL_DFSR folder on every DC.

## Affected objects (1)

- emea.contoso.com

## References

- [Migrate SYSVOL replication to DFS Replication](https://learn.microsoft.com/windows-server/storage/dfs-replication/migrate-sysvol-to-dfsr)
