# Mode: ask — Product Question and Answer

Answer a product, system, or codebase question. Start with the knowledge base and project documentation, then inspect source code when needed. Invite the relevant role agent for platform-specific questions.

## Inputs

Examples:

- "How does the account recovery flow work?"
- "Is this feature available on Android, iOS, and Web?"
- "Which API handles file uploads?"
- "How is the notification preference stored?"
- "What would change if we removed this field?"

## Step 0 — Load existing knowledge

1. Read `data/faq-knowledge.md` for the same or a similar question.
2. Read `data/feature-registry.md` for related feature locations.
3. Read recent `reports/` insights when the question involves a previous decision or known gap.
4. Read `analysis.default_excludes` and repository-level `include` / `exclude`
   patterns from `config/repos.yml`.
5. If an entry is older than 90 days or conflicts with current evidence, re-verify it.

## Step 1 — Search documentation

Inspect repositories marked as documentation or handbook repositories in `config/repos.yml`. Search their actual paths for the topic. If documentation provides a clear answer and the question does not concern implementation details, summarize it and cite the document.

## Step 2 — Search repositories and select roles

Use `rg` over each relevant repository's configured `include` scope while
honoring all default and repository exclusions. Record repository commit SHAs
or immutable refs for evidence. Select role agents by topic:

| Topic or keyword | Role agent |
|------------------|------------|
| Android, Kotlin, Gradle, Play policy | `product-ops-android` |
| iOS, Swift, UIKit, SwiftUI, App Store | `product-ops-ios` |
| Web, React, Next.js, browser, SEO | `product-ops-frontend` |
| API, database, service, queue, migration | `product-ops-backend` |
| Requirement, scope, priority, acceptance criteria | `product-ops-pm` |
| UI, UX, design, accessibility, consistency | `product-ops-uiux` |
| Naming, launch, messaging, adoption | `product-ops-marketing` |

The user may explicitly request `ask {role}`. Dispatch multiple roles when the question spans more than one area.

## Step 3 — Synthesize the answer

Use this structure:

```markdown
## {Question summary}

{Short answer and important caveats}

### Evidence

| Source | Location | Confidence |
|--------|----------|------------|
| {repository or document} | {path:line} | {✅/⚠️/❌} |

### Risks or open questions

- {Only when relevant}
```

Distinguish current behavior from desired behavior. If documentation and code disagree, state the conflict explicitly.

## Step 4 — Offer deeper analysis when appropriate

Suggest a formal report when the question reveals:

| Signal | Suggested mode |
|--------|----------------|
| Different behavior across clients or platforms | `cross-platform` |
| A proposed change, removal, migration, or deprecation | `impact-analysis` |
| Data flow, service boundaries, or system design | `architecture` |

Ask before switching to a report-producing workflow.

## Step 5 — Accumulate reusable knowledge

If the answer contains a durable, verifiable fact, show the proposed append to the relevant `data/` file. Write only after the user confirms. Record the research row when research was performed.
