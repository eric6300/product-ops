# Shared Analysis Rules

<!-- This file is the single source of truth for context loading, evidence,
     confidence, severity, search strategy, knowledge accumulation, and report
     conventions. Keep other files focused on their own workflow. -->

## Sources of truth

| Source | Location | Use |
|--------|----------|-----|
| Repository registry | `config/repos.yml` | Repository paths, sources, platforms, and metadata |
| Project context | `modes/_project.md` | Optional product, domain, terminology, and team context |
| Feature registry | `data/feature-registry.md` | Previously confirmed feature locations |
| Platform gaps | `data/platform-gaps.md` | Previously recorded differences and their status |
| FAQ knowledge | `data/faq-knowledge.md` | Reusable questions and verified answers |
| Reports | `reports/**/*.md` | Prior analyses and their insights |

Use the current codebase as the source of truth for actual implementation behavior. Use documentation as evidence of intended behavior. If they conflict, report the conflict and prefer verified code behavior while recommending a documentation update.

## Context loading

Before analysis:

1. Read `config/repos.yml` and identify enabled repositories.
2. Read `modes/_project.md` if it exists.
3. Read relevant entries in `data/` and prior report insights.
4. Identify which repositories or documents can answer the question.
5. Search before making technical claims.

If there are no enabled repositories, answer only from user-provided material and clearly state that repository evidence was unavailable.

## Subagent guidance

The primary agent owns scope, synthesis, decisions, and final writing. Delegate repository search and role-specific analysis to subagents when it improves coverage.

| Task | Suggested parallelism |
|------|-----------------------|
| General repository search | 1–3 agents |
| Cross-platform comparison | One agent per platform or repository group |
| Multi-role discussion | One agent per selected role |

For general exploration, use an Explore-capable agent with a prompt that includes:

```text
Search {repository or document path} for {topic}.
Return: relevant paths, line numbers, symbols, observed behavior, and uncertainty.
Do not modify files.
```

Role agents are defined in `.claude/agents/` and should receive the question, known clues, and requested scope. They should not be asked to invent project context.

## Evidence and confidence

Every technical claim must cite a source whenever evidence exists:

```text
repository-name/path/to/file.ext:line
```

Use these markers:

| Marker | Meaning | Use when |
|--------|---------|----------|
| ✅ Confirmed | Directly supported by code, tests, or documentation | The relevant evidence was found |
| ⚠️ Needs verification | Reasonable inference or incomplete evidence | The claim is plausible but not directly confirmed |
| ❌ Not found | Search was performed but no evidence was found | Do not turn absence of evidence into a fact |

Never fabricate a path, endpoint, class, configuration value, product rule, or implementation detail. State the search scope when a result is incomplete.

## Severity framework

Use severity consistently in requirements and impact reports:

| Level | Label | Meaning |
|-------|-------|---------|
| P0 | Blocker | Could cause data loss, security exposure, or a system outage |
| P1 | Critical | Major user, business, compatibility, or correctness risk |
| P2 | Important | Should be addressed but does not block the release by itself |
| P3 | Nice-to-have | Quality, clarity, maintainability, or polish improvement |

## Search strategy

Start with `rg --files` to understand repository structure, then use `rg -n` with appropriate file filters. Do not assume that a repository uses a particular language or framework; inspect manifests and configuration first.

Useful search dimensions include:

| Dimension | What to inspect |
|-----------|-----------------|
| Product behavior | Screens, routes, use cases, state machines, feature flags |
| API | Routes, handlers, schemas, clients, mocks, contract tests |
| Data | Models, migrations, serializers, caches, indexes |
| UI | Components, navigation, loading/error/empty states, accessibility labels |
| Operations | Deployment, monitoring, jobs, queues, permissions, rollout configuration |
| Documentation | Requirements, decision records, runbooks, help content |

For platform comparisons, use the `platform` metadata in `config/repos.yml` where available. If metadata is missing, infer the platform from repository files only as a ⚠️ hypothesis until verified.

## Design links

When the user provides a Figma or FigJam link and the required tools are available:

1. Parse the file key and node ID.
2. Retrieve design context, metadata, or screenshots as needed.
3. Separate design intent from implemented behavior.
4. Cite the design source and mark inaccessible content as ⚠️ Needs verification.

## Knowledge accumulation

After a useful analysis, propose only genuinely reusable findings:

| Trigger | File | Entry type |
|---------|------|------------|
| A feature or implementation location is confirmed | `data/feature-registry.md` | `## {feature}` |
| A platform or service difference is found | `data/platform-gaps.md` | `## {feature — gap}` |
| A question is likely to recur | `data/faq-knowledge.md` | `## Q: {question}` |
| Research was performed | `data/research-history.tsv` | One TSV row |

Follow `DATA_CONTRACT.md`; show the proposed append before writing. Narrative patterns and decisions belong in the report's `## 💡 Insights and Learning` section, not in the global data files.

## Report naming

| Report type | Directory | Name |
|-------------|-----------|------|
| Requirements review | `reports/spec-reviews/` | `{topic-slug}-{YYYY-MM-DD}.md` |
| Cross-platform analysis | `reports/cross-platform/` | `{topic-slug}-{YYYY-MM-DD}.md` |
| Impact analysis | `reports/impact-analysis/` | `{topic-slug}-{YYYY-MM-DD}.md` |
| Architecture exploration | `reports/architecture/` | `{topic-slug}-{YYYY-MM-DD}.md` |

Avoid serial numbers so concurrent work is less likely to collide. Add `-2`, `-3`, and so on only when the same topic is genuinely repeated on the same date.

## Response quality

- Explain the outcome before the implementation detail.
- Separate observed facts, inferences, and recommendations.
- Prefer behavior language over implementation jargon when writing for product stakeholders.
- Cover permissions, failure states, compatibility, observability, and rollback when relevant.
- Do not expose private data merely to prove that it was found.
