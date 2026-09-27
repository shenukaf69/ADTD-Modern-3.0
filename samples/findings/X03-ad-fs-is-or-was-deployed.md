# X03: AD FS is (or was) deployed

**Severity:** Medium · **Category:** Hybrid · **Area:** Authentication · **Roadmap phase:** 3 · **Forest:** contoso.com

## What ADTD found

AD FS configuration container found in: contoso.com.

## Why it matters

AD FS adds servers to patch and protect as Tier 0, and makes cloud sign-in depend on on-premises availability. Microsoft recommends password hash sync for cloud authentication.

## How to fix

1. Inventory the relying parties in AD FS; move apps to Microsoft Entra ID enterprise apps.
2. Enable password hash sync and test with Staged Rollout.
3. Convert the federated domains to managed, then decommission AD FS and its DKM container.

## Affected objects (1)

- contoso.com

## References

- [Migrate from federation to cloud authentication](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication)
- [Migrate to cloud authentication using Staged Rollout](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-staged-rollout)
