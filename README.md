# agentic-sdlc

A two-page software development lifecycle for small teams that build with coding agents, plus the files that make it mechanical. The gate lives on the remote: a pull request merges only when GitHub sees a required `review-gate` status on the head SHA, posted from a structured verdict by a reviewer that did not write the code.

Read [`SDLC.md`](SDLC.md) first. It is the whole method: three tiers, seven stages with one artifact each, seven governed numbers, five rules.

## What is in the kit

| Path | What it is |
|---|---|
| `SDLC.md` | the lifecycle, two pages |
| `templates/CLAUDE.md` | a project instruction file under 100 lines that imports `SDLC.md` |
| `templates/CODEOWNERS.example` | T2 paths mapped to required human approvers |
| `templates/pull_request_template.md` | tier, plan, `Spec:` link for T2 |
| `templates/adr.md` | one-page T2 spec: threat model and rollback |
| `templates/incidents-README.md` | incident format with `status:` and `regression:` front matter |
| `templates/.github/workflows/review-gate.yml` | runs the non-producer reviewer on the head SHA, posts the `review-gate` commit status |
| `templates/.github/workflows/incident-check.yml` | a closed incident must reference an existing test path or a named control |
| `templates/claude/settings.json` | project permissions: deny force-push and direct push, plan mode by default, tests after edits |
| `agents/reviewer.md` | the read-only reviewer subagent |
| `scripts/classify-change.sh` | paths changed → T0, T1 or T2 |
| `scripts/parse-verdict.sh` | extracts `- **Verdict**: PASS|REVISE|BLOCK` from a review comment |
| `scripts/tree-unchanged.sh` | proves a squash left the graded tree unchanged |
| `scripts/check-incident-frontmatter.sh` | the incident closure rule, runnable locally and in CI |
| `install.sh` | copies the templates into a target repository and prints the branch-protection settings a human must set |

## Install into a repository

```bash
git clone https://github.com/isatimur/agentic-sdlc ~/Dev/agentic-sdlc
cd /path/to/your/repo
~/Dev/agentic-sdlc/install.sh
```

Then, once, on GitHub (a human with admin rights):

1. Settings → Branches → protect your integration branch. Require status checks `tests` and `review-gate`. Require a pull request. Require review from Code Owners.
2. Settings → Secrets → add `ANTHROPIC_API_KEY` for the `review-gate` workflow.
3. Fill `CODEOWNERS` with your T2 paths and approvers.

`install.sh` prints these three steps with your branch name filled in.

## What the kit deliberately does not contain

No markdown verdict ledger, no dispatch log, no claims ledger, no sentinel, no dead-man switch, no autonomy-grant prose, no fifteen-rule charter. Pull request statuses and comments are the ledger. Alerts are your observability tool's job.

## Versioning

Consumers pin a tag. Changes are listed in [`CHANGELOG.md`](CHANGELOG.md). A change to a governed number in `SDLC.md` is a minor version; a change to a rule is a major version.

## Where it came from

Extracted on 2026-09-28 from a heavier agency-wide design after an audit found the gate guarding the wrong boundary. The audit and the reasoning are in that project's records; the kit keeps only what caught real bugs.

MIT license.
