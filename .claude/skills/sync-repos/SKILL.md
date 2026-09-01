---
name: sync-repos
description: Clone and update the external repositories configured in config/repos.yml
user_invocable: true
---

# sync-repos — Synchronize analysis repositories

Read `config/repos.yml` and recursively find entries containing `enabled: true`, `local_path`, and `source`. The configuration may be nested under any key. Entries without all three values are not sync targets.

The framework never includes or assumes a particular organization, repository, provider, credential, or branch name. The `source` value may be an SSH or HTTPS Git URL.

## Procedure

1. Read and validate `config/repos.yml`.
2. List enabled repositories and show their local paths before making changes.
3. Check whether `repos/` exists. Create it if necessary.
4. For each enabled entry:
   - If the local path does not exist, clone from `source` using `default_branch` when provided, otherwise `main`.
   - If the local path is already a Git repository, inspect its status first.
   - Do not discard local changes. If the repository is clean, check out the configured default branch and pull the latest changes.
   - If the repository has local changes, do not reset or overwrite them; report the repository as skipped and explain why.
5. Keep all cloned repositories under `repos/`; that directory is ignored by Git and protected as read-only by the project hook.
6. Report which repositories were cloned, updated, already current, skipped, or failed.

## Allowed synchronization commands

The following commands are acceptable inside `repos/` when needed for synchronization:

```bash
git clone <source> <directory>
git fetch
git checkout <branch>
git pull
git status
git log
git diff
```

Do not use `git add`, `commit`, `push`, `reset`, `clean`, `stash`, or destructive file operations inside a cloned repository.

## Suggested output

```text
sync-repos — completed

✅ Updated or cloned:
  repos/example-service  ← main, up to date

⏭️ Skipped:
  repos/example-client   ← local changes detected; nothing overwritten

❌ Failed:
  repos/example-docs     ← authentication or network error
```
