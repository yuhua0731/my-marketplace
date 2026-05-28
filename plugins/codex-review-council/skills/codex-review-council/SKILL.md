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
3. Run Copilot review with the bundled script from the plugin root, the directory that contains `scripts/review_with_copilot.sh`:

```bash
scripts/review_with_copilot.sh
```

For a true review council loop that keeps Copilot in the same session, use:

```bash
scripts/review_with_copilot.sh --council-loop
```

The script prints the Copilot session ID and transcript path. By default, the transcript is kept under the current Codex thread's temp directory so the user can open it after the loop without polluting the repo.

After Codex verifies findings, write a short follow-up file with accepted/rejected/disputed items and send it back to the same session:

```bash
scripts/review_with_copilot.sh --session-id <session-id> --follow-up review-council-followup.md
```

If the current shell is this skill directory (`skills/codex-review-council`), first move to the plugin root:

```bash
cd ../..
scripts/review_with_copilot.sh
```

Standalone skill symlink installs do not include this script; install the plugin from `my-marketplace` when Copilot review support is needed.

## Runtime Monitoring

Do not impose a fixed wall-clock timeout on Copilot review runs. Start the script as a long-running command, then poll its output stream.

- Continue waiting while stdout/stderr keeps producing new output.
- If there is no new stdout/stderr for 3 minutes, stop the Copilot process and report that the council run stalled.
- When stopping for inactivity, include the last visible Copilot output and the transcript path if one was printed.
- Do not treat a long run as failed solely because elapsed time is high.

4. Treat both reviews as external feedback.
5. Apply code-review reception discipline to every finding:
   - verify against code
   - accept and fix if correct
   - reject with technical reason if wrong
   - ask the user if architectural or unverifiable
6. Cross-check disagreement. In council-loop mode, send rejected and disputed findings back into the same Copilot session with `--follow-up`.
   - Codex-only finding: compare against Copilot output and code evidence.
   - Copilot-only finding: compare against Codex reviewer output and code evidence.
   - Conflicting findings: resolve by code/tests, not reviewer authority.
7. Produce a council decision:
   - accepted findings
   - rejected findings with reasons
   - user-decision items
   - clickable transcript link for the full council discussion
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

# persistent Copilot session for accepted/rejected/disputed review loop
scripts/review_with_copilot.sh --council-loop
scripts/review_with_copilot.sh --session-id <session-id> --follow-up review-council-followup.md
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

Council record:
- [copilot-review-council-<session-id>.md](/absolute/path/to/copilot-review-council-<session-id>.md)
```

If both reviewers have no actionable findings, say so and continue to normal completion.
Always include the `Council record` link when `--council-loop` was used. Use the absolute transcript path printed by the script, and format it as a Markdown file link so the user can click it.

## Commit Boundary

This skill never commits by itself. Before any commit or push, follow the user's git identity confirmation rule.
