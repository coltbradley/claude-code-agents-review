# Changelog

## 1.0.0 (2026-03-23)

Initial release of code-guardian.

### Agents (12)
- 9 code-agnostic auditor agents: security, bugs, code quality, dependencies, documentation, infrastructure, performance, database, API
- 3 action agents: fix-planner, code-fixer, test-runner

### Skills (8)
- audit — full 9-auditor parallel review
- quick-check — fast 3-auditor GO/CONCERNS/STOP verdict
- review-code — structured contractor/external code evaluation
- pre-deploy — deployment readiness GO/BLOCKED gate
- explain — plain-English code translation
- health-report — red/yellow/green dashboard
- compare — audit trend tracking with snapshots
- language-advisor — pre-project language/framework guidance

### Hooks
- Secret detection (pre-commit, blocks)
- .env file protection (pre-commit, blocks)
- Large file warning (pre-commit, blocks)
- Change size nudge (post-edit, advisory)

### Design
- Code-agnostic: works on any language
- Layered output: executive summary → plain English → technical detail
- Adversarial by default: finds problems, doesn't rubber-stamp
- Built for non-programmers using AI tools
