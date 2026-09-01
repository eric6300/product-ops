# Data Contract — Knowledge-Base Write Rules

`data/` is the cross-session knowledge base for product-ops. This document is the single source of truth for all knowledge-write rules.

## Files

| File | Content | Format |
|------|---------|--------|
| `data/faq-knowledge.md` | Reusable questions and answers | `## Q:` entry blocks |
| `data/feature-registry.md` | Features and implementation locations | `## ` entry blocks |
| `data/platform-gaps.md` | Known differences between platforms or services | `## ` entry blocks |
| `data/research-history.tsv` | Research history | TSV with a header row |

Each Markdown data file has its own `<!-- FORMAT SPEC -->` at the top. The TSV
schema is defined by its first row and by the rules below. Read the applicable
specification before writing.

## Write rules

1. Append new entries at the end of the file. Follow the field order in the file's FORMAT SPEC; use `—` for required values that are not available.
2. Do not edit or delete existing entries. When an existing entry changes, append a complete new entry with the same title and stable `ID`.
3. The last entry with a given `ID` (or, for legacy entries, title) is authoritative (latest-wins). Do not use strikethrough or in-place edits to represent an update.
4. If old entries need to be compacted, do so in a separate commit after confirming that no other knowledge-base changes are in progress.
5. Keep the knowledge-base updates from one interaction in a single commit.
6. Include the repository commit or immutable ref used as evidence whenever repository evidence exists. Use `—` when no repository was searched.
7. Knowledge-base entries may contain project secrets or private details. Review them manually before publishing.

## TSV schema

`data/research-history.tsv` has these columns, in order:

```text
date  mode  query  report_path  source_revision  repositories  status
```

Fields are separated by a single tab. `query` and other fields must be
single-line values with tabs replaced by spaces. `source_revision` records
semicolon-separated `repository-id=commit-or-ref` values. `status` is one of
`complete`, `partial`, or `not-found`.

## Git merge strategy

`.gitattributes` enables `merge=union` for knowledge files to reduce conflicts
when multiple branches append entries. This does not make edits to existing
lines safe and does not validate block boundaries; manually inspect merges and
run the framework validator afterward.

## Insights and learning

Write narrative insights, patterns, and decisions in the report that produced them instead of creating a separate global insights file. Every report template includes an `## 💡 Insights and Learning` section.
