#!/usr/bin/env bash
# parse-verdict.sh — read a review comment on stdin, print PASS, REVISE or BLOCK.
#
# Accepts only the canonical line "- **Verdict**: TOKEN" (case-sensitive token, optional
# trailing whitespace). The LAST such line wins, so a reviewer that reasons out loud and
# then concludes is parsed by its conclusion. Anything else exits 1: the gate fails closed.
set -euo pipefail
LINE=$(grep -E '^[[:space:]]*-[[:space:]]*\*\*Verdict\*\*:[[:space:]]*(PASS|REVISE|BLOCK)[[:space:]]*$' | tail -n 1 || true)
[[ -z "$LINE" ]] && exit 1
printf '%s\n' "$LINE" | sed -E 's/.*\*\*Verdict\*\*:[[:space:]]*(PASS|REVISE|BLOCK).*/\1/'
