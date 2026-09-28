#!/usr/bin/env bash
# post-edit-check.sh — PostToolUse hook: run the project's fast checks after an edit.
# Feedback, not a gate. Reads .sdlc/checks.txt (one command per line) if present; else no-op.
# Never blocks the session: a failing check is printed for the agent to act on.
set -uo pipefail
cat >/dev/null || true
CHECKS="${SDLC_CHECKS_FILE:-.sdlc/checks.txt}"
[[ -f "$CHECKS" ]] || exit 0
while IFS= read -r cmd; do
  [[ -z "$cmd" || "$cmd" == \#* ]] && continue
  if ! out=$(bash -c "$cmd" 2>&1); then
    printf '{"systemMessage": %s}\n' "$(printf 'post-edit check failed: %s\n%s' "$cmd" "$(printf '%s' "$out" | tail -n 20)" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
    exit 0
  fi
done < "$CHECKS"
exit 0
