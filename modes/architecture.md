# Mode: architecture — Architecture Exploration

Explore system design, data flow, service boundaries, and component relationships for a topic or question.

## Inputs

Examples:

- "Trace the notification delivery flow"
- "How does a purchase move through the system?"
- "Where should this new capability live?"
- "Which modules share this data model?"

## Step 0 — Prepare

1. Read `config/repos.yml` and project context when present.
2. Read related FAQ and feature-registry entries.
3. Search prior architecture reports for reusable insights.
4. Read configured repository exclusions and record each analyzed repository's commit SHA or immutable ref.
5. Check Git status before writing.

## Step 1 — Trace the system

Follow the topic through as many layers as evidence supports:

1. User or external event
2. Client entry point and local state
3. Network request or message
4. Route, handler, service, or worker
5. Persistence, cache, queue, or external integration
6. Response, event, notification, or UI update
7. Logging, metrics, and failure handling

For module analysis, identify boundaries, exports, dependencies, consumers, extension points, and ownership.

## Step 2 — Validate the model

Use source code, tests, configuration, and documentation to verify:

- Actual versus intended data flow
- Synchronous versus asynchronous work
- Source of truth for each state
- Authentication and authorization boundaries
- Failure, retry, idempotency, and rollback behavior
- Cross-platform or cross-service contracts

Mark unverified edges explicitly instead of filling them with assumptions.

## Step 3 — Write the report

Use `templates/architecture.md` and save the result under `reports/architecture/`. Include the evidence snapshot, a Mermaid diagram when it materially improves understanding, plus component mapping, data flow, API endpoints, data models, key files, risks, and `## 💡 Insights and Learning`.

## Step 4 — Accumulate knowledge

Propose updates to the feature registry, FAQ, and research history when the findings are durable and likely to be reused. Ask before writing or committing.
