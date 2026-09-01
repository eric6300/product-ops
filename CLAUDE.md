# product-ops — General Product Operations Framework

product-ops is a general-purpose product advisor that runs in Claude Code CLI. It helps PMs, designers, and engineers with product questions, requirements reviews, cross-platform analysis, impact analysis, and architecture exploration. Reusable findings are accumulated in `data/` so later analysis becomes more efficient.

## Commands

```text
/product-ops ask             → Answer a product question
/product-ops ask {role}      → Analyze from a specific role's perspective
/product-ops review           → Review a requirements document
/product-ops panel            → Run a multi-role discussion
/product-ops tracker          → Show the knowledge-base summary
/product-ops tutorial         → Run the interactive tutorial
/sync-repos                   → Synchronize external repositories
```

## Hard rules

1. **Search before answering**: Do not rely on memory for product or code behavior. State clearly when no evidence is found.
2. **External repositories are read-only**: Source code under `repos/` is for search and analysis only. `.claude/settings.json` and the guard hook block ordinary writes.
3. **Cite technical claims**: Use `repo/path/file:line` and mark confidence as ✅, ⚠️, or ❌.
4. **Knowledge is append-only**: Do not edit existing entries in `data/`; follow `DATA_CONTRACT.md`.
5. **Persist reports**: Store formal analysis in the appropriate `reports/` directory using a file in `templates/`.
6. **Read configuration first**: Before analysis, read `config/repos.yml` and, when present, `modes/_project.md`.
7. **Protect secrets**: Do not read, print, or commit tokens, passwords, private keys, or unpublished credentials.
8. **Confirm external writes**: Do not push, open pull requests, or modify external repositories without explicit confirmation. Review the diff first.

## Document map

| Source of truth | Location |
|-----------------|----------|
| Command routing and workflow | `.claude/skills/product-ops/SKILL.md` |
| External repository synchronization | `.claude/skills/sync-repos/SKILL.md` |
| Shared analysis rules and evaluation framework | `modes/_shared.md` |
| Analysis modes | `modes/{mode}.md` |
| Knowledge-base contract | `DATA_CONTRACT.md` |
| Role agents | `.claude/agents/` |
| Repository configuration | `config/repos.yml` |
| Project customization template | `modes/_project.template.md` |
