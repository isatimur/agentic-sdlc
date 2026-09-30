# Changelog

Governed numbers and rules live in `SDLC.md`. A change to a number is a minor version; a change to a rule is a major version. Every entry names what changed and why.

## 0.1.1 — 2026-09-30

- `review-gate` picks the reviewer model by tier: `claude-opus-5-5` for T2 verdicts, `claude-sonnet-5-5` for T1. Grading a well-specified definition of done does not need the frontier model; a T2 verdict does. The `reviewer` subagent's default model is now `claude-sonnet-5-5` for local use.
- First CI run of the `tests` workflow on GitHub passed (2026-09-29).

## 0.1.0 — 2026-09-28

First cut, extracted from an agency-wide design after an audit found its ship gate guarding the wrong boundary (a laptop hook instead of the remote).

- `SDLC.md`: three tiers, seven stages, seven numbers, five rules.
- `review-gate` workflow: tier classification, `Spec:` check for T2, non-producer review through `anthropics/claude-code-action`, verdict parsed into a commit status. Fails closed on an unparseable verdict.
- `incident-check` workflow and `check-incident-frontmatter.sh`: a closed incident must name an existing test path or a named control.
- `classify-change.sh`, `parse-verdict.sh`, `tree-unchanged.sh`, `post-edit-check.sh`, `session-context.sh`.
- `reviewer.md` agent, read-only.
- Templates: `CLAUDE.md`, `CODEOWNERS.example`, pull request template, ADR, incidents README, project `settings.json`.
- `install.sh`.

Verified against the action's documentation on 2026-09-29: input names `prompt`, `claude_args`, `anthropic_api_key`, `github_token` are current; a `prompt` input runs the action without an `@claude` mention; `id-token: write` is not needed with an API key. The workflow keeps `contents: read` although the setup guide recommends `write`, because the reviewer must not be able to change the tree it grades; if the first real run fails on that, the fix is one line and belongs in 0.1.1. The reviewer's tools are restricted with `--allowedTools` to read and read-only git.

Known limits of 0.1.0, stated rather than hidden:

- The `review-gate` workflow has not yet run in a real repository's CI. The first consumer proves it.
- For T2 the workflow posts the Claude verdict only. The second model family and the human approval come from Code Owner review, not from this workflow.
- Bypass counting from the GitHub API is described in `SDLC.md` and not yet scripted.
- The tier classifier matches paths only. It does not read diff content.
