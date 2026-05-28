#!/usr/bin/env bash
set -euo pipefail

MODEL="${COPILOT_REVIEW_MODEL:-claude-sonnet-4.6}"
MODE="head"
BASE_REF=""
COUNCIL_LOOP=0
SESSION_ID=""
FOLLOW_UP_FILE=""
SHARE_PATH=""
SUMMARY_PATH=""

usage() {
  cat <<'USAGE'
Usage: review_with_copilot.sh [--staged] [--base <ref>] [--model <model>]
                              [--council-loop] [--session-id <uuid>]
                              [--follow-up <file>] [--share <file>]
                              [--summary <file>]

Runs a read-only GitHub Copilot CLI review of local git changes.

Default mode is a stateless single-pass review.
Use --council-loop to start or resume a persistent Copilot review session.
Use --follow-up with --session-id to send Codex's accepted/rejected findings
back into the same Copilot session for disputed-item review.
Use --summary to choose where Codex should write the meeting-minutes summary.
Implies --council-loop.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged)
      MODE="staged"
      shift
      ;;
    --base)
      MODE="base"
      BASE_REF="${2:-}"
      [[ -n "$BASE_REF" ]] || { echo "missing value for --base" >&2; exit 2; }
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      [[ -n "$MODEL" ]] || { echo "missing value for --model" >&2; exit 2; }
      shift 2
      ;;
    --council-loop)
      COUNCIL_LOOP=1
      shift
      ;;
    --session-id)
      SESSION_ID="${2:-}"
      [[ -n "$SESSION_ID" ]] || { echo "missing value for --session-id" >&2; exit 2; }
      shift 2
      ;;
    --follow-up)
      FOLLOW_UP_FILE="${2:-}"
      [[ -n "$FOLLOW_UP_FILE" ]] || { echo "missing value for --follow-up" >&2; exit 2; }
      [[ -f "$FOLLOW_UP_FILE" ]] || { echo "follow-up file not found: $FOLLOW_UP_FILE" >&2; exit 2; }
      COUNCIL_LOOP=1
      shift 2
      ;;
    --share)
      SHARE_PATH="${2:-}"
      [[ -n "$SHARE_PATH" ]] || { echo "missing value for --share" >&2; exit 2; }
      COUNCIL_LOOP=1
      shift 2
      ;;
    --summary)
      SUMMARY_PATH="${2:-}"
      [[ -n "$SUMMARY_PATH" ]] || { echo "missing value for --summary" >&2; exit 2; }
      COUNCIL_LOOP=1
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$FOLLOW_UP_FILE" && -z "$SESSION_ID" ]]; then
  echo "--follow-up requires --session-id from the first council-loop pass" >&2
  exit 2
fi

command -v git >/dev/null || { echo "git is required" >&2; exit 127; }
command -v copilot >/dev/null || { echo "copilot CLI is required" >&2; exit 127; }
git rev-parse --is-inside-work-tree >/dev/null

COPILOT_HELP=""
copilot_supports() {
  if [[ -z "$COPILOT_HELP" ]]; then
    COPILOT_HELP="$(copilot --help)"
  fi
  grep -q -- "$1" <<<"$COPILOT_HELP"
}

case "$MODE" in
  staged)
    if git diff --cached --quiet -- .; then
      echo "No staged changes to review."
      exit 0
    fi
    DIFF_CMD="git diff --cached --find-renames --find-copies -- ."
    ;;
  base)
    git rev-parse --verify "$BASE_REF" >/dev/null
    if git diff --quiet "$BASE_REF"...HEAD -- .; then
      echo "No changes versus $BASE_REF to review."
      exit 0
    fi
    DIFF_CMD="git diff --find-renames --find-copies $BASE_REF...HEAD -- ."
    ;;
  head)
    if git diff --quiet HEAD -- .; then
      echo "No tracked changes versus HEAD to review."
      exit 0
    fi
    DIFF_CMD="git diff --find-renames --find-copies HEAD -- ."
    ;;
esac

PROMPT=$(cat <<EOF
Review the local code changes from this repository.

Use this exact command as the review input:

  $DIFF_CMD

Do not edit files. Do not run formatters. Do not commit.

Return only actionable findings. Prioritize bugs, regressions, edge cases,
security risks, data-loss risks, and missing tests. Ignore style-only issues.

For each finding, use:
- severity: critical|high|medium|low
- file:line
- issue
- why it matters
- suggested fix

If there are no actionable findings, say: No actionable findings.
EOF
)

if [[ "$COUNCIL_LOOP" -eq 1 ]]; then
  for required_flag in --session-id --name --share; do
    copilot_supports "$required_flag" || {
      echo "copilot CLI does not support $required_flag; upgrade Copilot CLI before using --council-loop" >&2
      exit 2
    }
  done

  if [[ -z "$SESSION_ID" ]]; then
    command -v uuidgen >/dev/null || { echo "uuidgen is required for --council-loop without --session-id" >&2; exit 127; }
    SESSION_ID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  fi

  if [[ -z "$SHARE_PATH" ]]; then
    THREAD_ID="$(printf '%s' "${CODEX_THREAD_ID:-local}" | tr -cd '[:alnum:]_-')"
    [[ -n "$THREAD_ID" ]] || THREAD_ID="local"
    SHARE_DIR="${TMPDIR:-/tmp}/codex-review-council/${THREAD_ID}"
    SHARE_PATH="$SHARE_DIR/copilot-review-council-${SESSION_ID}.md"
  fi
  mkdir -p "$(dirname "$SHARE_PATH")"

  if [[ -z "$SUMMARY_PATH" ]]; then
    SUMMARY_PATH="$(dirname "$SHARE_PATH")/copilot-review-council-summary-${SESSION_ID}.md"
  fi
  mkdir -p "$(dirname "$SUMMARY_PATH")"

  if [[ -n "$FOLLOW_UP_FILE" ]]; then
    FOLLOW_UP=$(cat "$FOLLOW_UP_FILE")
    PROMPT=$(printf '%s\n\n%s\n\n%s\n' \
      "Continue the same Codex + Copilot review council for this repository." \
      "Codex has reviewed your previous findings and recorded decisions below:

$FOLLOW_UP" \
      "Re-evaluate only rejected, disputed, or needs-discussion items.
For each item, either withdraw it, keep it with concrete code evidence, or
revise it into a narrower actionable finding. Do not repeat accepted findings.
Do not edit files. Do not run formatters. Do not commit.")
  else
    PROMPT=$(printf '%s\n\n%s\n\n%s\n' \
      "Start a Codex + Copilot review council for this repository." \
      "$PROMPT" \
      "This is the first pass. Codex will independently verify your findings, accept
or reject each one with reasons, and may send disputed items back into this
same session for re-evaluation. Use concrete file/line evidence only.")
  fi

  echo "Copilot review council session: $SESSION_ID" >&2
  echo "Copilot transcript: $SHARE_PATH" >&2
  echo "Copilot summary: $SUMMARY_PATH" >&2
  echo "Open the transcript after the loop to inspect the full council discussion." >&2

  copilot \
    --model "$MODEL" \
    --session-id "$SESSION_ID" \
    --name "codex-review-council" \
    --share "$SHARE_PATH" \
    --silent \
    --no-ask-user \
    --allow-tool='shell(git diff:*)' \
    --allow-tool='shell(git status:*)' \
    --allow-tool='shell(git rev-parse:*)' \
    --allow-tool='shell(git ls-files:*)' \
    --allow-tool='shell(test:*)' \
    --allow-tool='shell(find:*)' \
    --deny-tool='write' \
    --deny-tool='edit' \
    -p "$PROMPT"
else
  copilot \
    --model "$MODEL" \
    --silent \
    --no-ask-user \
    --allow-tool='shell(git diff:*)' \
    --allow-tool='shell(git rev-parse:*)' \
    --deny-tool='write' \
    --deny-tool='edit' \
    -p "$PROMPT"
fi
