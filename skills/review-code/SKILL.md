---
name: review-code
description: Use when reviewing code you didn't write — contractor deliveries, GitHub repos you're pulling in, inherited projects, or open-source libraries you're incorporating. Guides you through a structured evaluation.
---

## Phase 1: Context Gathering

Ask the user:
1. "What am I reviewing? (contractor delivery, GitHub repo, inherited project, open-source library)"
2. "Do you have a scope of work or requirements doc to compare against?" (optional — use $ARGUMENTS if provided)

## Phase 2: Codebase Overview

Read the project structure and explain in plain English:
- What the project does
- How it is organized
- What tech stack it uses
- How large it is (file count, rough line count)

## Phase 3: Scope Verification (if SOW provided)

Compare the code against the scope of work or requirements doc. Report:
- What is fully implemented
- What is partially done
- What is missing entirely
- What is extra (implemented but not in scope)

## Phase 4: Full Audit

Dispatch all 9 auditors in parallel using the Agent tool:
`security-auditor`, `bug-auditor`, `code-quality-auditor`, `dependency-auditor`,
`documentation-auditor`, `infrastructure-auditor`, `performance-auditor`, `database-auditor`, `api-auditor`

Wait for all to complete, then dispatch `fix-planner` with their combined findings.

## Phase 5: Red Flag Scan

Specifically check for contractor red flags:
- Hardcoded secrets or credentials anywhere in the codebase
- Placeholder data returned instead of real database queries
- Functions that exist but do nothing (stubs, `pass`, `return None`, `TODO`)
- Tests that don't assert anything meaningful (empty tests, always-pass assertions)
- Code that depends on the contractor's personal infrastructure or accounts
- Vendor lock-in patterns that would be costly to reverse

## Phase 6: Bus Factor Assessment

Rate 1–10: how hard would it be for someone new to take over this project?

Base the rating on:
- Quality and completeness of documentation
- Code organization and naming clarity
- Test coverage and test quality
- Deployment and setup documentation

Explain the rating in one paragraph.

## Phase 7: Final Verdict

Deliver one of three verdicts in plain English:

- **Accept** — Code meets requirements, quality is acceptable, safe to use.
- **Accept with conditions** — Code works but has issues that should be fixed before relying on it. List each condition as a plain-English bullet.
- **Push back** — Significant problems that must be addressed before acceptance. List each problem as a plain-English bullet with what needs to be done.
