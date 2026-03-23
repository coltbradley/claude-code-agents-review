# CLAUDE.md — Code Review Agents for Non-Programmers

This toolkit gives you a team of 24 AI review agents that check code for problems — security holes, bugs, performance issues, accessibility gaps, and more. You don't need to write code to use them. Think of it like hiring a QA team that reads the codebase for you.

## Who This Is For

You're someone who works with code — maybe you manage a product, own a project, or inherited a codebase — but you don't write code yourself. These agents let you **audit any codebase** and get plain-language reports about what's wrong and what to fix, regardless of programming language or framework.

## How It Works

You point agents at a codebase. They read the code, find problems, and write reports to `.claude/audits/`. You read the reports and decide what to do.

**The basic loop:**
1. Run auditors → they produce findings
2. Run the fix-planner → it prioritizes findings into a fix list
3. Optionally run the code-fixer → it implements the fixes
4. Run tests → verify nothing broke

---

## Quick Start

**Run a full audit** (all 11 auditors check everything):
```
Run a full audit on this codebase
```

**Check just one thing:**
```
Run the security-auditor on this project
Run the bug-auditor on src/
```

**After an audit, get a prioritized fix list:**
```
Run fix-planner to prioritize the findings
```

**Have fixes implemented automatically:**
```
Run code-fixer on the top 3 items in FIXES.md
```

---

## The Agents

### Auditors (11) — Read code, find problems, write reports

These are your main tools. Each one focuses on a specific area so nothing gets missed. They all run in parallel.

| Agent | What it checks | Report |
|-------|---------------|--------|
| **security-auditor** | Passwords in code, injection attacks, auth gaps, data exposure | `AUDIT_SECURITY.md` |
| **bug-auditor** | Crashes, memory leaks, broken logic, missing error handling | `AUDIT_BUGS.md` |
| **code-auditor** | Messy code, duplication, overly complex functions | `AUDIT_CODE.md` |
| **doc-auditor** | Missing documentation, outdated comments, incomplete READMEs | `AUDIT_DOCS.md` |
| **infra-auditor** | Server config, environment setup, deployment settings | `AUDIT_INFRA.md` |
| **ui-auditor** | Accessibility (screen readers, keyboard nav), UI consistency | `AUDIT_UI_UX.md` |
| **db-auditor** | Slow database queries, missing indexes, schema problems | `AUDIT_DB.md` |
| **perf-auditor** | Slow pages, large files, unoptimized images, bottlenecks | `AUDIT_PERF.md` |
| **dep-auditor** | Outdated libraries, known vulnerabilities, unused packages | `AUDIT_DEPS.md` |
| **seo-auditor** | Missing meta tags, broken links, search engine issues | `AUDIT_SEO.md` |
| **api-tester** | API endpoints: do they work, handle errors, validate input? | `API_TEST_REPORT.md` |

### Action Agents (4) — Fix and verify

| Agent | What it does |
|-------|-------------|
| **fix-planner** | Reads all audit reports, removes duplicates, ranks by severity (P1 critical → P4 nice-to-have) |
| **code-fixer** | Implements fixes from the prioritized list |
| **test-runner** | Runs the project's tests to verify fixes didn't break anything |
| **test-writer** | Creates new tests for uncovered code |

### Browser Testing (4) — Test the running app

| Agent | What it does |
|-------|-------------|
| **browser-qa-agent** | Opens the app in a browser, clicks around, finds broken UI and console errors |
| **fullstack-qa-orchestrator** | Find bug → fix it → verify fix — automated loop |
| **console-monitor** | Watches for errors while the app runs |
| **visual-diff** | Compares screenshots before/after changes to catch visual regressions |

### Deployment & Utility (5)

| Agent | What it does |
|-------|-------------|
| **deploy-checker** | Is this safe to ship? Checks build, secrets, config |
| **env-validator** | Are environment variables set up correctly? |
| **pr-writer** | Writes a pull request description from the changes |
| **seed-generator** | Creates realistic test data |
| **architect-reviewer** | Final sign-off — reviews everything before merge |

---

## Workflows (Pre-Built Sequences)

These chain agents together for common tasks:

| Workflow | When to use | What happens |
|----------|------------|-------------|
| `/full-audit` | Weekly health check, before a release | All 11 auditors run → fix-planner prioritizes |
| `/pre-commit` | Before saving changes | code-auditor + test-runner quick check |
| `/pre-deploy` | Before shipping to production | deploy-checker + env-validator + dep-auditor |
| `/new-feature` | Building something new | Tests written → code built → tests verified |
| `/bug-fix` | Fixing a reported bug | Bug reproduced → fixed → verified |
| `/release-prep` | Preparing a release | Full audit → critical fixes → deploy check → PR |

---

## Reading the Reports

All reports land in `.claude/audits/`. Each finding includes:

- **Severity:** P1 (critical — fix now) → P4 (nice-to-have)
- **What's wrong:** Plain description of the problem
- **Where:** File and location in the code
- **Why it matters:** What could go wrong if ignored
- **Suggested fix:** What should change

Start with `FIXES.md` after running fix-planner — it's the consolidated, deduplicated, prioritized list across all auditors.

---

## What You Can Do Without Writing Code

- Run any auditor and read the findings
- Run fix-planner to get a prioritized action list
- Run deploy-checker to see if the app is safe to ship
- Run browser-qa-agent to test the live app
- Run dep-auditor to check for vulnerable dependencies
- Share audit reports with your development team
- Use findings to write tickets or assign work

## What Requires a Developer (or code-fixer)

- Actually implementing the fixes
- Reviewing code-fixer's changes for correctness
- Resolving complex architectural issues flagged by auditors
- Setting up test infrastructure if none exists

---

## Language & Framework Agnostic

These agents work on **any codebase**: Python, JavaScript, TypeScript, Go, Rust, Ruby, Java, PHP, or anything else. The auditors read and analyze code regardless of language. Some agents (like seo-auditor and ui-auditor) are most useful for web projects, but the core auditors (security, bugs, code quality, dependencies) work everywhere.

---

## Why Non-Programmers Need These Agents More, Not Less

> Full research and evidence behind these points: [docs/research-non-programmer-code-review.md](docs/research-non-programmer-code-review.md)

There are 7 risks that compound silently when you build with AI but don't write code yourself. These agents are your defense against all of them.

| Risk | What happens | Your defense |
|------|-------------|-------------|
| **Language agnosticism** | You have no language bias — good for picking the right tool, but you can't tell if AI writes bad code in it | Run code-auditor early and often |
| **Refactoring = double debugging** | AI rewrites introduce new bugs on top of old ones, and you can't catch either set | Get it right the first time. Audit before AND after any major change |
| **Invisible code rot** | AI produces working-but-messy code. It compounds until the codebase is unmaintainable | Run code-auditor weekly, not just before deploys |
| **Circular validation** | AI reviewing AI shares blind spots. Same-model review rubber-stamps ~70-80% of the time | Use multiple agents, adversarial prompting, and deterministic tools (linters, type checkers) |
| **"Works but wrong"** | Code handles the happy path, fails on edge cases, concurrency, real data | Don't trust tests blindly. Get human review for security, payments, user data |
| **Language choice** | Python is easiest for AI to generate but catches almost nothing at compile time. TypeScript strict or Rust catch mistakes before they run | Pick based on safety, not ease. See [language choice research](docs/research-non-programmer-code-review.md#4-language-choice) |
| **The lock-in trap** | AI lowers the cost of building but not of maintaining. Prompt loops emerge when you can't understand the code | Keep it simple. Document decisions. Use boring, well-tested frameworks |

**The bottom line:** Programmers use these agents as a convenience. Non-programmers need them as **essential infrastructure**. But don't trust any single layer — AI auditors + deterministic tools + human review + runtime testing. The value is in the combination.

---

## Non-Programmer Workflows That Actually Work

These are practical patterns for using Claude Code and subagents when you don't write code yourself.

### Workflow 1: The Describe-Build-Review Loop

The core development cycle for non-programmers. You describe outcomes, AI builds, you review visually, AI reviews structurally.

```
Step 1: Describe what you want (outcomes, not implementation)
   Bad:  "Write a React component with useState hooks"
   Good: "I want a dashboard showing users who haven't logged in for 3 days,
          with a button to send them a nudge email"

Step 2: Work in small increments — one feature per prompt
   "Build the user list display only. Don't add email functionality yet."

Step 3: Review what you can see
   - Open it in a browser. Does it look right?
   - Click every button. Do they work?
   - Test on mobile (resize the window). Does it break?

Step 4: Run auditors on what you can't see
   "Run security-auditor and code-auditor on the changes from this session"

Step 5: Commit to git (your save point)
   "Commit these changes with a description of what was added"

Step 6: Repeat
```

**Critical habit:** Commit after every working increment. Git commits are save points. If AI breaks something three prompts later, you can roll back.

### Workflow 2: Parallel Audit with Subagents

This is where the review agents shine. Claude Code can spawn multiple subagents simultaneously, each checking a different dimension of the code.

```
Run these auditors in parallel on the entire codebase:
- security-auditor
- bug-auditor
- code-auditor
- dep-auditor
- perf-auditor

Then run fix-planner to consolidate and prioritize the findings.
```

Each subagent gets its own context window and runs independently. You get 5 audits in roughly the time of 1.

### Workflow 3: Contractor Code Review

When you receive code from a freelancer or agency, run this sequence:

```
Step 1: Get a plain-English overview
   "Explain this codebase to me like I'm a business owner.
    What does it do? How is it organized?"

Step 2: Compare to your scope of work
   "Here is what my contractor agreed to deliver: [paste SOW].
    Which items are implemented? Which are missing? Which are stubbed out?"

Step 3: Run a full audit
   "Run all 11 auditors in parallel on this codebase"

Step 4: Check for red flags
   "Look for: hardcoded passwords, placeholder data returned instead of
    real database queries, functions that exist but do nothing, tests that
    don't actually verify behavior, and code that only works on the
    contractor's machine"

Step 5: Assess maintainability
   "If this contractor disappeared tomorrow, how hard would it be for
    someone else to take over? Rate 1-10 and explain."
```

### Workflow 4: Weekly Health Check

Run this on a schedule to catch problems before they compound:

```
1. Pull latest code
2. Run full audit (all 11 auditors in parallel)
3. Run fix-planner to prioritize
4. Compare to last week's audit — are things improving or degrading?
5. Focus on P1 (critical) items only
```

The trend matters more than any single audit. If security issues are going up week over week, something is wrong with the development process, not just the code.

### Workflow 5: Pre-Deploy Safety Check

Before shipping anything to real users:

```
Run these in parallel:
- deploy-checker (is the build clean?)
- env-validator (are secrets configured, not hardcoded?)
- dep-auditor (any vulnerable dependencies?)
- security-auditor (any last-minute security issues?)

Give me a single GO or NO-GO recommendation with reasons.
```

### Workflow 6: AI-Builds-Then-Different-AI-Reviews

This addresses the circular validation problem. Use adversarial prompting to make the reviewer skeptical rather than agreeable:

```
You are a skeptical senior engineer reviewing code written by a junior
developer. Your job is to find problems, not to be nice. For each file
changed in the last session:

1. What could go wrong in production?
2. What edge cases aren't handled?
3. What would break if 1000 users hit this at the same time?
4. Are there any security assumptions that might be wrong?

Be harsh. I'd rather fix problems now than discover them in production.
```

This framing significantly improves bug detection compared to a neutral "review this code" prompt.

---

## Automated Guardrails (Set Up Once, Benefit Forever)

These don't require you to understand code. They produce green (pass) or red (fail) signals.

### Priority order for setup:

1. **Branch protection on `main`** — No code reaches production without passing checks
2. **Linting in CI** — Catches formatting issues, unused code, common mistakes automatically
3. **Type checking** — If using TypeScript (strict) or Python (mypy strict), the type checker rejects subtly wrong code
4. **Security scanning** — Semgrep or CodeQL catch vulnerability patterns on every PR
5. **Dependency auditing** — Dependabot auto-opens PRs when libraries have known vulnerabilities
6. **Pre-commit hooks** — Block secrets from being committed, enforce formatting locally
7. **Test coverage threshold** — CI fails if test coverage drops below a minimum (e.g., 70%)

**The key insight:** You don't need to understand the code. You need to understand the traffic light. Green check = safe to merge. Red X = don't merge until it's fixed.

### Secret detection (critical for non-programmers)

AI code generators frequently produce placeholder API keys that get replaced with real ones and accidentally committed. Install `detect-secrets` as a pre-commit hook — it blocks any commit containing what looks like a password, API key, or token.

---

## Using These Agents for Vendor/Contractor Management

### Contract language to include

Require deliverables to pass automated quality checks before acceptance:
- Test coverage >= 70% for business logic
- No critical/high security vulnerabilities (per security-auditor or Snyk)
- Code maintainability rating of B+ or above (per code-auditor)
- Zero hardcoded secrets
- README that lets a new developer set up the project in 30 minutes

### The "bus factor" test

Ask periodically:
```
If this contractor disappeared tomorrow, how hard would it be for a
new developer to take over? Consider: documentation, code organization,
test coverage, deployment docs, and "only they would know" situations.
Rate 1-10.
```

### Weekly contractor check-in verification

```
Show me everything that changed this week. For each change:
1. What was the intent?
2. Is it done properly?
3. Any concerns?

Then compare against what the contractor claimed they completed this week:
[paste their status update]

Which claims are verified by the code? Which can't be verified?
```

---

## Integration with Superpowers Plugin

If you use the superpowers plugin, these review agents complement its pipeline. Superpowers provides structured discipline (brainstorming → spec → plan → TDD → review). These agents provide specialized code analysis. Together:

### What superpowers mitigates

- **Invisible code rot** — Two-stage review (spec compliance + code quality) with fresh subagents per step
- **Refactoring risk** — Forces design decisions before code via brainstorming → spec → plan
- **Circular validation** — Fresh subagent contexts with different prompts for each review stage
- **Lock-in trap** — Plans in `docs/superpowers/plans/` document every decision with exact paths and commands
- **"Works but wrong"** — Verification-before-completion requires evidence, not claims

### What superpowers doesn't cover (where these agents fill gaps)

- **Security, performance, SEO, accessibility, dependency, infrastructure, database** — Superpowers' code-quality-reviewer is general-purpose. The 11 auditors here are specialists.
- **Business-impact translation** — Superpowers speaks technical language only. Audit reports with fix-planner provide severity rankings a non-programmer can act on.
- **Trend tracking** — Running audits weekly and comparing results over time. Superpowers doesn't track longitudinal quality.

### Combined workflow

```
1. Brainstorm → spec → plan (superpowers)
2. Create worktree (superpowers)
3. For each task in the plan:
   a. Implement with TDD (superpowers)
   b. Spec-reviewer + code-quality-reviewer (superpowers)
   c. Run security-auditor + bug-auditor (review agents) ← additional gate
4. Before finishing branch:
   Run full 11-auditor suite (review agents) ← final gate
5. Finish branch — merge, PR, or discard (superpowers)
```

### Where decisions get documented

| What | Where | Purpose |
|------|-------|---------|
| Design rationale | `docs/superpowers/specs/` | Why this approach was chosen |
| Implementation steps | `docs/superpowers/plans/` | What was built and how |
| Quality snapshots | `.claude/audits/` | What's wrong at a point in time |
| Prioritized fixes | `.claude/audits/FIXES.md` | What to fix next, ranked by severity |

### Watch out for

- **Process as substitute for understanding.** The full pipeline (brainstorming → spec review → plan review → TDD → two-stage review → audit) gives the *feeling* of rigor. Make sure you actually understand the specs you're approving, not just that they look thorough.
- **Spec approval without comprehension.** Before approving a spec, ask targeted questions: "What are the tradeoffs? What could go wrong? What am I giving up with this approach?"
- **Subagent cost accumulation.** Each plan task dispatches 3+ subagents (implementer + 2 reviewers). Adding auditor gates on top increases cost. Consider running full audits at branch completion rather than per-task for cost control.

> Full analysis: [docs/research-non-programmer-code-review.md#5-the-superpowers-plugin](docs/research-non-programmer-code-review.md#5-the-superpowers-plugin)

---

## Reports Output

All reports go to `.claude/audits/`:

| File | Source |
|------|--------|
| `AUDIT_SECURITY.md` | security-auditor |
| `AUDIT_BUGS.md` | bug-auditor |
| `AUDIT_CODE.md` | code-auditor |
| `AUDIT_DOCS.md` | doc-auditor |
| `AUDIT_INFRA.md` | infra-auditor |
| `AUDIT_UI_UX.md` | ui-auditor |
| `AUDIT_DB.md` | db-auditor |
| `AUDIT_PERF.md` | perf-auditor |
| `AUDIT_DEPS.md` | dep-auditor |
| `AUDIT_SEO.md` | seo-auditor |
| `API_TEST_REPORT.md` | api-tester |
| `DEPLOY_CHECK.md` | deploy-checker |
| `ENV_REPORT.md` | env-validator |
| `FIXES.md` | fix-planner (prioritized, deduplicated) |
| `TEST_REPORT.md` | test-runner |
| `AUDIT_BROWSER_QA.md` | browser-qa-agent |
| `EXECUTION_LOG.md` | Status tracking for all agents |

## Agent Status Protocol

Every agent report starts with a status block:
```yaml
---
agent: [agent-name]
status: COMPLETE | PARTIAL | SKIPPED | ERROR
timestamp: [ISO timestamp]
findings: [count]
---
```

---

## Don't Touch

- `.env` files (contain secrets)
- Production databases
- Deployed infrastructure
