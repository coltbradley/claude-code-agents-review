---
name: language-advisor
description: Use when starting a new project or considering a language or framework change — recommends the right stack based on your goals, with honest tradeoffs about AI code generation quality and type safety.
---

# language-advisor

Interactive Q&A that recommends the right language and framework for a new project.

## Steps

### 1. Ask ONE question at a time — do not ask multiple questions at once

**Q1:** "What are you building?"
Options: Web app, API/backend service, CLI tool, data pipeline, mobile app, desktop app, other

**Q2:** "What matters most to you?"
Options:
- Safety (catching bugs before they run)
- Speed to launch (get something working fast)
- Simplicity (easy to understand and maintain)
- Performance (handles heavy load or large data)

**Q3:** "Who will maintain this long-term?"
Options:
- Just me with AI tools
- A small team (2-5 people)
- Contractors or freelancers
- I don't know yet

### 2. After all three answers, present the recommendation in this structure

**Recommendation: [Language] + [Framework]**

**Why this fits:**
[2-3 sentences connecting the recommendation to their specific answers]

**What you gain:**
- Compile-time safety: [what the compiler catches vs what slips through]
- AI code generation quality: [how well AI writes this language]
- Deployment: [what shipping looks like]
- Ecosystem: [available libraries, community size]

**What you give up:**
[Honest about downsides — every choice has tradeoffs]

**Type Safety Rating:** [Low / Medium / High / Very High]
This matters because when AI generates code, the type system acts as an automatic reviewer. Higher type safety = more AI mistakes caught before they run.

**AI Generation Quality:** [Excellent / Good / Fair]
Based on training data volume and benchmark performance.

### 3. Decision framework (apply this to every recommendation)

- Web projects → TypeScript (strict mode) + Next.js, Remix, or SvelteKit
- APIs → TypeScript (strict) + Fastify/Hono OR Go + standard library OR Rust + Actix
- CLIs → Go or Rust (single binary, no runtime dependency)
- Data pipelines → Python with mypy strict, or Rust
- If safety is the #1 priority → Rust
- If speed to launch is the #1 priority → TypeScript or Python
- If simplicity is the #1 priority → Go
- Python is only recommended for: throwaway scripts, data science, ML, or prototypes

### 4. Close with this offer

"Want me to create a starter CLAUDE.md with this stack configured?"
