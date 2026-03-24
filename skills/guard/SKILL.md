---
name: guard
description: Main entry point for Code Guardian. Run with no arguments for help, or with a command name to dispatch. Examples - "/code-guardian:guard", "/code-guardian:guard quick-check", "/code-guardian:guard audit".
---

Code Guardian — your codebase's safety net.

## Behavior

Parse `$ARGUMENTS` to determine what the user wants.

### If no arguments, or arguments contain "help"

Show this menu:

```
Code Guardian — codebase guardrails in plain English

Quick commands:
  /code-guardian:guard quick-check    Fast scan before committing (GO / CONCERNS / STOP)
  /code-guardian:guard audit          Full review across all 9 areas
  /code-guardian:guard explain        Understand code without jargon
  /code-guardian:guard review-code    Evaluate code you didn't write

Before shipping:
  /code-guardian:guard pre-deploy     Deployment readiness check (GO / BLOCKED)

Dashboards:
  /code-guardian:guard health-report  Red/yellow/green status overview
  /code-guardian:guard compare        See what improved or regressed since last audit

Starting fresh:
  /code-guardian:guard language-advisor  Stack recommendations for a new project

Tip: You can also call any command directly, e.g. /code-guardian:quick-check
```

Then ask: "What would you like to do?"

### If arguments match a command name

Invoke the matching skill using the Skill tool:

| Argument | Invoke |
|---|---|
| `quick-check`, `check`, `qc` | `code-guardian:quick-check` |
| `audit`, `full`, `full-audit` | `code-guardian:audit` |
| `explain` | `code-guardian:explain` |
| `review-code`, `review` | `code-guardian:review-code` |
| `pre-deploy`, `deploy` | `code-guardian:pre-deploy` |
| `health-report`, `health`, `status` | `code-guardian:health-report` |
| `compare`, `diff`, `trend` | `code-guardian:compare` |
| `language-advisor`, `language`, `stack` | `code-guardian:language-advisor` |

Pass any remaining arguments through to the invoked skill.

### If arguments don't match any command

Say: "I don't recognize that command. Here's what's available:" and show the help menu above.
