# X08: Microsoft Entra Password Protection is not deployed on domain controllers

**Severity:** Low · **Category:** Hybrid · **Area:** Authentication · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

No Microsoft Entra Password Protection DC agents are registered.

## Why it matters

On-premises password changes aren't checked against the global banned password list.

## How to fix

1. Install the Password Protection proxy on member servers and the DC agent on every DC; start in audit mode, then enforce.

## References

- [Plan and deploy on-premises Microsoft Entra Password Protection](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy)
