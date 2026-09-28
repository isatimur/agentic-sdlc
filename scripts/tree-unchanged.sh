#!/usr/bin/env bash
# tree-unchanged.sh <graded-sha> [<candidate-sha>=HEAD]
# Exit 0 if the two commits have identical trees. Use after squashing: a PASS applies to
# a tree, so the squash must not change it.
set -euo pipefail
GRADED="${1:?usage: tree-unchanged.sh <graded-sha> [<candidate-sha>]}"
CAND="${2:-HEAD}"
if git diff --quiet "$GRADED" "$CAND"; then
  echo "tree unchanged: $(git rev-parse --short "$GRADED") == $(git rev-parse --short "$CAND")"
else
  echo "TREE CHANGED between $GRADED and $CAND — the PASS does not apply to $CAND" >&2
  git diff --stat "$GRADED" "$CAND" >&2
  exit 1
fi
