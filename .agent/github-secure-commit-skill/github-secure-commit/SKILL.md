---
name: github-secure-commit
description: secure and automate git commit and github push with mandatory pre-commit code review for leaked ai keys, api keys, secrets, and environment variables, plus a repository-wide security audit mapped to owasp top 10 checks. use when the user asks to commit or push code safely, enforce security gates before commit, install a pre-commit hook, or perform a fast security review before publishing source code.
---

# Github Secure Commit

## Overview
Secure the commit pipeline by running deterministic pre-commit checks before every `git commit` or `git push`.
Fail fast on secret leaks. Block commit when high-risk OWASP findings are detected.

## Workflow
1. Resolve the git repository root.
2. Run `scripts/scan-secrets.ps1` to detect leaked AI keys, API keys, credentials, and unsafe `.env` files.
3. Run `scripts/owasp-audit.ps1` to perform repository-wide static security checks mapped to OWASP Top 10, then run dependency vulnerability checks when supported tools are installed.
4. If all gates pass, perform commit and optional push.
5. If any blocking issue exists, stop and return actionable remediation items.

## Primary Commands
Run security gates only:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .agent/github-secure-commit-skill/github-secure-commit/scripts/secure-commit.ps1 -Path .
```

Run gates, then commit:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .agent/github-secure-commit-skill/github-secure-commit/scripts/secure-commit.ps1 -Path . -CommitMessage "feat: secure update"
```

Run gates, commit, and push:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .agent/github-secure-commit-skill/github-secure-commit/scripts/secure-commit.ps1 -Path . -CommitMessage "feat: secure update" -Push
```

Install pre-commit hook:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .agent/github-secure-commit-skill/github-secure-commit/scripts/install-pre-commit-hook.ps1 -Path .
```

## Gate Policy
- Block immediately on any secret/key leak found by `scan-secrets.ps1`.
- Block on `critical` or `high` severity issues reported by `owasp-audit.ps1`.
- Allow `medium` and `low` findings to pass with warnings unless the user asks for strict mode.
- Save reports to `.security-reports/` in the repository root for traceability.

## Remediation Rules
When a leak or security issue is detected:
1. Do not commit.
2. Show the exact file and line.
3. Suggest one minimal fix.
4. Re-run the same gate to verify closure.
5. Continue to commit only after all blocking findings are resolved.

## References
- Use `references/owasp-top10-2021-checklist.md` for category mapping and audit coverage.
