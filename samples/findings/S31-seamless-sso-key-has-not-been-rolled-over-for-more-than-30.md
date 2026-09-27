# S31: Seamless SSO key has not been rolled over for more than 30 days

**Severity:** High · **Category:** Security · **Area:** Hybrid identity · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

AZUREADSSOACC key age: contoso.com 120 days.

## Why it matters

The AZUREADSSOACC key lets anyone who steals it create Kerberos tickets that sign in as any synced user to Microsoft Entra ID.

## How to fix

1. Roll over the key with Update-AzureADSSOForest on the Entra Connect server (once per forest).
2. Schedule the rollover every 30 days.
3. Switch the account to AES after rolling the key.

## Affected objects (1)

- contoso.com - 120 days

## References

- [Roll over the Seamless SSO Kerberos decryption key](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-faq)
- [Seamless SSO technical deep dive (AES and RC4)](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works)
