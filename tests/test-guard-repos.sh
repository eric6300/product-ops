#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -P -- "$TEST_DIR/.." && pwd)"
HOOK="$ROOT_DIR/.claude/hooks/guard-repos.sh"

PYTHON_BIN=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 \
        && "$candidate" -c 'import sys; raise SystemExit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
        PYTHON_BIN="$(command -v "$candidate")"
        break
    fi
done
if [[ -z "$PYTHON_BIN" ]]; then
    echo "Python 3 is required for guard tests." >&2
    exit 2
fi

payload_for() {
    local command=$1
    local tool_name=${2:-Bash}
    local cwd=${3:-$ROOT_DIR}
    HOOK_COMMAND="$command" HOOK_TOOL="$tool_name" HOOK_CWD="$cwd" "$PYTHON_BIN" - <<'PY'
import json
import os

tool_name = os.environ["HOOK_TOOL"]
input_key = "script" if tool_name.lower() == "powershell" else "command"
print(json.dumps({
    "cwd": os.environ["HOOK_CWD"],
    "tool_name": tool_name,
    "tool_input": {input_key: os.environ["HOOK_COMMAND"]},
}))
PY
}

assert_allowed() {
    local command=$1
    local tool_name=${2:-Bash}
    local cwd=${3:-$ROOT_DIR}
    local output
    if ! output="$(payload_for "$command" "$tool_name" "$cwd" | "$HOOK" 2>&1)"; then
        echo "Expected allowed command but it was blocked: $command" >&2
        echo "$output" >&2
        exit 1
    fi
}

assert_blocked() {
    local command=$1
    local tool_name=${2:-Bash}
    local cwd=${3:-$ROOT_DIR}
    local output
    local status

    set +e
    output="$(payload_for "$command" "$tool_name" "$cwd" | "$HOOK" 2>&1)"
    status=$?
    set -e

    if [[ $status -ne 2 ]]; then
        echo "Expected command to be blocked with exit 2: $command" >&2
        echo "exit=$status output=$output" >&2
        exit 1
    fi
}

assert_allowed 'rg -n "TODO" repos/example'
assert_allowed 'git clone https://example.invalid/repo.git repos/example'
assert_allowed 'git -C "repos/example" status'
assert_allowed 'mkdir -p repos'
assert_allowed 'cat < repos/example/file.txt'
assert_allowed 'find repos/example -type f -maxdepth 2'
assert_allowed 'git diff --output=/tmp/product-ops.diff repos/example'
assert_allowed 'echo repos/example is a path'
assert_allowed 'Get-Content repos/example/file.txt' PowerShell
assert_allowed 'Set-Location repos/example; Get-Content file.txt' PowerShell

assert_blocked 'git -C "repos/example" add .'
assert_blocked 'git add "repos/example/file.txt"'
assert_blocked 'git diff --output="repos/example/diff.txt" repos/example'
assert_blocked 'cp /tmp/file "repos/example/file.txt"'
assert_blocked 'python3 -c "open(\"repos/example/file.txt\", \"w\").write(\"x\")"'
assert_blocked 'printf x > repos/example/file.txt'
assert_blocked 'cd repos/example && git commit -m test'
assert_blocked 'echo x > file.txt' Bash "$ROOT_DIR/repos/example"
assert_blocked 'bash -c "echo x > file.txt"' Bash "$ROOT_DIR/repos/example"
assert_blocked '. repos/example/modify.sh'
assert_blocked './modify-repo.sh repos/example/file.txt'
assert_blocked 'find repos/example -type f -delete'
assert_blocked 'Copy-Item "repos/example/file.txt" "repos/example/file-2.txt"' PowerShell
assert_blocked 'New-Item -ItemType File -Path "repos/example/file.txt"' PowerShell
assert_blocked 'git add .' Bash "$ROOT_DIR/repos/example"

echo "guard-repos tests: ok"
