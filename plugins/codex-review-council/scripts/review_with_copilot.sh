#!/usr/bin/env bash
set -euo pipefail

MODEL="${COPILOT_REVIEW_MODEL:-claude-sonnet-4.6}"
MODE="head"
BASE_REF=""

usage() {
  cat <<'USAGE'
Usage: review_with_copilot.sh [--staged] [--base <ref>] [--model <model>]

Runs a read-only GitHub Copilot CLI review of local git changes.
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

command -v git >/dev/null || { echo "git is required" >&2; exit 127; }
command -v copilot >/dev/null || { echo "copilot CLI is required" >&2; exit 127; }
git rev-parse --is-inside-work-tree >/dev/null

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

copilot \
  --model "$MODEL" \
  --silent \
  --no-ask-user \
  --allow-tool='shell(git diff:*)' \
  --allow-tool='shell(git rev-parse:*)' \
  --deny-tool='write' \
  --deny-tool='edit' \
  -p "$PROMPT"
