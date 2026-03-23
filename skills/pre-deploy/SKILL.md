---
name: pre-deploy
description: Use before deploying to production — checks security, infrastructure, dependencies, and API endpoints for deployment blockers. Gives a GO or BLOCKED verdict.
---

## Step 1: Dispatch Auditors in Parallel

Using the Agent tool, dispatch these 4 auditors simultaneously:
- `security-auditor`
- `infrastructure-auditor`
- `dependency-auditor`
- `api-auditor`

Wait for all four to complete before proceeding.

## Step 2: Check for Deployment Blockers

Review auditor findings specifically for these blockers:
- Exposed secrets or credentials in source code or config files
- Debug mode enabled in production configuration
- Missing or incomplete environment variable configuration
- Vulnerable dependencies with known, actively exploited CVEs
- Broken or internally inconsistent API endpoints
- Missing health check endpoint (required for load balancers and orchestrators)

## Step 3: Deliver Verdict

Present a single, unambiguous verdict:

- **GO** — "Ready to deploy. No blockers found. [One sentence summarizing what was checked and found clean.]"
- **BLOCKED** — "Do NOT deploy. X blockers found:" followed by a numbered list where each item is one plain-English sentence explaining what is wrong and exactly what needs to be done to fix it before deploying.

Do not include recommendations, suggestions, or nice-to-haves in the verdict. Only blockers belong in a BLOCKED list.
