# <PROJECT NAME>

<One paragraph: what this service is, who uses it, what "production" means here.>

## Lifecycle

This repository follows the agentic SDLC. The two pages below are the rules; nothing outside them is a rule.

@.sdlc/SDLC.md

Project-specific overlay:

- Integration branch: `<dev>`. Production branch: `<prod>`. A merge to either is a deploy.
- T2 paths and their approvers are in `CODEOWNERS`. The tier map is `.sdlc/tiers.txt`.
- Who decides what: <name> owns architecture and release go/no-go; <name> owns <domain sign-off>.
- Spec format for T2: `docs/adr/` using `templates/adr.md`.

## Commands

```bash
<install>
<run dev>
<run tests>          # the `tests` status check runs exactly this
<lint / typecheck>
```

## Conventions

- <language and framework versions>
- <error handling rule>
- <naming: request bodies, query params, DB columns>
- <response shape>
- Commits: Conventional Commits. One commit per pull request at hand-over; squash only after the gate has graded the tree, and prove the tree is unchanged with `scripts/tree-unchanged.sh`.
- No AI attribution lines in commits or pull request bodies.

## Layout

```
src/        <what lives where, five lines at most>
tests/
docs/adr/   T2 specs
incidents/  one file per incident, front matter enforced by CI
```

## Do not

- Do not push to `<dev>` or `<prod>` directly. The settings deny it; the remote refuses it.
- Do not edit a governed number inline. Change `.sdlc/SDLC.md` through a pull request with a changelog line.
- Do not close an incident without a `regression:` path that exists.
