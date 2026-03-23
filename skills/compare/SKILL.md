---
name: compare
description: Use when you want to compare the current state of the codebase against a previous audit — shows what improved, what regressed, and trends over time.
---

# compare

Run a full audit then compare results against the most recent previous snapshot.

## Steps

1. Run a full audit: dispatch all 9 auditors in parallel, then run fix-planner on the combined results.

2. Save a snapshot:
   - Create directory `.claude/audits/snapshots/YYYY-MM-DD/` (use today's date)
   - Copy all current `AUDIT_*.md` and `FIXES.md` into that directory

3. Find the most recent previous snapshot:
   - List directories in `.claude/audits/snapshots/`
   - Pick the most recent one that is not today's date

4. If no previous snapshot exists:
   - Tell the user: "This is your first audit snapshot. I've saved today's results. Run /code-guardian:compare again next week to see trends."
   - Display today's executive summary
   - Stop here

5. If a previous snapshot exists, compare the two:
   - Parse finding counts from each snapshot's status blocks
   - For each audit area, report one of:
     - Improved (count went down): "Security: 5 → 2 ✅ (3 fixed)"
     - Regressed (count went up): "Bugs: 1 → 4 ⚠️ (3 new issues)"
     - Unchanged: "Dependencies: 0 → 0 ✅ (still clean)"
     - Changed status: "Database: SKIPPED → 3 findings (new database code detected)"

6. Present the trend report in this format:

```
# Code Guardian — Trend Report
Comparing: [previous date] → [today]

## Changes by Area
| Area | Before | After | Trend |
|------|--------|-------|-------|
| Security | X findings | Y findings | ✅ Improving / ⚠️ Regressing / ➡️ Stable |
| ... | ... | ... | ... |

## What Improved
- [plain English list of what got better]

## What Regressed
- [plain English list of what got worse]

## Overall Trend
[One paragraph: is the codebase getting healthier or not?]
```

7. Save the trend report to `.claude/audits/TREND_REPORT.md`
