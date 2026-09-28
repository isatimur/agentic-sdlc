#!/usr/bin/env bash
# check-incident-frontmatter.sh [incidents-dir=incidents]
# Every incident file needs front matter with status: and regression:.
# status: closed requires regression: to name a path that exists (optionally ::test_name),
# or control:<name> where <name> appears in docs/CONTROLS.md. Exit 1 on any violation.
set -euo pipefail
DIR="${1:-incidents}"
CONTROLS="${SDLC_CONTROLS_FILE:-docs/CONTROLS.md}"
FAIL=0
shopt -s nullglob
for f in "$DIR"/*.md; do
  [[ "$(basename "$f")" == "README.md" ]] && continue
  fm=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")
  if [[ -z "$fm" ]]; then echo "FAIL $f: no front matter" >&2; FAIL=1; continue; fi
  status=$(printf '%s\n' "$fm" | sed -nE 's/^status:[[:space:]]*([a-z]+).*/\1/p' | head -1)
  reg=$(printf '%s\n' "$fm" | sed -nE 's/^regression:[[:space:]]*(.*)$/\1/p' | head -1 | sed -E 's/[[:space:]]+$//')
  case "$status" in
    open) ;;
    closed)
      if [[ -z "$reg" || "$reg" == "TODO" ]]; then
        echo "FAIL $f: status: closed with no regression:" >&2; FAIL=1; continue
      fi
      if [[ "$reg" == control:* ]]; then
        name="${reg#control:}"
        if [[ ! -f "$CONTROLS" ]] || ! grep -qF -- "$name" "$CONTROLS"; then
          echo "FAIL $f: control '$name' not found in $CONTROLS" >&2; FAIL=1
        fi
      else
        path="${reg%%::*}"
        if [[ ! -e "$path" ]]; then
          echo "FAIL $f: regression path does not exist: $path" >&2; FAIL=1
        fi
      fi ;;
    *) echo "FAIL $f: status must be open or closed (got '${status:-none}')" >&2; FAIL=1 ;;
  esac
done
[[ $FAIL -eq 0 ]] && echo "incidents OK ($DIR)"
exit $FAIL
