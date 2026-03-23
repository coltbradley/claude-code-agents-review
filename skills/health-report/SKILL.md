---
name: health-report
description: Use when you want a single-page health dashboard of your codebase — red/yellow/green status across all areas. Designed to share with stakeholders or team members.
---

1. Check if recent audit results exist in `.claude/audits/` (less than 24 hours old based on file timestamps)
   - If yes: use existing results
   - If no: run full audit first (dispatch all 9 auditors in parallel, then fix-planner)

2. Read all audit reports and FIXES.md

3. Generate a single-page health dashboard. Use this EXACT format:

```
# Codebase Health Report
Generated: [date and time]

## Status Dashboard

| Area | Status | Findings |
|------|--------|----------|
| Security | 🔴/🟡/🟢 | X critical, Y important |
| Bugs | 🔴/🟡/🟢 | ... |
| Code Quality | 🔴/🟡/🟢 | ... |
| Dependencies | 🔴/🟡/🟢 | ... |
| Documentation | 🔴/🟡/🟢 | ... |
| Infrastructure | 🔴/🟡/🟢 | ... |
| Performance | 🔴/🟡/🟢 | ... |
| Database | 🔴/🟡/🟢 | ... |
| API | 🔴/🟡/🟢 | ... |

## Overall: 🔴/🟡/🟢 [ONE WORD STATUS]

## Top Priority
[1-3 sentences: what to fix first and why]

## Summary
[One paragraph plain-English overview]
```

Status rules:
- 🔴 RED = any critical findings
- 🟡 YELLOW = important findings but no critical
- 🟢 GREEN = minor or no findings
- Skipped auditors show as ⚪ N/A

4. Save to `.claude/audits/HEALTH_REPORT.md`
5. Display the dashboard directly to the user (it's designed to be copy-pasted)
