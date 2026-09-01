#!/bin/bash
# PreToolUse hook: keep cloned analysis repositories read-only.
# Synchronization commands such as git clone, fetch, pull and checkout remain allowed.

INPUT=$(cat)
export HOOK_INPUT="$INPUT"

python3 - <<'PY'
import json
import os
import re
import sys

try:
    command = (json.loads(os.environ.get("HOOK_INPUT", "{}")).get("tool_input") or {}).get("command") or ""
except Exception:
    sys.exit(0)

# Commands unrelated to the analysis directory are not restricted by this hook.
if "repos" not in command:
    sys.exit(0)

# Do not treat a quoted search term or commit message as a path reference.
stripped = re.sub(r"'[^']*'|\"[^\"]*\"", "", command)

git_write = re.compile(
    r"\bgit\b(?:\s+-\S+|\s+-C\s+\S+)*\s+"
    r"(add|commit|push|rebase|reset|merge|cherry-pick|stash|tag|apply|am|restore|revert|rm|mv|clean)\b"
)
fs_write = re.compile(r"\b(rm|mv|touch|mkdir|rmdir|tee|ln)\b|\bsed\s+(-\S*\s+)*-i")


def block():
    print(
        "repos/ contains read-only analysis mirrors. "
        "Only synchronization and read-only commands are allowed there.",
        file=sys.stderr,
    )
    sys.exit(2)


in_repos_dir = False
for segment in re.split(r"&&|\|\||;", stripped):
    if re.search(r"\bcd\s+\S*\brepos\b", segment):
        in_repos_dir = True
    targets_repos = bool(
        re.search(r"(^|[\s='\"(])\S*repos/", segment)
        or re.search(r"-C\s+\S*repos\b", segment)
    )
    if git_write.search(segment) and (in_repos_dir or targets_repos):
        block()
    if targets_repos and fs_write.search(segment):
        block()
    if re.search(r">>?\s*\S*repos/", segment):
        block()

sys.exit(0)
PY
