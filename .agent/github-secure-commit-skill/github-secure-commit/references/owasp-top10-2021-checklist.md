# OWASP Top 10 2021 Checklist for Secure Commit

Use this mapping to interpret `scripts/owasp-audit.ps1` results.

## A01: Broken Access Control
- Check accidental `[AllowAnonymous]` exposure.
- Verify authorization attributes on sensitive endpoints.
- Validate role and policy checks for admin operations.

## A02: Cryptographic Failures
- Block weak algorithms such as `MD5` and `SHA1`.
- Block insecure cipher mode `ECB`.
- Avoid hardcoded keys and plaintext secrets.

## A03: Injection
- Flag SQL string concatenation and raw SQL calls.
- Flag dynamic code execution patterns such as `eval(...)`.
- Require parameterized queries and input validation.

## A04: Insecure Design
- Require explicit threat modeling for new risky flows.
- Review business logic abuse paths before release.
- Prefer deny-by-default for sensitive operations.

## A05: Security Misconfiguration
- Flag permissive CORS with credentials.
- Flag `TrustServerCertificate=true` and similar unsafe defaults.
- Ensure production configs disable debug and verbose errors.

## A06: Vulnerable and Outdated Components
- Run `dotnet list package --vulnerable --include-transitive`.
- Run `npm audit --audit-level=high` where applicable.
- Block release when critical/high dependency CVEs exist.

## A07: Identification and Authentication Failures
- Flag direct password equality checks.
- Require secure password hashing and proper auth workflows.
- Verify token expiration and rotation strategy.

## A08: Software and Data Integrity Failures
- Flag unsafe deserialization (`BinaryFormatter`, `TypeNameHandling.All`).
- Verify integrity of external packages and build artifacts.
- Prefer signed packages and locked dependency versions.

## A09: Security Logging and Monitoring Failures
- Flag empty catch blocks swallowing exceptions.
- Require audit logs for auth, privilege, and data-access actions.
- Ensure monitoring captures suspicious behavior.

## A10: Server-Side Request Forgery (SSRF)
- Flag outbound requests built from user-controlled URL input.
- Enforce allowlist of protocols, domains, and ports.
- Block local network and cloud metadata endpoint access.

## Gate Decision
- Secret leak findings: always block commit.
- OWASP findings:
  - block on `critical` and `high`
  - warn on `medium` and `low` unless strict mode is requested
