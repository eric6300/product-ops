# Contributing

Thanks for helping improve product-ops. Contributions should make the
framework more reusable, safer to publish, or easier to operate across
different repository layouts.

## Before opening a pull request

Run the local checks from the framework root:

```bash
./scripts/validate-framework.sh
shellcheck .claude/hooks/guard-repos.sh scripts/validate-framework.sh tests/test-guard-repos.sh
```

Also review the diff for:

- real repository URLs, organization names, product names, or internal paths;
- tokens, credentials, private keys, `.env` content, or customer data;
- changes to the append-only knowledge-base contract;
- accidental files under `repos/`.

## Contribution guidelines

- Keep the public command surface small. Use a mode file as an internal depth
  workflow when it does not need to be a user-facing command.
- Keep repository configuration generic and provider-neutral. Never require a
  specific organization, branch name, credential format, or hosting service.
- Treat repositories under `repos/` as read-only analysis mirrors. Changes to
  application source belong in the source repository's own workflow.
- Update the relevant documentation and templates when changing a workflow or
  data format.
- Preserve stable IDs and append-only semantics in `data/`; see
  [`DATA_CONTRACT.md`](DATA_CONTRACT.md).
- Add or update a smoke test when changing the repository guard or validation
  behavior.

## Pull request checklist

- [ ] The framework validator passes.
- [ ] Shell scripts pass ShellCheck.
- [ ] No internal or sensitive data is included.
- [ ] Documentation and examples match the supported workflow.
- [ ] New report or data formats include a clear contract and migration note.
- [ ] The change does not silently broaden repository write access.
