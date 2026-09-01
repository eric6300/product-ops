# Security and Data Handling

product-ops is a prompt-, configuration-, and documentation-driven analysis
framework. It is designed to inspect repositories, not to modify application
source code. The analysis process may still expose repository content to the
configured AI tooling, so configure and operate it as a data-processing tool.

## Before syncing a repository

1. Confirm that the repository and its contents may be processed by the
   Claude Code account and model provider being used.
2. Keep credentials in the local Git credential helper or SSH agent, never in
   `config/repos.yml`.
3. Add exclusions for secrets, generated output, dependency trees, dumps, and
   other material that should not be searched:

   ```yaml
   analysis:
     default_excludes:
       - ".env*"
       - "**/*.pem"
       - "**/secrets/**"
       - "**/database-dumps/**"
   ```

4. Add narrower `exclude` patterns to individual repository entries when a
   project needs stricter handling. Exclusions take precedence over `include`.
5. Set a commit-SHA `ref` when a report must be reproducible. A tag is a
   convenience only; record the resolved SHA and verify that the tag is
   protected if you rely on it.

Exclusions are workflow instructions used by searches; they are not an
operating-system access-control boundary. Remove sensitive material from the
analysis mirror or use filesystem and account permissions when stronger
isolation is required.

## Before publishing or committing

Review:

- `data/` and `reports/` for source excerpts, customer information, internal
  names, URLs, and credentials;
- `modes/_project.md`, local settings, and Git remotes;
- Git history, branches, tags, and generated files;
- repository revisions and paths recorded in evidence snapshots.

The `repos/` directory is ignored and the framework hook rejects common write
operations there. This is a best-effort guardrail for the Claude Code workflow;
it does not replace OS permissions, repository protections, or review of shell
commands.

## If evidence is missing

The framework should say when no enabled repository or usable source evidence
was available. Do not fill that gap with guessed paths, endpoints, or product
behavior. Mark the result as unverified and request the minimum additional
context needed.
