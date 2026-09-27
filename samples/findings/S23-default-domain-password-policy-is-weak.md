# S23: Default domain password policy is weak

**Severity:** Medium · **Category:** Security · **Area:** Domain settings · **Roadmap phase:** 2 · **Forest:** contoso.com

## What ADTD found

Weak default password policy: contoso.com: minimum length 7, no lockout.

## Why it matters

Short passwords and no lockout make password spraying easy.

## How to fix

1. Set a minimum length of at least 14 characters (fine-grained policies for admins can require more).
2. Set an account lockout threshold (for example 10 attempts) to slow down guessing.
3. Add Microsoft Entra Password Protection to block common and breached passwords on-premises.

## Affected objects (1)

- contoso.com: minimum length 7, no lockout

## References

- [Password policy recommendations](https://learn.microsoft.com/microsoft-365/admin/misc/password-policy-recommendations)
- [Plan and deploy on-premises Microsoft Entra Password Protection](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy)
