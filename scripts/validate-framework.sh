#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -P -- "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

fail() {
    echo "validate-framework: $1" >&2
    exit 1
}

required_files=(
    "CLAUDE.md"
    "DATA_CONTRACT.md"
    "README.md"
    "config/repos.yml"
    ".claude/settings.json"
    ".claude/hooks/guard-repos.sh"
    ".claude/skills/product-ops/SKILL.md"
    ".claude/skills/sync-repos/SKILL.md"
    "templates/panel.md"
    "CONTRIBUTING.md"
    "SECURITY.md"
    "docs/security-and-data-handling.md"
    "tests/test-guard-repos.sh"
)

for file in "${required_files[@]}"; do
    [[ -f "$file" ]] || fail "missing required file: $file"
done

[[ -x ".claude/hooks/guard-repos.sh" ]] || fail ".claude/hooks/guard-repos.sh must be executable"
[[ -x "scripts/validate-framework.sh" ]] || fail "scripts/validate-framework.sh must be executable"
[[ -x "tests/test-guard-repos.sh" ]] || fail "tests/test-guard-repos.sh must be executable"

PYTHON_BIN=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 \
        && "$candidate" -c 'import sys; raise SystemExit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
        PYTHON_BIN="$(command -v "$candidate")"
        break
    fi
done
if [[ -z "$PYTHON_BIN" ]]; then
    fail "Python 3 is required"
fi

"$PYTHON_BIN" -m json.tool .claude/settings.json >/dev/null || fail "invalid .claude/settings.json"
FRAMEWORK_ROOT="$ROOT_DIR" "$PYTHON_BIN" - <<'PY'
import json
import os
from pathlib import Path

root = Path(os.environ["FRAMEWORK_ROOT"])
settings = json.loads((root / ".claude/settings.json").read_text())
hooks = settings.get("hooks", {}).get("PreToolUse", [])
if not any(item.get("matcher") == "Bash|PowerShell" for item in hooks):
    raise SystemExit("PreToolUse must cover Bash|PowerShell")

deny = settings.get("permissions", {}).get("deny", [])
for rule in ("Edit(repos/**)", "Write(repos/**)", "NotebookEdit(repos/**)"):
    if rule not in deny:
        raise SystemExit(f"missing permission deny rule: {rule}")
PY

ruby - config/repos.yml <<'RUBY' || fail "invalid config/repos.yml"
require "pathname"
require "yaml"

data = YAML.load_file(ARGV.fetch(0))
abort "config must be a mapping" unless data.is_a?(Hash)
abort "unsupported schema_version" unless data["schema_version"] == 1

excludes = data.dig("analysis", "default_excludes")
abort "analysis.default_excludes must be a non-empty string array" unless
  excludes.is_a?(Array) && excludes.all? { |item| item.is_a?(String) && !item.empty? }

seen = {}
walk = lambda do |value|
  case value
  when Hash
    if value.key?("local_path")
      path = value["local_path"].to_s
      valid_path = path.start_with?("repos/") &&
        !Pathname.new(path).absolute? && !path.split("/").include?("..")
      abort "local_path must be under repos/: #{path}" unless valid_path
      abort "duplicate local_path: #{path}" if seen[path]
      seen[path] = true
      abort "sync target missing source: #{path}" if value["enabled"] == true && value["source"].to_s.empty?
    end

    %w[include exclude].each do |key|
      patterns = value[key]
      next if patterns.nil?
      valid_patterns = patterns.is_a?(Array) &&
        patterns.all? { |item| item.is_a?(String) && !item.empty? }
      abort "#{key} must be a non-empty string array" unless valid_patterns
    end

    value.each_value { |child| walk.call(child) }
  when Array
    value.each { |child| walk.call(child) }
  end
end
walk.call(data)
RUBY

for file in data/faq-knowledge.md data/feature-registry.md data/platform-gaps.md; do
    rg -q '<!-- FORMAT SPEC' "$file" || fail "$file is missing FORMAT SPEC"
done

expected_header=$'date\tmode\tquery\treport_path\tsource_revision\trepositories\tstatus'
actual_header="$(head -n 1 data/research-history.tsv)"
[[ "$actual_header" == "$expected_header" ]] || fail "data/research-history.tsv has an invalid header"
awk -F '\t' 'NR > 1 && NF != 7 { exit 1 }' data/research-history.tsv \
    || fail "data/research-history.tsv contains a row with an invalid field count"
if rg -n $'\t|\r' data/faq-knowledge.md data/feature-registry.md data/platform-gaps.md >/dev/null; then
    fail "Markdown knowledge files must not contain tab or carriage-return fields"
fi

if rg -n '\{\{mode\}\}|^args:[[:space:]]*mode' .claude/skills/product-ops/SKILL.md; then
    fail "unsupported skill argument syntax remains in product-ops SKILL.md"
fi
if rg -n '^user_invocable:' .claude/skills/product-ops/SKILL.md .claude/skills/sync-repos/SKILL.md; then
    fail "skill frontmatter must use user-invocable"
fi
rg -q '^user-invocable:[[:space:]]*true' .claude/skills/product-ops/SKILL.md \
    || fail "product-ops skill must be user-invocable"
rg -q '^user-invocable:[[:space:]]*true' .claude/skills/sync-repos/SKILL.md \
    || fail "sync-repos skill must be user-invocable"
rg -q '^disable-model-invocation:[[:space:]]*true' .claude/skills/sync-repos/SKILL.md \
    || fail "sync-repos skill must require explicit invocation"
rg -q '\$ARGUMENTS' .claude/skills/product-ops/SKILL.md || fail "product-ops SKILL.md must consume \$ARGUMENTS"

bash tests/test-guard-repos.sh

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck .claude/hooks/guard-repos.sh scripts/validate-framework.sh tests/test-guard-repos.sh
else
    echo "validate-framework: warning: shellcheck is not installed; skipping shell lint" >&2
fi

if git diff --check >/dev/null 2>&1; then
    :
else
    fail "git diff --check failed"
fi

echo "validate-framework: ok"
