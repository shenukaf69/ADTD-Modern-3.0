# S17: Accounts limited to RC4 Kerberos encryption

**Severity:** Medium · **Category:** Security · **Area:** Kerberos · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

2 account(s) only allow RC4 for Kerberos: contoso.com\svc.web, contoso.com\AZUREADSSOACC.

## Why it matters

Windows Server updates from July 2026 change the default Kerberos encryption type from RC4 to AES-256. Accounts limited to RC4 are easier to crack and may fail to authenticate.

## How to fix

1. Enable AES 128/256 on each account (msDS-SupportedEncryptionTypes = 0x18 or 0x1C during migration) and reset the password so AES keys exist.
2. For the AZUREADSSOACC account, roll over its key first, then switch it to AES.

## Affected objects (2)

- contoso.com\svc.web
- contoso.com\AZUREADSSOACC

## References

- [Detect and remediate RC4 usage in Kerberos](https://learn.microsoft.com/windows-server/security/kerberos/detect-remediate-rc4-kerberos)
- [Unsecure account attributes (Defender for Identity)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/accounts#unsecure-account-attributes)
- [Seamless SSO technical deep dive (AES and RC4)](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works)
