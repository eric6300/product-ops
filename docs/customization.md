# Customization Guide

The public repository contains generic defaults. Keep project-specific context in ignored or private files, and keep reusable improvements in the framework itself.

## Repository registry

`config/repos.yml` is the input to `/sync-repos` and the analysis workflows. A nested entry is a sync target when it contains:

- `enabled: true`
- `local_path`
- `source`
- optional `default_branch` (defaults to `main`)

Useful metadata includes:

- `platform`: `android`, `ios`, `web`, `backend`, or another project-specific value
- `category`: `client`, `service`, `documentation`, `shared`, or another useful category
- `description`: short human-readable context

The registry is not a secret store. Keep credentials outside the file.

## Project context

Copy `modes/_project.template.md` to `modes/_project.md` for private context such as:

- Product and service names
- Target users and domain rules
- Supported platforms and architecture
- Preferred terminology and report language
- Information that must not appear in generated reports

If the context should be shared publicly, create a sanitized file with no private details instead of publishing the internal file.

## Adding a role

Create a Markdown file under `.claude/agents/` with frontmatter similar to:

```yaml
---
name: product-ops-security
description: Security perspective for product analysis
tools: Read, Grep, Glob
model: inherit
---
```

Include the role's focus areas, search guidance, typical tasks, evidence requirements, and a reminder to read `.claude/agents/_agent-shared.md`. Add the new role to the role-selection tables in `.claude/skills/product-ops/SKILL.md` and the relevant mode files.

## Adding a mode

Create a mode file under `modes/` and document:

1. Inputs
2. Context files to load
3. Search or analysis steps
4. Report destination and template
5. Knowledge-base updates
6. Confirmation points before writing or external actions

Add the mode to the router table in `.claude/skills/product-ops/SKILL.md` and add a matching template under `templates/` when it produces a formal report.

## Knowledge-base customization

Keep the append-only behavior in `DATA_CONTRACT.md`. If you add a data file:

1. Define its purpose and format at the top of the file.
2. Document its write and merge behavior in `DATA_CONTRACT.md`.
3. Add an appropriate `merge` rule to `.gitattributes` if concurrent append-only updates are expected.
4. Add it to tracker instructions and the relevant mode files.

## Publishing checklist

Before making a fork public:

- Remove all real repository URLs, organization names, product names, customer data, and internal paths.
- Remove generated reports and populated knowledge-base entries unless they are intentionally public.
- Review Git history, branches, tags, and remotes for private information.
- Search the working tree for tokens, private keys, `.env` content, internal domains, and personal data.
- Replace example placeholders only in a private copy or in a controlled project configuration.
- Keep `repos/` out of Git.
