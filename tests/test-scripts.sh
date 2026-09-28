#!/usr/bin/env bash
# Tests for the kit's scripts. Run: bash tests/test-scripts.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/scripts"
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "ok   $1"; }
fail() { FAIL=$((FAIL+1)); echo "FAIL $1" >&2; }
expect() { # name expected actual
  if [[ "$2" == "$3" ]]; then ok "$1"; else fail "$1 (expected '$2', got '$3')"; fi
}

# classify-change: defaults
expect "T0 for docs"            T0 "$(printf 'docs/a.md\nREADME.md\n' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
expect "T1 for app code"        T1 "$(printf 'src/x.js\n' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
expect "T2 for workflows"       T2 "$(printf 'src/x.js\n.github/workflows/ci.yml\n' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
expect "T2 for migrations"      T2 "$(printf 'src/db/migrations/001.sql\n' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
expect "T2 wins over T0"        T2 "$(printf 'docs/a.md\ninfra/main.tf\n' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
expect "empty diff is T1"       T1 "$(printf '' | SDLC_TIERS_FILE=/nonexistent bash "$S/classify-change.sh")"
# classify-change: tiers file overrides
TMP=$(mktemp); printf 'T0 src/generated/*\nT2 src/billing/*\n' > "$TMP"
expect "tiers file T0 override" T0 "$(printf 'src/generated/client.ts\n' | SDLC_TIERS_FILE=$TMP bash "$S/classify-change.sh")"
expect "tiers file T2 override" T2 "$(printf 'src/billing/charge.ts\n' | SDLC_TIERS_FILE=$TMP bash "$S/classify-change.sh")"
rm -f "$TMP"

# parse-verdict
expect "PASS parsed"            PASS   "$(printf 'notes\n- **Verdict**: PASS\n' | bash "$S/parse-verdict.sh")"
expect "last line wins"         BLOCK  "$(printf -- '- **Verdict**: PASS\nmore\n- **Verdict**: BLOCK\n' | bash "$S/parse-verdict.sh")"
expect "trailing space ok"      REVISE "$(printf -- '- **Verdict**: REVISE   \n' | bash "$S/parse-verdict.sh")"
if printf 'Verdict: PASS\n' | bash "$S/parse-verdict.sh" >/dev/null 2>&1; then fail "bare 'Verdict: PASS' must not parse"; else ok "bare form rejected"; fi
if printf -- '- **Verdict**: pass\n' | bash "$S/parse-verdict.sh" >/dev/null 2>&1; then fail "lowercase token must not parse"; else ok "lowercase rejected"; fi
if printf -- '- **Verdict**: PASS-ELIGIBLE\n' | bash "$S/parse-verdict.sh" >/dev/null 2>&1; then fail "suffixed token must not parse"; else ok "suffixed token rejected"; fi
if printf 'no verdict here\n' | bash "$S/parse-verdict.sh" >/dev/null 2>&1; then fail "missing verdict must exit 1"; else ok "missing verdict fails closed"; fi

# check-incident-frontmatter
D=$(mktemp -d); mkdir -p "$D/incidents" "$D/tests" "$D/docs"; touch "$D/tests/test_x.sh"; printf '# Controls\n- deploy-sop-iam-check\n' > "$D/docs/CONTROLS.md"
printf -- '---\ntitle: a\ndate: 2026-01-01\nseverity: low\nstatus: open\nregression: TODO\n---\nbody\n' > "$D/incidents/2026-01-01-open.md"
printf -- '---\ntitle: b\ndate: 2026-01-02\nseverity: low\nstatus: closed\nregression: tests/test_x.sh::test_it\n---\nbody\n' > "$D/incidents/2026-01-02-closed-ok.md"
printf -- '---\ntitle: c\ndate: 2026-01-03\nseverity: low\nstatus: closed\nregression: control:deploy-sop-iam-check\n---\nbody\n' > "$D/incidents/2026-01-03-control-ok.md"
( cd "$D" && bash "$S/check-incident-frontmatter.sh" incidents >/dev/null ) && ok "valid incidents pass" || fail "valid incidents should pass"
printf -- '---\ntitle: d\ndate: 2026-01-04\nseverity: low\nstatus: closed\nregression: tests/missing.sh\n---\nbody\n' > "$D/incidents/2026-01-04-bad.md"
( cd "$D" && bash "$S/check-incident-frontmatter.sh" incidents >/dev/null 2>&1 ) && fail "missing regression path should fail" || ok "missing regression path fails"
rm -f "$D/incidents/2026-01-04-bad.md"
printf -- '---\ntitle: e\ndate: 2026-01-05\nseverity: low\nstatus: closed\nregression: TODO\n---\nbody\n' > "$D/incidents/2026-01-05-todo.md"
( cd "$D" && bash "$S/check-incident-frontmatter.sh" incidents >/dev/null 2>&1 ) && fail "closed with TODO should fail" || ok "closed with TODO fails"
rm -f "$D/incidents/2026-01-05-todo.md"
printf 'no front matter\n' > "$D/incidents/2026-01-06-none.md"
( cd "$D" && bash "$S/check-incident-frontmatter.sh" incidents >/dev/null 2>&1 ) && fail "no front matter should fail" || ok "no front matter fails"
rm -rf "$D"

# tree-unchanged
G=$(mktemp -d); ( cd "$G" && git init -q && git config user.email t@t && git config user.name t && echo a > f && git add f && git commit -qm one && A=$(git rev-parse HEAD) && git commit -q --allow-empty -m two && bash "$S/tree-unchanged.sh" "$A" >/dev/null ) && ok "identical trees pass" || fail "identical trees should pass"
( cd "$G" && A=$(git rev-parse HEAD~1) && echo b >> f && git commit -qam three && bash "$S/tree-unchanged.sh" "$A" >/dev/null 2>&1 ) && fail "changed tree should fail" || ok "changed tree fails"
rm -rf "$G"

echo "----"; echo "passed $PASS, failed $FAIL"
[[ $FAIL -eq 0 ]]
