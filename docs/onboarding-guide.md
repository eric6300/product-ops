# Onboarding Guide

This guide takes a new user from a clean machine to a working product-ops setup. The framework reads your repositories; it does not provide or upload project source code.

## 1. Install Git

Check whether Git is installed:

```bash
git --version
```

Install Git with the package manager for your operating system if the command is unavailable.

## 2. Install Claude Code

Follow the current installation instructions in the [Claude Code documentation](https://code.claude.com/docs/en/overview). Sign in with the account your organization permits you to use.

The repository hook uses Python 3 to inspect tool input. Confirm that one of
these commands works before using the framework:

```bash
python3 --version
# Windows PowerShell may use:
python --version
```

## 3. Clone the framework

Replace the URL with your own public or private fork:

```bash
git clone <your-framework-repository-url> product-ops
cd product-ops
```

## 4. Configure repositories

Open `config/repos.yml` and:

1. Set the project name.
2. Replace the example `source` URLs.
3. Set `enabled: true` for repositories that should be analyzed.
4. Set each `local_path`, `default_branch`, `platform`, and `category`.
5. Use SSH or an already authenticated Git credential helper; never put credentials in the YAML file.

The template also defines `analysis.default_excludes`. Add any project-specific
secret, credential, generated-file, or dependency patterns before syncing.

Example:

```yaml
repositories:
  service:
    enabled: true
    local_path: "repos/service"
    source: "git@github.com:your-org/your-service.git"
    default_branch: "main"
    platform: "backend"
    category: "service"
```

## 5. Clone the analysis repositories

Open Claude Code in the framework directory:

```bash
claude
```

Run:

```text
/sync-repos
```

The command creates `repos/` when necessary and clones only enabled entries. It never resets local changes. The directory is ignored by Git and protected as read-only by `.claude/hooks/guard-repos.sh`.

## 6. Add optional project context

Copy the template:

```bash
cp modes/_project.template.md modes/_project.md
```

Fill in product terminology, supported platforms, domain rules, and information that must not be printed. The file is ignored by default. Keep it private if it contains internal context.

## 7. Validate the setup

From the framework root, run:

```bash
./scripts/validate-framework.sh
```

Inside Claude Code, `/skills`, `/agents`, `/hooks`, and `/doctor` can confirm
that the project configuration was loaded.

## 8. Start using the framework

```text
/product-ops
/product-ops ask Where is the account creation flow implemented?
/product-ops review
/product-ops panel How should this feature be rolled out?
```

The framework cites repository paths and line numbers when evidence is available. It marks uncertainty instead of presenting guesses as facts.

## 9. Review generated files

Before committing:

```bash
git status --short
git diff -- data/ reports/
```

Check for secrets, customer data, internal URLs, private names, and any other information that should not be published.

## Troubleshooting

### A repository does not clone

Check the `source` URL, branch name, local Git authentication, and repository permissions. Do not paste credentials into the configuration or into a report.

### The framework cannot find a feature

Confirm that the repository is enabled, present under `repos/`, and not excluded by its file type or search scope. Report the missing evidence as unverified.

### A write is blocked under `repos/`

This is intentional. Make changes in the source repository through its own workflow. product-ops is an analysis tool and keeps cloned repositories read-only.
