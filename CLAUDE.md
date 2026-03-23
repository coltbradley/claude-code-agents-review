# Code Guardian

Code Guardian is a code-agnostic guardrails plugin for non-programmers building with AI tools. It provides 12 specialized agents and 8 skills that analyze any codebase — regardless of language or framework — and report findings in plain English, translating technical risk into business impact so you can make informed decisions without needing to read the code yourself.

## Quick Start

```
/code-guardian:quick-check          # Fast check before committing
/code-guardian:audit                # Full comprehensive audit
/code-guardian:explain [path]       # Understand code in plain English
/code-guardian:review-code          # Evaluate external code before using it
```

## Agents (12)

### Auditors (9)

| Agent | Scope | Report |
|---|---|---|
| security-auditor | Credentials, injection risks, auth flaws, exposed secrets | `AUDIT_SECURITY.md` |
| bug-auditor | Logic errors, null handling, edge cases, silent failures | `AUDIT_BUGS.md` |
| code-quality-auditor | Maintainability, duplication, naming, structure | `AUDIT_CODE_QUALITY.md` |
| dependency-auditor | Outdated packages, known CVEs, license risks | `AUDIT_DEPENDENCIES.md` |
| documentation-auditor | Missing docs, misleading comments, undocumented behavior | `AUDIT_DOCUMENTATION.md` |
| infrastructure-auditor | CI/CD config, environment handling, deployment risks | `AUDIT_INFRASTRUCTURE.md` |
| performance-auditor | Slow queries, memory leaks, blocking calls, inefficiencies | `AUDIT_PERFORMANCE.md` |
| database-auditor | Schema risks, missing indexes, migration safety, data loss | `AUDIT_DATABASE.md` |
| api-auditor | Endpoint security, input validation, error exposure, rate limiting | `AUDIT_API.md` |

### Action Agents (3)

| Agent | What it does |
|---|---|
| fix-planner | Prioritizes findings into an actionable fix plan ordered by business impact |
| code-fixer | Applies low-risk, high-confidence fixes directly to code |
| test-runner | Runs available test suites and summarizes results in plain English |

## Skills (8)

| Skill | When to use | What happens |
|---|---|---|
| audit | Before finishing a feature branch or shipping | Runs all 9 auditors, produces full report set |
| quick-check | Before every commit | Runs security + bug auditors only, fast turnaround |
| review-code | Before using external code (libraries, snippets, AI output) | Audits code you didn't write for hidden risks |
| pre-deploy | Final gate before production | Full audit + fix-planner + test-runner in sequence |
| explain | When you don't understand what a file or function does | Returns plain-English explanation, no jargon |
| health-report | Weekly or on-demand codebase overview | Aggregates all existing audit reports into one summary |
| compare | After a large refactor or merge | Diffs risk posture before and after changes |
| language-advisor | Before starting a new project or adding a stack | Recommends languages/frameworks based on your constraints |

## Output Format

All reports use a layered format so you can stop reading as soon as you have enough context:

1. **Executive Summary** — one paragraph, plain English, what matters and why
2. **Plain-English Findings** — each issue described as a business risk, not a code problem
3. **Technical Detail** — file paths, line numbers, and code snippets for whoever fixes it

Severity reflects business impact:
- **Critical** — users are at risk right now, or data could be lost
- **Important** — problems are coming soon if not addressed
- **Minor** — worth fixing when time allows, no immediate risk

## Reports

All output is written to `.claude/audits/`:

```
.claude/audits/
  AUDIT_SECURITY.md
  AUDIT_BUGS.md
  AUDIT_CODE_QUALITY.md
  AUDIT_DEPENDENCIES.md
  AUDIT_DOCUMENTATION.md
  AUDIT_INFRASTRUCTURE.md
  AUDIT_PERFORMANCE.md
  AUDIT_DATABASE.md
  AUDIT_API.md
  FIXES.md
  TEST_REPORT.md
  HEALTH_REPORT.md
  TREND_REPORT.md
  snapshots/YYYY-MM-DD/
```

## Hooks (Automatic)

These run without being asked:

- **pre-commit** — scans staged files for secrets and credentials, blocks `.env` files from being committed, warns if any single file exceeds 500 lines
- **post-edit** — nudges when a single change touches more than 10 files, suggesting a checkpoint audit

## Superpowers Integration

Code Guardian is standalone but works well alongside planning and execution tools:

- Run `quick-check` after any plan-generated code before moving to the next task
- Run `audit` before marking a branch done
- Run `language-advisor` before starting a new project to avoid stack regret
- Run `review-code` whenever you paste in code from the internet, an AI, or a third party

## Principles

- **Code-agnostic** — works on any language, framework, or project type
- **Plain English first** — every finding is explained as a business consequence before technical detail
- **Adversarial by default** — assumes things can go wrong; looks for problems, not reassurance
- **Business-impact severity** — risk is rated by what it means for users and operations, not CVSS scores
- **Layered review** — AI auditors catch patterns at scale, deterministic hooks catch known-bad signatures, human review is recommended for any Critical finding before shipping
