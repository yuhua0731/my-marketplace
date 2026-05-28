---
name: codex-review-council
description: Use when the user explicitly asks Copilot, GitHub Copilot, a Claude-backed Copilot reviewer, dual reviewers, reviewer cross-checking, or a review council to participate in local code review.
type: discipline
---

# Codex Review Council

Add Copilot as an extra local reviewer only when the user explicitly asks for it. Do not change normal brainstorming, planning, implementation, or verification flow.

## Trigger Boundary

Use this skill for explicit requests such as:

- "let Copilot review this too"
- "use Copilot as reviewer"
- "Codex reviewer and Copilot reviewer"
- "dual reviewer"
- "review council"
- "Claude-backed Copilot review"

Do not use this skill for ordinary feature work, bug fixes, or generic "review my code" requests that do not mention Copilot or dual reviewers. In those cases, keep the normal code review flow.

## Council Flow

1. Complete implementation and normal verification first.
2. Run the normal Codex reviewer path for the current environment.
3. Run Copilot review with the bundled script:

```bash
scripts/review_with_copilot.sh
```

If the current shell is not in this skill directory, locate the installed skill directory first, then run the script from there.

4. Treat both reviews as external feedback.
5. Apply code-review reception discipline to every finding:
   - verify against code
   - accept and fix if correct
   - reject with technical reason if wrong
   - ask the user if architectural or unverifiable
6. Cross-check disagreement:
   - Codex-only finding: compare against Copilot output and code evidence.
   - Copilot-only finding: compare against Codex reviewer output and code evidence.
   - Conflicting findings: resolve by code/tests, not reviewer authority.
7. Produce a council decision:
   - accepted findings
   - rejected findings with reasons
   - user-decision items
8. Fix accepted findings, run relevant tests, and rerun the council if the fixes materially change code.

## Copilot Script Options

```bash
# staged + unstaged tracked changes versus HEAD
scripts/review_with_copilot.sh

# staged changes only
scripts/review_with_copilot.sh --staged

# branch changes versus a base ref
scripts/review_with_copilot.sh --base origin/main

# choose a model
scripts/review_with_copilot.sh --model claude-opus-4.7
```

Default model: `claude-sonnet-4.6`.

## Output Contract

Before handing work back to the code writer, summarize:

```text
Accepted:
- [severity] file:line issue -> action

Rejected:
- file:line suggestion -> reason

Needs user decision:
- question and options
```

If both reviewers have no actionable findings, say so and continue to normal completion.

## Commit Boundary

This skill never commits by itself. Before any commit or push, follow the user's git identity confirmation rule.
