# X07: Microsoft Entra Kerberos (cloud Kerberos trust) is not set up

**Severity:** Low · **Category:** Hybrid · **Area:** Authentication · **Roadmap phase:** 3 · **Forest:** contoso.com

## What ADTD found

No AzureADKerberos object in: emea.contoso.com.

## Why it matters

Cloud Kerberos trust is the recommended way to deploy Windows Hello for Business and FIDO2 security keys for on-premises access, without a PKI.

## How to fix

1. Create the Microsoft Entra Kerberos server object for each domain (Set-AzureADKerberosServer).
2. Enable Windows Hello for Business with "Use cloud trust for on-premises authentication".

## Affected objects (1)

- emea.contoso.com

## References

- [Windows Hello for Business cloud Kerberos trust](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/deploy/hybrid-cloud-kerberos-trust)
