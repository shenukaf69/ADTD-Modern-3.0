# S02: krbtgt password is old

**Severity:** High · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

krbtgt password is older than 180 days in: contoso.com (400 days).

## Why it matters

The krbtgt key signs every Kerberos ticket. If it was ever stolen, attackers can forge tickets (Golden Ticket) until it is changed twice.

## How to fix

1. Reset the krbtgt password twice, at least 10 hours apart (longer than the maximum ticket lifetime), using Microsoft's documented procedure or script.
2. Check replication between the two resets.
3. Repeat at least every 180 days.

## Affected objects (1)

- contoso.com - 400 days

## References

- [Change password for krbtgt account (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#change-password-for-krbtgt-account)
- [Reset the krbtgt password](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-reset-the-krbtgt-password)
