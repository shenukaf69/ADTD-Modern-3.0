# S26: Some computers have no LAPS password

**Severity:** Medium · **Category:** Security · **Area:** Local admin passwords · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

80% of 5 Windows member computers have a LAPS password; 1 don't: contoso.com\WS02.

## Why it matters

Computers without a managed password still share local admin credentials.

## How to fix

1. Check that the LAPS policy reaches these computers (event log Microsoft-Windows-LAPS/Operational).
2. Retire or fix computers that no longer apply policy.

## Affected objects (1)

- contoso.com\WS02

## References

- [What is Windows LAPS?](https://learn.microsoft.com/windows-server/identity/laps/laps-overview)
- [Microsoft LAPS usage (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#microsoft-laps-usage)
