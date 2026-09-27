# S13: Accounts trusted to authenticate for delegation (protocol transition)

**Severity:** Medium · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

1 account(s) use protocol transition: .

## Why it matters

Protocol transition lets the service get tickets for any user to its target services without that user's password.

## How to fix

1. Confirm each one is needed and limited to the right target services; remove it otherwise.

## References

- [Unsecure Kerberos delegation (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-kerberos-delegation)
