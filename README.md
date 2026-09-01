# product-ops

A reusable AI product-operations framework for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI. It reads the code repositories and product documentation you configure, then helps with product questions, requirements reviews, cross-platform analysis, impact analysis, and architecture exploration.

This repository contains the framework only. It includes no product source code, product knowledge, analysis reports, brand assets, or project-specific remote configuration. Configure `config/repos.yml` before using it.

The framework is inspired by the ideas behind [career-ops](https://github.com/eric6300/career-ops).

## Features

| Command | Purpose |
|---------|---------|
| `/product-ops ask` | Answer product questions using documents and source code |
| `/product-ops ask {role}` | Analyze a question from a specific role's perspective |
| `/product-ops review` | Review a requirements document or PRD |
| `/product-ops panel` | Run a multi-role product discussion |
| `/product-ops tracker` | Review the knowledge base and report status |
| `/product-ops tutorial` | Run an interactive introduction |
| `/sync-repos` | Synchronize configured external repositories |

Included roles: `android`, `ios`, `frontend`, `backend`, `pm`, `uiux`, and `marketing`.

## Quick start

1. Clone this repository and start Claude Code in the directory.

   ```bash
   git clone <your-repository-url> product-ops
   cd product-ops
   claude
   ```

2. Edit `config/repos.yml`. Add the repositories you want to analyze and set the correct `source`, `local_path`, and `default_branch` values.

3. Run `/sync-repos` when needed. Cloned repositories are placed in the `.gitignore`d `repos/` directory.

4. Run `/product-ops` to see the menu, or use one of the commands above.

Read [`docs/onboarding-guide.md`](docs/onboarding-guide.md) and [`docs/customization.md`](docs/customization.md) for more detail.

## Directory structure

```text
product-ops/
├── CLAUDE.md                         # Operating rules and document map
├── DATA_CONTRACT.md                  # Knowledge-base write contract
├── config/repos.yml                  # External repository configuration template
├── data/                             # Empty knowledge-base templates
├── modes/                            # Analysis modes and project template
├── reports/                          # Generated report destination
├── templates/                        # Report templates
└── .claude/
    ├── agents/                       # Role agents
    ├── hooks/guard-repos.sh          # Read-only protection for cloned repositories
    └── skills/                       # Claude Code commands and sync workflow
```

## Safety boundaries

- `repos/` is intended to contain local mirrors of external source code; the framework must not modify the code inside them.
- Never commit access tokens, SSH private keys, `.env` files, or other secrets.
- Analysis results and the knowledge base may contain information about your project. Review `data/`, `reports/`, and custom files before publishing.
- The framework does not automatically push content to any remote. Review the diff before committing, pushing, or opening a pull request.

## Customization

- Configure repositories in `config/repos.yml`.
- Copy `modes/_project.template.md` to `modes/_project.md` and add project-specific context. The file is ignored by default so internal context is not published accidentally.
- Edit the role definitions in `.claude/agents/` or add your own roles.
- Adapt the report formats in `templates/` to your team's needs.
- Treat `DATA_CONTRACT.md` as the source of truth for knowledge-base updates.

## License

MIT License. See [`LICENSE`](LICENSE).
