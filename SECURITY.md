# Security

Please do not report secrets, private source code, or exploitable details in a
public issue.

## Reporting a vulnerability

Use a private security-advisory or private contact channel provided by the
repository host and notify the maintainers with:

- the affected file or workflow;
- a minimal reproduction that does not contain real credentials or customer
  data;
- the impact and any safe mitigation;
- whether the issue affects the framework itself or a configured external
  repository.

If no private channel is configured, ask the repository maintainers for one
before sharing sensitive details. Please allow maintainers reasonable time to
investigate and release a fix before public disclosure.

## Data-handling expectations

This framework can search configured repositories and write findings into
`data/` and `reports/`. Those files may contain private product information.
Users are responsible for applying their organization's policies to the
repositories, Claude Code account, model provider, generated output, and Git
history they use with the framework.

- Keep credentials out of `config/repos.yml`; use SSH agents or credential
  helpers.
- Add project-specific secret, generated-file, and dependency patterns to
  `analysis.default_excludes` before syncing repositories.
- Review generated reports and knowledge-base entries before committing or
  publishing them.
- Treat the default exclusions and repository hook as defense-in-depth, not as
  a guarantee that a secret cannot be read or transmitted.
- Keep `modes/_project.md` private when it contains internal context.
- Use an immutable repository `ref` when reproducibility or auditability is
  important.

For the operational checklist, see
[`docs/security-and-data-handling.md`](docs/security-and-data-handling.md).
