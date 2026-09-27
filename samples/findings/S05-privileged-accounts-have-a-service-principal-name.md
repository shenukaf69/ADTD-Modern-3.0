# S05: Privileged accounts have a service principal name (Kerberoastable)

**Severity:** High · **Category:** Security · **Area:** Privileged access · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 privileged account(s) have an SPN: contoso.com\svc.sql.

## Why it matters

Any domain user can request a ticket for an account with an SPN and crack its password offline. If it is an admin, cracking it gives Tier 0 access.

## How to fix

1. Move the service to a group managed service account (gMSA) and remove the SPN from the admin account.
2. If the account must stay, give it a long random password (25+ characters) and remove it from privileged groups.

## Affected objects (1)

- contoso.com\svc.sql

## References

- [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)
- [Identify service accounts in privileged groups](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#identify-service-accounts-in-privileged-groups)
