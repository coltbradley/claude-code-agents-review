---
name: quick-check
description: Use when you want a fast check before committing or after making changes — runs security, bug, and code quality checks only. Gives a GO/CONCERNS/STOP verdict.
---

## Steps

1. Dispatch 3 auditor agents in parallel as subagents:
   - security-auditor
   - bug-auditor
   - code-quality-auditor

   Each agent audits the project's source code and returns its findings with severity labels: **critical**, **important**, **minor**.

2. Wait for all 3 agents to complete.

3. Analyze findings across all three reports. Then present a single verdict — choose exactly one:

   - **GO** ✅ "No critical issues found. Safe to commit."
   - **CONCERNS** ⚠️ "X issues worth looking at before committing: [plain English list]"
   - **STOP** 🔴 "Found critical problems that should be fixed first: [plain English list]"

   Verdict rules:
   - Any **critical** finding → STOP
   - Any **important** finding → CONCERNS
   - Only **minor** findings or none → GO

4. If the verdict is CONCERNS or STOP, list each issue as one plain-English sentence.

5. Close with: "For a deeper review across all areas, run /code-guardian:audit"
