# The Agentic SDLC

For one to five engineers plus coding agents, shipping through GitHub. Two pages. If a rule is not on these pages, it is not a rule of this lifecycle.

## The one idea

The gate lives on the remote. A pull request merges only when GitHub sees a required `review-gate` status on the head SHA, posted from a structured verdict by a reviewer that did not write the code. Nothing that runs on one machine, parses command strings, or depends on which tool pushed can be the control. It can be a convenience.

## Tiers

The highest-risk path a change touches sets its tier. CI computes it from paths. A human may raise a tier in the pull request, never lower it.

| Tier | What | What it takes to merge |
|---|---|---|
| **T0** records and prose | docs, incidents, ADR text, changelogs | green tests |
| **T1** application code to the integration branch | features, fixes, tests, refactors | one non-producer review; an agent reviewer is allowed |
| **T2** blast radius | control plane, CI and hooks, infrastructure, IAM, schema migrations, pricing or scoring formulas, promotion to production, customer-facing output, anything irreversible | a spec before code, a second model family or a human reviewer, Code Owner approval, a rollback demonstrated once |

## Seven stages, one artifact each

| # | Stage | The one artifact | Who approves | Mechanically enforced | Convention |
|---|---|---|---|---|---|
| 1 | Intent | T0: none. T1: a ticket with a definition of done. T2: a one-page spec with threat model and rollback | T2: the named human owner | CI: a T2 pull request must carry a `Spec:` link | the quality of the T1 definition of done |
| 2 | Plan | the plan in the pull request body: what it touches, what it could break | author; for T2 also the reviewer | none | plan before the first edit |
| 3 | Build | branch and commits | none | deny force-push and direct push to protected branches; format and tests run after each edit | small pull requests; one commit at hand-over |
| 4 | Verify | a review comment with a per-clause verdict, and a `review-gate` commit status on the head SHA | a non-producer. T1: agent reviewer. T2: agent plus a second model family or a human, plus a human approval | CI posts the status only from a verdict line that parses: `- **Verdict**: PASS`, `REVISE` or `BLOCK` | the verdict format |
| 5 | Merge | the merge commit, tree identical to the graded tree | none | branch protection: required `review-gate` plus your test job's status check (`tests`, or whatever your CI names it) on the head SHA; Code Owner approval for T2 | squash after the gate; prove the tree is unchanged |
| 6 | Release | a deploy record: tag plus changelog entry | T2 and production: a named human go or no-go | protected environment approval | a rollback drill before the first production deploy of a new service |
| 7 | Monitor | alert configuration, and an incident file with `status:` and `regression:` front matter | the on-call owner | CI: an incident with `status: closed` must reference an existing test path or a named control | the postmortem prose |

An incident re-enters the lifecycle as new intent.

## Seven governed numbers

| # | Number | Value |
|---|---|---|
| 1 | Review-round ceiling | T1: 2. T2: 3 |
| 2 | At the ceiling | exactly one of: ship the bounded version, kill the change, a human-signed capped waiver. Never a further round, never a new spec to restart the count |
| 3 | PASS floor | one number per tier, published in the reviewer prompt, not per lens |
| 4 | Second model family | required for T2 only |
| 5 | Pull request age limit | 48 hours, then intake pauses until the queue drains |
| 6 | Spend cap | per session, enforced by the provider or a budget setting, never by prose |
| 7 | Tier map | paths to T0, T1, T2, in `CODEOWNERS` and `.sdlc/tiers.txt` |

Changing a number is a dated line in `CHANGELOG.md`. Under pressure the answer is pausing intake, never editing a number inline.

## Five rules

1. No merge without the required status on the head SHA.
2. A bypass is an incident, even when the output was fine.
3. No re-roll on an unchanged SHA. Fix the artifact; do not re-sample the reviewer.
4. An incident closes only with a test or control reference that CI checks.
5. T2 changes need a spec before code.

## What is measured

| Metric | Computed from |
|---|---|
| Bypass count | merges on protected branches without a `review-gate` success, from the GitHub API |
| Rework rate | REVISE plus BLOCK share per pull request, from status history |
| Time to merge by tier | opened to merged |
| Incidents closed with a checked regression | front matter, CI-verified |
| Shipped then reverted | reverts joined to the pull request that shipped them |

Never pull requests opened, agents run, or lines written.

## Claude Code mapping, honestly stated

| Need | Primitive | What it does and does not do |
|---|---|---|
| Team conventions | `CLAUDE.md` with `@path` imports | one source, no mirror to diff |
| Plan before build | plan mode, `defaultMode: plan` in project settings | a convention with a default; subagents bypass it; the artifact is the pull request body, not the mode |
| Autonomy levels | `permissions` allow, ask, deny in `settings.json` | the real ladder, enforced by the tool |
| Parallel builders | the Agent tool with `isolation: worktree` | collision isolation, not decomposition |
| Self-check after edits | a PostToolUse hook running format and tests | feedback, not a gate |
| Non-producer review | a reviewer subagent with read-only tools, or the `review-gate` GitHub Action | the verdict counts only when it lands as a commit status |
| The gate | branch protection and required checks | the only control that sees every merge, from every tool and every human |
| Context at session start | a SessionStart hook | injects open pull requests and incidents; cannot block |
