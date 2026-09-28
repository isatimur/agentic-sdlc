#!/usr/bin/env bash
# install.sh [target-repo=.] — copy the kit into a repository.
#
# Copies:  .sdlc/SDLC.md, .sdlc/scripts/*, .sdlc/agents/reviewer.md, .sdlc/tiers.txt (starter)
#          .github/workflows/review-gate.yml, .github/workflows/incident-check.yml
#          .github/pull_request_template.md, CODEOWNERS (example, only if absent)
#          .claude/settings.json (only if absent), .claude/agents/reviewer.md
#          incidents/README.md (only if absent), docs/adr/TEMPLATE.md
# Never overwrites CLAUDE.md, CODEOWNERS or .claude/settings.json if they exist; prints a diff hint instead.
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "${1:-.}" && pwd)"
# A worktree has a .git *file*, not a directory; ask git instead of testing the path.
git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository: $TARGET" >&2; exit 1; }
cd "$TARGET"

copy() { # src dst [keep]
  local src="$1" dst="$2" keep="${3:-}"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && -n "$keep" ]]; then
    echo "keep     $dst (exists; compare with $src)"
  else
    cp "$src" "$dst"; echo "install  $dst"
  fi
}

copy "$KIT/SDLC.md"                                    .sdlc/SDLC.md
for s in classify-change parse-verdict tree-unchanged check-incident-frontmatter post-edit-check session-context; do
  copy "$KIT/scripts/$s.sh" ".sdlc/scripts/$s.sh"; chmod +x ".sdlc/scripts/$s.sh"
done
copy "$KIT/agents/reviewer.md"                         .sdlc/agents/reviewer.md
copy "$KIT/agents/reviewer.md"                         .claude/agents/reviewer.md
copy "$KIT/templates/.github/workflows/review-gate.yml"    .github/workflows/review-gate.yml
copy "$KIT/templates/.github/workflows/incident-check.yml" .github/workflows/incident-check.yml
copy "$KIT/templates/pull_request_template.md"         .github/pull_request_template.md
copy "$KIT/templates/CODEOWNERS.example"               CODEOWNERS keep
copy "$KIT/templates/claude/settings.json"             .claude/settings.json keep
copy "$KIT/templates/incidents-README.md"              incidents/README.md keep
copy "$KIT/templates/adr.md"                           docs/adr/TEMPLATE.md keep
if [[ ! -f .sdlc/tiers.txt ]]; then
  cat > .sdlc/tiers.txt <<'EOF'
# TIER glob — first match wins per path; the highest tier across the diff wins.
# Anything unmatched is T1 (application code). Declare your prose and your blast radius.
T2 .github/*
T2 .sdlc/*
T2 CODEOWNERS
T2 .claude/*
T2 infra/*
T2 */migrations/*
T0 docs/*
T0 incidents/*
T0 *.md
EOF
  echo "install  .sdlc/tiers.txt (starter — edit it)"
fi
if [[ ! -f .sdlc/checks.txt ]]; then
  printf '# one shell command per line; run after every edit by the PostToolUse hook\n# npm test --silent\n' > .sdlc/checks.txt
  echo "install  .sdlc/checks.txt (empty — add your fast checks)"
fi
if [[ ! -f CLAUDE.md ]]; then
  copy "$KIT/templates/CLAUDE.md" CLAUDE.md
else
  echo "keep     CLAUDE.md — add this line under your lifecycle section:  @.sdlc/SDLC.md"
fi

BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#origin/##' || echo dev)
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || echo "<owner/repo>")
cat <<EOF

Done. Three steps only a human with admin rights can do, once:

1. Branch protection on '$BRANCH' in $REPO:
   Settings → Branches → Add rule → '$BRANCH'
   [x] Require a pull request before merging   [x] Require review from Code Owners
   [x] Require status checks to pass: tests, review-gate   [x] Require branches to be up to date
   Or, with the CLI:
   gh api -X PUT repos/$REPO/branches/$BRANCH/protection \\
     -F required_status_checks[strict]=true -F required_status_checks[contexts][]=tests -F required_status_checks[contexts][]=review-gate \\
     -F enforce_admins=false -F required_pull_request_reviews[require_code_owner_reviews]=true \\
     -F required_pull_request_reviews[required_approving_review_count]=1 -F restrictions=

2. Secret: Settings → Secrets → Actions → ANTHROPIC_API_KEY   (gh secret set ANTHROPIC_API_KEY)

3. Edit CODEOWNERS and .sdlc/tiers.txt with your T2 paths and approvers.

'tests' above is a placeholder: use the check name your existing test job reports
(the job id or its name:, e.g. 'test'). review-gate is always named 'review-gate'.
EOF
