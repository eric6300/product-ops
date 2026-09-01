# Mode: spec-review — Requirements Review

Review a product requirements document, PRD, design brief, or feature proposal against the available project context and repositories.

## Inputs

The requirement may be:

- Text pasted by the user
- A document URL
- A Figma design link
- A FigJam board link
- A file in the current workspace

## Step 0 — Prepare

1. Read `config/repos.yml` and identify relevant repositories.
2. Read `modes/_project.md` when present.
3. Read related entries in `data/feature-registry.md` and `data/platform-gaps.md`.
4. Search recent reports for `## 💡 Insights and Learning` related to the topic.
5. Inspect design sources when the user provides them and the required tools are available.
6. Check Git status before writing. Keep the report isolated from unrelated changes.

## Step 1 — Understand the requirement

Extract:

- Problem and desired outcome
- Target users, roles, and permissions
- Products, services, and platforms in scope
- User flow and expected behavior
- Data, API, and integration needs
- Empty, loading, error, offline, and recovery states
- Success metrics and rollout constraints
- Ambiguities that require clarification

Do not fill missing information with assumptions. Put unresolved decisions in the report.

## Step 2 — Compare with current implementation

Search relevant repositories for:

- Existing screens, routes, components, and state transitions
- API endpoints, request/response schemas, and validation
- Data models, migrations, and persistence
- Feature flags, permissions, analytics, and notifications
- Existing tests, documentation, and runbooks

Dispatch role agents based on the requirement's scope:

| Scope | Role agent |
|-------|------------|
| Android | `product-ops-android` |
| iOS | `product-ops-ios` |
| Web | `product-ops-frontend` |
| API or data changes | `product-ops-backend` |
| User-facing behavior | `product-ops-uiux` |
| Launch or communication | `product-ops-marketing` |
| Ambiguous or broad scope | `product-ops-pm` |

## Step 3 — Write the report

Use `templates/spec-review.md` and include:

- Requirement summary
- Feasibility and complexity
- Existing implementation and reusable assets
- P0–P3 risks
- Cross-platform considerations
- Role-agent perspectives, consensus, and disagreements
- Clarifying questions
- MVP and phased recommendations
- User stories and acceptance criteria
- API specification or explicit "not applicable"
- Client data-layer changes or explicit "not applicable"
- BDD test cases
- `## 💡 Insights and Learning`

Save the report as `reports/spec-reviews/{topic-slug}-{YYYY-MM-DD}.md`.

## Step 4 — Update knowledge

Propose append-only updates to the feature registry, platform gaps, FAQ, and research history. Show the exact entries before writing them. Ask for confirmation before committing.
