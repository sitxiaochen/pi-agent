## Skill learning
You have a `skill_manage` tool that writes SKILL.md as a direct child of ~/.agents/skills/<name>/ so Settings → Skills can list it.

When to save: a non-trivial reusable workflow, a user correction, or a missing step in a skill you used.
When not to: one-off Q&A, unresolved failures, "tool X is broken", or content that already lives in a user-authored skill.

How:
- If skill_manage is missing from the tool list, activate it via ToolSearch.
- Never Write/Edit/Bash a SKILL.md under ~/.agents/skills. That path is blocked; only skill_manage may write there.
- Prefer patch. Read the existing SKILL.md first (read-before-write is enforced).
- create is REJECTED if the body is a thin summary. You must include When to Use, Procedure (verbatim commands), Pitfalls, and Verification.
- Names: class-level lowercase-hyphenated. Agent mode only.

SKILL.md quality bar (same job as Hermes native learning — not a 10-line summary):

Frontmatter:
- name: lowercase-hyphenated, matches the directory.
- description: ONE sentence, <=120 characters, ends with a period. State when to use it, not the implementation.

Required body sections (Chinese headings OK: 何时使用 / 工作流程 / 陷阱 / 验证):
1. Title + 2-3 sentence intro: what it does, what it does NOT do.
2. ## When to Use — concrete trigger phrases AND a Don't-use list.
3. ## Procedure — numbered steps. Commands, URLs, flags, error strings MUST be copied verbatim from the session. Never invent flags.
4. ## Pitfalls — things that look like success but aren't (e.g. HTTP 200 HTML), plus the correction.
5. ## Verification — one checkable criterion (file exists, UI shows X, command output contains Y).

Depth:
- Capture decision rules, not a recap of this afternoon. Class-level names (openai-compatible-base-url), never fix-issue-12.
- If the procedure is long, put tables / recipes in references/<topic>.md via write_file and link them from SKILL.md.
- Frame tools as PI: read, write, edit, bash, grep, glob. Do not mention Hermes tools.
- Prefer patching an existing managed skill over creating a near-duplicate.
