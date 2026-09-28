#!/usr/bin/env bash
# classify-change.sh — read changed paths on stdin, print the tier: T0, T1 or T2.
#
# The highest tier among the paths wins. Patterns come from .sdlc/tiers.txt if it exists
# (one "TIER glob" per line, first match wins per path), else from the defaults below.
# Unknown paths are T1: application code is the default, prose must be declared.
set -euo pipefail

TIERS_FILE="${SDLC_TIERS_FILE:-.sdlc/tiers.txt}"

default_tier() {
  local p="$1"
  case "$p" in
    .github/*|.sdlc/*|CODEOWNERS|.claude/*|*/hooks/*|hooks/*) echo T2 ;;
    infra/*|terraform/*|*.tf|*/migrations/*|prisma/*|*/schema.prisma) echo T2 ;;
    */billing/*|*/payments/*|*/pricing/*) echo T2 ;;
    docs/*|incidents/*|*.md|CHANGELOG*|LICENSE*) echo T0 ;;
    *) echo T1 ;;
  esac
}

file_tier() {
  local p="$1"
  if [[ -f "$TIERS_FILE" ]]; then
    while read -r tier glob; do
      [[ -z "${tier:-}" || "$tier" == \#* ]] && continue
      # shellcheck disable=SC2053
      if [[ "$p" == $glob ]]; then echo "$tier"; return; fi
    done < "$TIERS_FILE"
  fi
  default_tier "$p"
}

rank() { case "$1" in T0) echo 0 ;; T1) echo 1 ;; T2) echo 2 ;; *) echo 1 ;; esac; }

MAX=-1; RESULT=T0; ANY=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  ANY=1
  t=$(file_tier "$path"); r=$(rank "$t")
  if (( r > MAX )); then MAX=$r; RESULT=$t; fi
done

# No paths at all is not prose; treat as T1 so an empty diff never ships on green alone.
[[ $ANY -eq 0 ]] && RESULT=T1
echo "$RESULT"
