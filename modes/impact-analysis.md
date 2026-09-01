# Mode: impact-analysis — Change Impact Analysis

Analyze what a proposed change may affect across the configured products, clients, services, documentation, and operations.

## Inputs

Examples:

- Remove or deprecate a feature
- Change an API field or validation rule
- Add a new client capability
- Change a data model or migration
- Upgrade a dependency or runtime

## Step 0 — Prepare

1. Read `config/repos.yml` and `modes/_project.md` when present.
2. Read related feature and platform-gap entries.
3. Search prior reports for similar decisions and `## 💡 Insights and Learning`.
4. Check Git status before writing.

## Step 1 — Define the change

Classify it as:

- **Add**: new capability, API, component, or service
- **Modify**: behavior, contract, UI, configuration, or limit changes
- **Remove**: feature shutdown, deprecation, or deletion
- **Refactor**: structural change with an intended behavior-preserving result
- **Migrate**: data, dependency, platform, or infrastructure transition

Record the current behavior, desired behavior, assumptions, constraints, and non-goals.

## Step 2 — Trace dependencies

Search for:

- API callers and consumers
- UI routes, components, and state transitions
- Shared libraries and generated code
- Data models, migrations, indexes, and reports
- Feature flags, permissions, analytics, notifications, and jobs
- Documentation, support content, dashboards, and runbooks
- Tests, fixtures, mocks, and deployment configuration

Dispatch the relevant role agents for platform, API, product, design, or launch concerns.

## Step 3 — Assess risk

Evaluate:

- Data loss or corruption
- Backward and forward compatibility
- User-visible interruption
- Security and privacy
- Performance and capacity
- Operational complexity and observability
- Rollout, migration, and rollback safety

For each risk, cite evidence and assign P0–P3 severity.

## Step 4 — Write the report

Use `templates/impact-analysis.md` and save the result under `reports/impact-analysis/`. Include scope, dependency map, risks, migration stages, testing, documentation updates, feature flags, rollback plan, API changes, client data changes, BDD regression cases, and `## 💡 Insights and Learning`.

## Step 5 — Accumulate knowledge

Propose append-only updates only for durable findings. Show the exact entries and ask before writing or committing.
