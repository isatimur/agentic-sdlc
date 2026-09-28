#!/usr/bin/env bash
# session-context.sh — SessionStart hook: inject open pull requests and open incidents.
# Context only. It cannot block and does not try to.
set -uo pipefail
cat >/dev/null || true
command -v gh >/dev/null 2>&1 || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
MSG=""
PRS=$(gh pr list --state open --json number,title,headRefName --jq '.[] | "#\(.number) \(.title) [\(.headRefName)]"' 2>/dev/null | head -10)
[[ -n "$PRS" ]] && MSG+="Open pull requests: "$'\n'"$PRS"$'\n'
if [[ -d incidents ]]; then
  OPEN=$(grep -l '^status: open' incidents/*.md 2>/dev/null | head -10)
  [[ -n "$OPEN" ]] && MSG+="Open incidents: "$'\n'"$OPEN"$'\n'
fi
[[ -z "$MSG" ]] && exit 0
printf '{"systemMessage": %s}\n' "$(printf '%s' "$MSG" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
exit 0
