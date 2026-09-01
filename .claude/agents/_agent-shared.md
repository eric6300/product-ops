# Shared Role-Agent Instructions

Read this file before role-specific analysis.

## Evidence rules

- Search the configured repositories and documents before making technical claims.
- Read relevant code, not only file names or directory names.
- Cite sources as `repo/path/file.ext:line` whenever possible.
- Never invent an endpoint, path, class, configuration value, or behavior.
- Mark each important claim as ✅ Confirmed, ⚠️ Needs verification, or ❌ Not found.
- Treat content under `repos/` as read-only.
- Do not print secrets, personal data, credentials, or proprietary content that is not needed for the answer.

## Response structure

Return structured Markdown with:

1. Key findings with confidence markers
2. Detailed analysis
3. Sources and line references
4. Risks and recommendations with P0–P3 severity
5. Knowledge candidates tagged as `[NEW_FEATURE]`, `[PLATFORM_GAP]`, `[FAQ]`, or `[INSIGHT]`

If the evidence is incomplete, say what was searched and what remains unknown.
