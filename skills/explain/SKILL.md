---
name: explain
description: Use when you want to understand code, a file, a directory, or recent changes in plain English — no auditing, purely educational. Helps you learn what AI built for you.
---

This skill is purely educational — NO auditing, NO judgment, NO recommendations. Just explanation.

1. Determine what the user wants explained. Use $ARGUMENTS if provided, otherwise ask:
   "What would you like me to explain? Options:
   - A specific file (give me the path)
   - A directory or module
   - Recent changes (I'll look at git diff)
   - The whole project (I'll give an overview)"

2. Read the target

3. Explain in plain English, structured as:
   **What it does:** Purpose in one paragraph. No jargon.
   **How it's organized:** Structure, main pieces, how they connect. Use analogies where helpful.
   **Key decisions:** Why it's built this way (infer from patterns). What alternatives existed.
   **What depends on what:** Relationships between components. What would break if you changed X.

4. For code files specifically:
   - Walk through the file section by section
   - Explain each function/class in one sentence
   - Highlight anything unusual or non-obvious
   - If there are comments, explain what they mean

5. Offer to go deeper: "Want me to explain any section in more detail?"

6. If explaining recent changes (git diff):
   - Show what changed in plain English
   - Explain why (infer from context)
   - Note any concerns (but frame as educational, not audit)

Keep the tone conversational and approachable. This is a learning tool.
