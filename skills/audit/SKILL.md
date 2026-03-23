---
name: audit
description: Use when you want a comprehensive code review across all areas — security, bugs, quality, dependencies, documentation, infrastructure, performance, database, and API. Also use for weekly health checks or before releases.
---

## Steps

1. Detect project language(s) and structure by looking for dependency files (package.json, requirements.txt, go.mod, Cargo.toml, etc.) and dominant file extensions.

2. Create `.claude/audits/` directory if it does not exist.

3. Dispatch ALL 9 auditor agents in parallel as subagents. Each agent audits the project's source code and saves its report to the specified file:
   - security-auditor → `.claude/audits/AUDIT_SECURITY.md`
   - bug-auditor → `.claude/audits/AUDIT_BUGS.md`
   - code-quality-auditor → `.claude/audits/AUDIT_CODE_QUALITY.md`
   - dependency-auditor → `.claude/audits/AUDIT_DEPENDENCIES.md`
   - documentation-auditor → `.claude/audits/AUDIT_DOCUMENTATION.md`
   - infrastructure-auditor → `.claude/audits/AUDIT_INFRASTRUCTURE.md`
   - performance-auditor → `.claude/audits/AUDIT_PERFORMANCE.md`
   - database-auditor → `.claude/audits/AUDIT_DATABASE.md`
   - api-auditor → `.claude/audits/AUDIT_API.md`

   Each report must use consistent severity labels: **critical**, **important**, **minor**.

4. Wait for all 9 agents to complete before proceeding.

5. Dispatch a fix-planner agent to read all 9 reports and produce `.claude/audits/FIXES.md` — a prioritized, actionable fix list ordered by severity and impact.

6. Present an executive summary to the user:
   - Total finding counts by severity (critical / important / minor) across all reports
   - Which auditors found issues and which were clean
   - Top 3 things to address first, in plain English
   - "Full reports in .claude/audits/. Prioritized fix list in FIXES.md."

> Note: If using superpowers, this is a good skill to run before finishing a development branch.
