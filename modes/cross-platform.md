# Mode: cross-platform — Cross-Platform Consistency Review

Compare a feature across the platforms or clients configured in `config/repos.yml`. The framework does not assume that every project has Android, iOS, or Web clients; compare only the platforms that exist.

## Inputs

Examples:

- "Compare the sign-in flow across clients"
- "Is file upload behavior consistent on Web and mobile?"
- "Which platform is missing this feature?"

## Step 0 — Prepare

1. Read `config/repos.yml` and group repositories by their `platform` metadata.
2. Read `data/platform-gaps.md` and `data/feature-registry.md` for prior findings.
3. Check recent reports for the same feature.
4. Check Git status before writing.

## Step 1 — Search in parallel

Dispatch one Explore-capable agent per platform or repository group. Ask each agent to report:

1. Whether the feature exists
2. Entry points and key symbols
3. User-visible behavior
4. API calls and data models
5. Loading, empty, error, and permission states
6. Platform-specific behavior and its rationale
7. Tests and documentation

Use the platform-specific role agent as a second perspective when the question involves implementation risk.

## Step 2 — Compare dimensions

Compare:

| Dimension | Questions |
|-----------|-----------|
| Availability | Does the feature exist on each platform? |
| Core behavior | Does the same action produce the same result? |
| UI and interaction | Are the flows equivalent while respecting native conventions? |
| API usage | Are endpoints and payloads compatible? |
| Data layer | Are models and required fields aligned? |
| Edge cases | Are errors, empty states, loading, and offline states covered? |
| Permissions | Do roles and access rules match? |
| Observability | Are analytics, logs, and failure signals comparable? |

Classify gaps as:

| Type | Default severity |
|------|-----------------|
| Missing capability | P1 |
| Behavioral difference | P1 |
| UI or UX difference | P2 |
| Edge-case difference | P2–P3 |
| Justified platform-specific behavior | P3, if documented |

## Step 3 — Write the report

Use `templates/cross-platform.md` and save the result under `reports/cross-platform/`. Include evidence and confidence for every cell that contains a factual claim.

## Step 4 — Accumulate knowledge

Propose append-only updates to `data/platform-gaps.md`, `data/feature-registry.md`, and `data/research-history.tsv`. Include the report path and ask for confirmation before writing or committing.
