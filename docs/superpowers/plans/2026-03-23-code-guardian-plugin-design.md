# Code Guardian Plugin — Design Document

> **Date:** 2026-03-23
> **Status:** Approved
> **Plugin name:** code-guardian
> **Namespace:** `/code-guardian:*`

## Vision

A Claude Code plugin that provides code-agnostic guardrails for non-programmers building software with AI tools. Think of it as a QA team that reads your codebase and reports back in plain English — what's wrong, why it matters, and what to do about it.

## Who This Is For

People who work with code but don't write it themselves. They build with AI (vibe coding), manage contractors, pull in open-source projects, or inherit codebases. They need to know if things are going off the rails without being able to read the code themselves.

## Design Principles

1. **Code-agnostic.** Works on any language, any framework. Agents detect the project's stack and adapt. Checks that don't apply skip gracefully.
2. **Plain English first.** Every finding is explained so a non-programmer can understand and act on it. Technical details are included for learning and developer handoff, but never required to understand the report.
3. **Adversarial by default.** Agents are prompted to find problems, not approve code. "What could go wrong" not "does this look okay."
4. **Layered output.** Executive summary → plain-English findings → technical detail. Read as deep as you want.
5. **Severity = business impact.** P1 isn't "critical CVE" — it's "someone could steal your users' data." P4 isn't "code smell" — it's "future changes will be harder but nothing breaks today."
6. **Standalone, complements superpowers.** Works independently. When superpowers is also installed, skills are designed to be used at natural points in the superpowers workflow (documented, not enforced).
7. **Tiered intervention.** Auto checks are minimal, fast, and deterministic (no AI). AI-powered checks are suggested or manual.

---

## Architecture

### Agents (12 total)

#### Core Auditors (9)

Each auditor is a specialist with non-overlapping scope. All produce the layered output format. All skip gracefully when their domain doesn't apply.

| Agent | File | Scope | Skips when |
|-------|------|-------|-----------|
| security-auditor | `agents/security-auditor.md` | Secrets in code, injection attacks, auth gaps, data exposure, crypto issues | Never |
| bug-auditor | `agents/bug-auditor.md` | Crashes, null refs, race conditions, error handling, logic errors | Never |
| code-quality-auditor | `agents/code-quality-auditor.md` | Duplication, complexity, naming consistency, dead code, structural mess | Never |
| dependency-auditor | `agents/dependency-auditor.md` | Vulnerable deps, outdated packages, unused deps, license conflicts | No dependency file found |
| documentation-auditor | `agents/documentation-auditor.md` | Missing docs, outdated comments, README gaps, setup instructions | Never |
| infrastructure-auditor | `agents/infrastructure-auditor.md` | Config files, env vars, deployment settings, health checks, CORS | No config/infra files found |
| performance-auditor | `agents/performance-auditor.md` | Slow queries, large bundles, unoptimized assets, O(n^2) patterns | Never |
| database-auditor | `agents/database-auditor.md` | N+1 queries, missing indexes, schema issues, migration safety | No database code found |
| api-auditor | `agents/api-auditor.md` | Endpoint design, validation, response consistency, error responses, rate limiting | No API code found |

**Non-overlapping scope enforcement:** Each agent explicitly lists what it does NOT check and which other agent handles it. Prevents duplicate findings.

#### Action Agents (3)

| Agent | File | What it does |
|-------|------|-------------|
| fix-planner | `agents/fix-planner.md` | Reads all audit reports, deduplicates findings, prioritizes P1→P4, produces FIXES.md with layered output |
| code-fixer | `agents/code-fixer.md` | Implements fixes from FIXES.md, follows existing code patterns, explains changes in plain English |
| test-runner | `agents/test-runner.md` | Runs project tests, reports results in plain English (what passed, what failed, what it means) |

### Universal Agent Prompt Structure

Every agent follows this template:

```markdown
---
name: [agent-name]
description: [what it checks]
tools: Read, Grep, Glob, Bash
model: inherit
---

# [Agent Name]

You are a code review specialist focused on [domain].

## Audience

Your reports are read by NON-PROGRAMMERS who build software with AI tools.
They cannot read code. They need to understand what's wrong, why it matters,
and what to do about it — in plain English.

## Language & Framework

You are language-agnostic. Detect the project's language(s) and adapt your
checks accordingly. Do not assume any specific framework or stack.
If a check doesn't apply to this project's language, skip it gracefully.

## Output Format

Start every report with a status block:
---
agent: [agent-name]
status: COMPLETE | PARTIAL | SKIPPED | ERROR
timestamp: [ISO timestamp]
findings: [count]
critical: [count]
important: [count]
minor: [count]
---

Then use the layered format:

### Executive Summary
[emoji] [count] critical | [emoji] [count] important | [emoji] [count] minor
One-paragraph plain-English overview.

### Findings
For each finding:
**[ID] Finding Title**
**Severity:** Critical / Important / Minor
**What's wrong:** Plain English anyone can understand.
**Why it matters:** Business/user impact if ignored.
**Technical detail:** [file:line] — specific technical description.
**Suggested fix:** Plain English + technical specifics.

### Recommendations
Prioritized list of what to do next.

## Scope
[What this agent checks]

## Not In Scope
[What other agents handle — explicit delegation]

## Checks
[Domain-specific checks with patterns]
```

---

### Skills (8)

Each skill is a `/code-guardian:skill-name` slash command.

#### `/code-guardian:audit` — Full Audit

**Trigger:** "Run a full audit" / weekly health check / before release
**Description:** "Use when you want a comprehensive code review across all areas — security, bugs, quality, dependencies, documentation, infrastructure, performance, database, and API"

**Flow:**
1. Detect project language(s) and structure
2. Dispatch all 9 auditors in parallel as subagents
3. Each auditor writes its report to `.claude/audits/`
4. Wait for all to complete
5. Dispatch fix-planner to consolidate and prioritize
6. Present executive summary: "Found X critical, Y important, Z minor issues across 9 areas. Top 3 things to address: [plain English list]. Full reports in .claude/audits/. Prioritized fix list in FIXES.md."

#### `/code-guardian:quick-check` — Fast Check

**Trigger:** "Is this okay?" / before committing / after changes
**Description:** "Use when you want a fast check before committing or after making changes — runs security, bug, and code quality checks only"

**Flow:**
1. Dispatch security + bug + code-quality auditors in parallel (3 only)
2. Present combined summary — no fix-planner step
3. Verdict:
   - GO: "No critical issues. Safe to commit."
   - CONCERNS: "2 issues worth looking at before committing: [list]"
   - STOP: "Found critical problems. Fix these first: [list]"

#### `/code-guardian:review-code` — External Code Review

**Trigger:** "Review this contractor code" / "I pulled in a new repo"
**Description:** "Use when reviewing code you didn't write — contractor deliveries, GitHub repos, inherited projects, or open-source libraries you're incorporating"

**Flow:**
1. Ask: "What am I reviewing?" — context (contractor, GitHub repo, inherited project). Optional: paste scope of work.
2. Explain the codebase in plain English (structure, purpose, tech stack)
3. If SOW provided: compare delivered code against it (done, missing, stubbed out)
4. Run full 9-auditor suite in parallel
5. Red flag scan: hardcoded secrets, placeholder data, empty functions, tests that don't assert, vendor lock-in patterns
6. Bus factor assessment (1-10): "If this person disappeared, how hard is the handoff?"
7. Final verdict: Accept / Accept with conditions / Push back

#### `/code-guardian:pre-deploy` — Deploy Readiness

**Trigger:** "Is this safe to ship?"
**Description:** "Use before deploying to production — checks security, infrastructure, dependencies, and API endpoints for deployment blockers"

**Flow:**
1. Dispatch security + infrastructure + dependency + api auditors (4) in parallel
2. Check for: build errors, exposed secrets, debug mode, missing env vars, vulnerable deps, broken endpoints
3. Single verdict: GO or BLOCKED
4. If blocked: numbered list of what must be fixed, in plain English

#### `/code-guardian:explain` — Code Translation

**Trigger:** "What does this do?" / "Explain this file"
**Description:** "Use when you want to understand code, a file, a directory, or recent changes in plain English — no auditing, purely educational"

**Flow:**
1. User points at: file, directory, diff, or "the whole project"
2. Read the target
3. Explain: what it does (purpose), how it's organized (structure), key decisions (why built this way), what depends on what (relationships)
4. No auditing, no judgment
5. Offer to go deeper on any section

#### `/code-guardian:health-report` — Dashboard

**Trigger:** "How's the codebase?" / status for stakeholders
**Description:** "Use when you want a single-page health dashboard of your codebase — red/yellow/green status designed to share with stakeholders"

**Flow:**
1. Run full audit (or use most recent if <24 hours old)
2. Generate single-page dashboard:
   ```
   🔴 Security: 3 critical findings
   🟢 Bugs: No issues found
   🟡 Code Quality: 5 issues (none critical)
   🟢 Dependencies: All current, no vulnerabilities
   ...
   Overall: 🟡 NEEDS ATTENTION
   Top priority: Fix the 3 security issues before anything else.
   ```
3. Designed to be copy-pasted to stakeholder or team chat

#### `/code-guardian:compare` — Trend Tracking

**Trigger:** "Is it getting better or worse?"
**Description:** "Use when you want to compare the current state of the codebase against a previous audit — shows what improved, regressed, or is unchanged"

**Flow:**
1. Run full audit
2. Save snapshot to `.claude/audits/snapshots/YYYY-MM-DD/`
3. Find most recent previous snapshot
4. Diff: what improved (fixed), what regressed (new), what's unchanged
5. Trend summary: "Security improving, code quality declining, deps stable"
6. If no previous snapshot: "This is your first audit. Run again next week to start tracking trends."

#### `/code-guardian:language-advisor` — Pre-Project Guidance

**Trigger:** Starting a new project / considering a rewrite
**Description:** "Use when starting a new project or considering a language/framework change — recommends the right stack based on your goals, with honest tradeoffs"

**Flow:**
1. Ask: "What are you building?" (web app, CLI, API, data pipeline, etc.)
2. Ask: "What matters most?" (safety, speed to launch, simplicity, performance)
3. Ask: "Who maintains this long-term?" (just you + AI, small team, contractors)
4. Recommend language + framework with rationale:
   - Why this fits your answers
   - Tradeoffs (honest about downsides)
   - Compile-time safety (what the compiler catches vs what slips through)
   - AI generation quality in this language
5. Offer to create a starter CLAUDE.md with the recommended stack

---

### Hooks (Auto Tier)

Lightweight, deterministic, no AI. Defined in `hooks/hooks.json`.

#### Pre-commit hooks (block on failure)

| Hook | Script | What it catches |
|------|--------|----------------|
| Secret detection | `hooks/scripts/detect-secrets.sh` | API keys, passwords, tokens in staged files. Grep for patterns: `sk-`, `AKIA`, `ghp_`, `password\s*=\s*['"]`, etc. |
| .env protection | `hooks/scripts/check-env-files.sh` | .env, .env.local, .env.production in staged files |
| Large file warning | `hooks/scripts/check-large-files.sh` | Staged files >500KB |

#### Post-tool-use hook (advisory)

| Hook | Script | When |
|------|--------|------|
| Change size nudge | `hooks/scripts/change-size-nudge.sh` | After Write/Edit, if 5+ files changed in session. Prints reminder to run quick-check. |

**Implementation:** Hooks return exit code 2 to block (pre-commit), or exit 0 with stdout message (advisory).

---

### Output Locations

```
.claude/
├── audits/
│   ├── AUDIT_SECURITY.md
│   ├── AUDIT_BUGS.md
│   ├── AUDIT_CODE_QUALITY.md
│   ├── AUDIT_DEPENDENCIES.md
│   ├── AUDIT_DOCUMENTATION.md
│   ├── AUDIT_INFRASTRUCTURE.md
│   ├── AUDIT_PERFORMANCE.md
│   ├── AUDIT_DATABASE.md
│   ├── AUDIT_API.md
│   ├── FIXES.md
│   ├── TEST_REPORT.md
│   ├── HEALTH_REPORT.md
│   └── snapshots/
│       └── YYYY-MM-DD/
│           └── (copies of all audit files for trend comparison)
```

All audit output is gitignored via `.claude/.gitignore`.

---

### Plugin Packaging

#### File Structure

```
code-guardian/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── security-auditor.md
│   ├── bug-auditor.md
│   ├── code-quality-auditor.md
│   ├── dependency-auditor.md
│   ├── documentation-auditor.md
│   ├── infrastructure-auditor.md
│   ├── performance-auditor.md
│   ├── database-auditor.md
│   ├── api-auditor.md
│   ├── fix-planner.md
│   ├── code-fixer.md
│   └── test-runner.md
├── skills/
│   ├── audit/SKILL.md
│   ├── quick-check/SKILL.md
│   ├── review-code/SKILL.md
│   ├── pre-deploy/SKILL.md
│   ├── explain/SKILL.md
│   ├── health-report/SKILL.md
│   ├── compare/SKILL.md
│   └── language-advisor/SKILL.md
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       ├── detect-secrets.sh
│       ├── check-env-files.sh
│       ├── check-large-files.sh
│       └── change-size-nudge.sh
├── CLAUDE.md
├── README.md
├── LICENSE
├── CHANGELOG.md
└── package.json
```

#### plugin.json

```json
{
  "name": "code-guardian",
  "version": "1.0.0",
  "description": "Code-agnostic guardrails for non-programmers building with AI tools. 9 specialist auditors + 8 workflow skills that report in plain English.",
  "author": {
    "name": "Colt Bradley",
    "url": "https://github.com/coltbradley"
  },
  "license": "MIT",
  "repository": "https://github.com/coltbradley/code-guardian",
  "keywords": ["audit", "code-review", "non-programmer", "vibe-coding", "guardrails", "security"],
  "agents": "agents/",
  "skills": "skills/",
  "hooks": "hooks/hooks.json",
  "minClaudeCodeVersion": "1.0.0"
}
```

---

### Superpowers Integration (Documented, Not Enforced)

The plugin's CLAUDE.md and skill descriptions guide Claude to suggest code-guardian skills at natural points in the superpowers workflow:

| Superpowers moment | Suggested code-guardian skill | Why |
|-------------------|------------------------------|-----|
| Starting brainstorming, no code exists yet | `/code-guardian:language-advisor` | Make the right language choice before writing anything |
| After a plan task completes | `/code-guardian:quick-check` | Catch issues early, before they compound |
| Before `finishing-a-development-branch` | `/code-guardian:audit` | Full review before merge |
| Pulling in external code during a plan | `/code-guardian:review-code` | Evaluate before incorporating |
| Preparing a release | `/code-guardian:pre-deploy` | Deployment readiness gate |

No hard dependency on superpowers. No hooks that fire on superpowers events. Just well-written skill descriptions and CLAUDE.md guidance.

---

### Research Foundation

This design is informed by extensive research documented in:
- `docs/research-non-programmer-code-review.md` — failure modes, circular validation, language tradeoffs, superpowers analysis
- `docs/non-programmer-claude-code-workflows.md` — practical Claude Code playbooks

Key risks this plugin addresses:
1. **Circular validation** → Adversarial prompting, multiple specialist agents with non-overlapping scopes
2. **Invisible code rot** → Weekly audits via `/code-guardian:compare`, code-quality-auditor as always-on specialist
3. **"Works but wrong"** → Layered output that surfaces business impact, not just technical status
4. **Language choice** → `/code-guardian:language-advisor` before starting projects
5. **Lock-in trap** → Documentation-auditor checks for setup instructions and bus factor
6. **Security blindness** → Security-auditor runs in every workflow (audit, quick-check, pre-deploy, review-code)
7. **Refactoring risk** → Audit before AND after major changes via `/code-guardian:compare`

### What This Plugin Does NOT Do

- **Write code for you.** code-fixer implements specific fixes from FIXES.md, but the plugin is primarily about review, not generation.
- **Replace human review for consequential decisions.** Security, payments, user data — get a human to look at it. This plugin is a first pass, not a gate.
- **Modify the superpowers plugin.** Standalone, complementary, no coupling.
- **Run expensive AI checks automatically.** Auto-tier is shell scripts only. AI agents are suggested or manual.
