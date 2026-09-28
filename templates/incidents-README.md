# incidents/

One file per incident, named `YYYY-MM-DD-short-slug.md`. A gate bypass is an incident even when the output was fine. An incident closes only when its regression is something CI can see.

## Front matter, required

```yaml
---
title: <one line>
date: YYYY-MM-DD
severity: low | medium | high
status: open | closed
regression: <path/to/test_file or path/to/test_file::test_name> | control:<named durable control>
---
```

Rules, enforced by `scripts/check-incident-frontmatter.sh` in CI:

- `status: closed` requires `regression:` to name a path that exists in the repository, or `control:` followed by a name that appears in `docs/CONTROLS.md`.
- `status: open` may leave `regression:` empty or `TODO`.
- The same failure class appearing in two incidents with no test between them is a process failure. Say so in the second file.

## Body

```
## What happened
## Detected via
## Why it happened
## What changed
## Regression
```

Keep it short. The point of the file is the front matter and the regression, not the prose.
