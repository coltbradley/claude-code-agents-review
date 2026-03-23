# Code Guardian

**Code-agnostic guardrails for non-programmers building with AI tools.**

Code Guardian is a Claude Code plugin that gives you a team of adversarial auditors and action agents without requiring you to read or understand code. It runs parallel reviews across security, bugs, quality, dependencies, performance, documentation, infrastructure, databases, and APIs — then delivers findings in plain English, layered from executive summary down to technical detail. Built for non-programmers using AI to build software, contractors reviewing external work, and anyone who needs code quality visibility without diving into the codebase themselves.

---

## Installation

**1. Marketplace:**
```
/plugin install code-guardian@marketplace-name
```

**2. Local development:**
```bash
claude --plugin-dir ./code-guardian
```

**3. Reload after changes:**
```
/reload-plugins
```

---

## Quick Start

| Command | Description |
|---------|-------------|
| `/code-guardian:quick-check` | Fast pre-commit check — GO, CONCERNS, or STOP verdict in seconds |
| `/code-guardian:audit` | Full 9-auditor parallel review with prioritized findings |
| `/code-guardian:explain src/` | Plain-English translation of what your code does and why |
| `/code-guardian:review-code` | Structured evaluation of contractor or external code |

---

## Skills

| Skill | When to Use | What It Does |
|-------|-------------|--------------|
| `audit` | Before any major milestone | Runs all 9 auditors in parallel and produces a prioritized findings report |
| `quick-check` | Before every commit | Runs 3 fast auditors and returns a single GO / CONCERNS / STOP verdict |
| `review-code` | When evaluating contractor or external code | Structured adversarial review with a trust score and red flags |
| `pre-deploy` | Before pushing to production | Deployment readiness gate — returns GO or BLOCKED with blockers listed |
| `explain` | When you need to understand code | Translates code into plain English with no jargon |
| `health-report` | Weekly or on-demand status check | Red / yellow / green dashboard across all audit dimensions |
| `compare` | After a batch of changes | Compares current audit snapshot to a previous one to surface regressions |
| `language-advisor` | Before starting a new project | Recommends the right language and framework given your goals and constraints |

---

## Agents

### Auditors (9)

Each auditor runs independently and in parallel during a full audit.

| Agent | What It Checks | Output File |
|-------|---------------|-------------|
| `security-auditor` | Exposed secrets, injection risks, auth gaps, OWASP top 10 | `AUDIT_SECURITY.md` |
| `bug-auditor` | Runtime errors, null references, logic gaps, unhandled edge cases | `AUDIT_BUGS.md` |
| `code-auditor` | Complexity, duplication, dead code, readability | `AUDIT_CODE.md` |
| `dep-auditor` | Outdated packages, known CVEs, license risks | `AUDIT_DEPS.md` |
| `doc-auditor` | Missing docs, misleading comments, undocumented public APIs | `AUDIT_DOCS.md` |
| `infra-auditor` | Config files, env var usage, HTTP headers, secrets management | `AUDIT_INFRA.md` |
| `perf-auditor` | Slow queries, unnecessary work, memory leaks, bundle size | `AUDIT_PERF.md` |
| `db-auditor` | N+1 queries, missing indexes, unsafe migrations, data integrity | `AUDIT_DB.md` |
| `api-auditor` | Endpoint design, error handling, rate limiting, input validation | `AUDIT_API.md` |

### Action Agents (3)

| Agent | What It Does |
|-------|-------------|
| `fix-planner` | Takes audit findings and produces a prioritized `FIXES.md` with effort estimates |
| `code-fixer` | Implements fixes from `FIXES.md` one at a time with before/after explanations |
| `test-runner` | Runs the project's existing test suite and surfaces failures in plain English |

---

## How Reports Work

Every audit output uses a layered format so you can read as much or as little as you need:

```
## VERDICT: CONCERNS

### Plain English Summary
Two medium-severity issues found. No blockers.

### Findings
1. [MEDIUM] Hardcoded timeout value in payment handler — should be configurable
2. [LOW] Three unused imports in auth module — minor cleanup

### Technical Detail
payment/handler.js:42 — `setTimeout(resolve, 5000)` ...
```

Start at the top for the verdict. Read the summary for context. Scroll to technical detail only if you need to act on it or hand it to a developer.

---

## Automatic Hooks

These run without you asking:

| Hook | Trigger | Behavior |
|------|---------|----------|
| Secret detection | Pre-commit | Scans staged files for API keys, tokens, passwords — **blocks commit** if found |
| `.env` protection | Pre-commit | Prevents accidental commit of `.env` files — **blocks commit** |
| Large file warning | Pre-commit | Warns when a file exceeds 500KB — **blocks commit** until confirmed |
| Change size nudge | Post-edit | Advisory reminder when a single change touches more than 20 files |

---

## Works With Superpowers

Code Guardian pairs naturally with the superpowers plugin. Superpowers gives you fast, task-focused execution. Code Guardian wraps that execution with adversarial review — catching what fast AI work tends to miss. Run superpowers to build, then run `/code-guardian:quick-check` before committing.

---

## Who This Is For

- Non-programmers using AI tools to build software who want confidence without reading code
- People reviewing contractor work before paying or merging
- Anyone who has had AI agents make changes they didn't notice or understand
- Solo founders and small teams without a dedicated code reviewer

---

## License

MIT
