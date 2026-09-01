# Mode: tutorial — Interactive Introduction

Guide a new user through the framework one step at a time. Wait for the user's reply before moving to the next step.

## Welcome

Explain that product-ops can:

1. Answer questions using configured documents and repositories
2. Review product requirements
3. Compare behavior across platforms
4. Trace architecture and data flow
5. Analyze the impact of proposed changes
6. Ask specialist role agents for focused feedback

Ask whether the user wants to continue. Accept `next` to continue or `skip` to end the tutorial.

## Step 1 — Ask a question

Invite the user to ask a question about their own project, for example:

- "Where is the account creation flow implemented?"
- "Does this feature behave consistently across clients?"
- "Which service owns this API?"

Run the `ask` workflow and show the sources and confidence markers.

## Step 2 — Review a requirement

Invite the user to paste a small requirement or PRD. Explain that the framework compares it with the configured repositories, identifies risks, and can produce a structured report.

## Step 3 — Use role agents

Demonstrate a role-specific request such as:

```text
/product-ops ask backend Which endpoint owns account recovery?
```

Explain that role agents provide focused analysis and cite evidence; they do not modify source repositories.

## Step 4 — Knowledge and privacy

Explain that reusable findings can be appended to `data/`, while reports are saved under `reports/`. Remind the user to review generated content for secrets or private project information before publishing.

## Completion

Show the main commands and point the user to `docs/customization.md`. Invite them to configure `config/repos.yml` and ask their first project question.
