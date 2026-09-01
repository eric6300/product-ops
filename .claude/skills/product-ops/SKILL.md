---
name: product-ops
description: General product operations agent for questions, requirements reviews, and multi-role analysis
user_invocable: true
args: mode
argument-hint: "[ask | ask {role} | review | panel | tracker | tutorial]"
---

# product-ops — Router

Use `{{mode}}` to select the appropriate workflow.

| Input | Mode | Purpose |
|-------|------|---------|
| Empty | `discovery` | Show the command menu and setup status |
| `ask` + question | `ask` | Answer a product or codebase question |
| `ask {role}` + question | `ask` | Answer from a named role's perspective |
| `review` + requirements | `spec-review` | Review a product requirement |
| `panel` + topic | `agent-panel` | Run a multi-role discussion |
| `tracker` | `tracker` | Summarize the knowledge base and reports |
| `tutorial` | `tutorial` | Guide a first-time user |

Legacy inputs such as `qa`, `cross-platform`, `arch`, and `impact` should be routed to `ask`, with a suggestion to use the relevant formal analysis mode when appropriate.

If the input is not a known subcommand, route requests containing requirement language (`PRD`, `feature spec`, `requirements`, `planning`, or `new feature`) to `spec-review`. Route all other questions to `ask`.

## Discovery mode

Before showing the menu:

1. Read `config/repos.yml`.
2. Check whether the configured repository entries are enabled and whether `repos/` exists.
3. Mention `/sync-repos` when a configured repository is missing.
4. Read `modes/_project.md` when it exists; otherwise mention the optional template.

Show:

```text
product-ops — Product Operations Framework

What would you like to do?
  /product-ops ask             → Answer a product question
  /product-ops ask {role}      → Use a specific role's perspective
  /product-ops review          → Review a requirements document
  /product-ops panel           → Run a multi-role discussion
  /product-ops tracker         → Show the knowledge-base summary
  /product-ops tutorial        → Start the interactive tutorial
  /sync-repos                  → Sync configured repositories

You can also paste a question or requirements document directly.
```

## Shared context loading

After selecting a mode, load only the files needed for that mode:

1. `config/repos.yml`
2. `modes/_project.md` if present
3. `modes/_shared.md`
4. The selected mode file
5. The relevant files under `data/` and `reports/`

Treat `config/repos.yml` as metadata, not as a source of product truth. Verify claims in the configured repositories or documents.

## Agent panel mode

For `/product-ops panel {topic}`:

1. Read `modes/_shared.md` and `.claude/agents/_agent-shared.md`.
2. Select roles based on the topic, or honor an explicit comma-separated role list.
3. Dispatch the selected role agents in parallel when possible. Use the names `product-ops-android`, `product-ops-ios`, `product-ops-frontend`, `product-ops-backend`, `product-ops-pm`, `product-ops-uiux`, and `product-ops-marketing`.
4. Ask each agent for evidence, uncertainty, risks, and recommendations.
5. Synthesize the results into consensus, disagreements, open questions, and next steps.
6. Write a report with `templates/spec-review.md` or the closest matching template.

## Knowledge and report handling

- Read the applicable knowledge files before research.
- Follow `DATA_CONTRACT.md` exactly when adding knowledge.
- Formal reports belong in `reports/{category}/` and should use a name such as `{topic-slug}-{YYYY-MM-DD}.md`.
- Include a `## 💡 Insights and Learning` section in every formal report.
- Before writing, show the intended files and avoid overwriting unrelated user changes.
- After writing, show the diff and ask for confirmation before committing.

## Git workflow

The framework does not assume a remote name, branch policy, or hosting provider.

For a report-producing mode:

1. Run `git status --short` and preserve unrelated changes.
2. If the current branch is a protected or shared branch, recommend a branch named `product-ops/{mode}/{topic-slug}-{date}`.
3. Write the report and knowledge updates only after confirming their scope.
4. Show the diff and run the relevant checks.
5. Commit only after explicit user confirmation.
6. Push or open a pull request only after a second explicit confirmation for that external action.

For `ask`, `tracker`, and `tutorial`, do not create a branch automatically. If `ask` produces a reusable fact, propose the exact append-only entry and ask before writing it.

## Evidence and confidence

Every technical claim in an answer or report must include a source when one exists:

```text
repo-name/path/to/file.ext:line
```

Use the confidence markers defined in `modes/_shared.md`. Never invent a path, endpoint, file name, or implementation detail.

## Figma and design links

When the user provides a Figma or FigJam link and the required Figma tools are available:

1. Parse the file key and node ID from the URL.
2. Retrieve design context, metadata, and screenshots as needed.
3. Compare the design evidence with the written requirement and codebase evidence.
4. Cite the design source in the report and mark any inaccessible information as unverified.
