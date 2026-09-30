# S30: Certificate templates let requesters choose the subject (possible ESC1)

**Severity:** High · **Category:** Security · **Area:** Certificate services · **Roadmap phase:** 1 · **Forest:** contoso.com

## What ADTD found

1 published certificate template(s) let the requester set the subject and can be used to sign in: VulnTemplate.

## Why it matters

If low-privileged users can enroll, anyone can get a certificate that signs in as a domain admin.

## How to fix

1. Check enrollment permissions on each template listed. ADTD does not read ACLs.
2. Turn off "Supply in the request", or require CA manager approval, or remove authentication EKUs, or stop publishing the template.

## Affected objects (1)

- VulnTemplate - Enrollee supplies subject, usable for authentication, no manager approval

## References

- [Certificate template assessments (ESC1)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/certificates#prevent-users-to-request-a-certificate-valid-for-arbitrary-users-based-on-the-certificate-template-esc1-preview)
- [Certificate templates with Any Purpose or no EKU (ESC2)](https://learn.microsoft.com/defender-for-identity/security-posture-assessments/certificates#edit-overly-permissive-certificate-template-with-privileged-eku-any-purpose-eku-or-no-eku-esc2)
