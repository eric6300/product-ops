#!/usr/bin/env bash
# PreToolUse hook: keep cloned analysis repositories read-only.
#
# Synchronization commands (git clone/fetch/checkout/pull/status/log/diff) are
# allowed. Other commands that target repos/ are rejected conservatively. This
# is a guardrail, not a substitute for OS-level permissions or review.

set -euo pipefail

INPUT="$(cat)"
export HOOK_INPUT="$INPUT"

PYTHON_BIN=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 \
        && "$candidate" -c 'import sys; raise SystemExit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
        PYTHON_BIN="$(command -v "$candidate")"
        break
    fi
done
if [[ -z "$PYTHON_BIN" ]]; then
    echo "Cannot enforce repos/ read-only protection: Python 3 is required." >&2
    exit 2
fi

exec "$PYTHON_BIN" - <<'PY'
import json
import os
import re
import shlex
import sys


def block(reason):
    print(f"Blocked repos/ write: {reason}", file=sys.stderr)
    sys.exit(2)


try:
    payload = json.loads(os.environ.get("HOOK_INPUT", "{}"))
except json.JSONDecodeError:
    block("the hook received invalid tool input")
if not isinstance(payload, dict):
    block("the hook received an invalid tool-input object")

tool_input = payload.get("tool_input") or {}
if not isinstance(tool_input, dict):
    block("the hook received an invalid tool_input value")
command = tool_input.get("command") or tool_input.get("script") or ""
if not isinstance(command, str):
    block("the hook received a non-string command")
if not command:
    sys.exit(0)

# Keep quoted paths intact. Removing quoted strings makes paths such as
# `git add "repos/example/file"` invisible to the guard.
repo_path = re.compile(
    r'''(?:^|[\s'"`=:(])(?:[A-Za-z]:[\\/]|/|\./|\.\./)?'''
    r'''(?:[^;&|()\s'"`]+[\\/])*repos(?:[\\/]|$)''',
    re.IGNORECASE,
)

write_commands = {
    "rm", "mv", "cp", "install", "touch", "mkdir", "md", "rmdir", "tee",
    "ln", "chmod", "chown", "chgrp", "truncate", "dd", "shred", "setfacl",
    "sed", "awk", "perl", "ruby", "php", "node", "nodejs", "deno", "bun",
    "python", "python3", "pwsh", "powershell", "cmd", "sh", "bash", "zsh",
    "dash", "ksh", "fish", "copy-item", "set-content",
    "out-file", "new-item", "remove-item", "move-item", "rename-item",
    "add-content", "clear-content", "invoke-webrequest", "start-bitstransfer",
    "xargs", "rsync", "tar", "unzip", "7z",
}

git_write_subcommands = {
    "add", "commit", "push", "rebase", "reset", "merge", "cherry-pick",
    "stash", "tag", "apply", "am", "restore", "revert", "rm", "mv", "clean",
    "switch", "update-index", "update-ref", "worktree", "config", "remote",
    "submodule", "notes", "filter-branch",
}

prefix_commands = {"sudo", "command", "env"}
path_option_values = {"-path", "-literalpath", "-name"}
ignored_option_values = {"-itemtype"}
git_read_subcommands = {
    "blame", "branch", "cat-file", "checkout", "clone", "describe", "diff",
    "fetch", "grep", "log", "ls-files", "ls-tree", "pull", "rev-parse",
    "show", "status",
}
neutral_commands = {
    ":", "cat", "cd", "command", "cut", "diff", "du", "echo", "fd",
    "file", "get-childitem", "get-content", "get-item", "get-location", "grep",
    "head", "less", "ls", "measure-object", "more", "popd", "pop-location",
    "printf", "push-location", "pwd", "resolve-path", "rg", "select-string",
    "set-location", "sort", "sort-object", "stat", "tail", "test-path", "tree",
    "type", "uniq", "wc", "where-object", "write-host", "write-output",
}


def tokens_for(segment):
    try:
        return shlex.split(segment, posix=True)
    except ValueError:
        # An unfinished quote is unsafe to classify; retain conservative
        # tokenization so a write command is still rejected.
        return re.findall(r"[^\s]+", segment)


def effective_command(tokens):
    index = 0
    while index < len(tokens) and tokens[index].lower() in prefix_commands:
        index += 1
    while index < len(tokens) and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", tokens[index]):
        index += 1
    if index >= len(tokens):
        return ""
    return os.path.basename(tokens[index]).lower()


def is_repo_root_create(tokens, command_name):
    if command_name not in {"mkdir", "md", "new-item"}:
        return False

    operands = []
    skip_next = False
    collect_next = False
    for token in tokens[1:]:
        lower = token.lower()
        if skip_next:
            if collect_next:
                operands.append(token)
            skip_next = False
            collect_next = False
        elif lower in path_option_values:
            skip_next = True
            collect_next = True
        elif lower in ignored_option_values:
            skip_next = True
            collect_next = False
        elif lower in {"-p", "--parents", "-force", "-itemtype", "directory"}:
            continue
        elif token.startswith("-"):
            continue
        else:
            operands.append(token)

    normalized = [item.replace("\\", "/").rstrip("/") for item in operands]
    return normalized in (["repos"], ["./repos"])


def is_write_command(tokens, command_name):
    if command_name in write_commands:
        if command_name == "sed":
            return any(token == "-i" or token.startswith("-i") for token in tokens[1:])
        if command_name == "awk":
            return any(token in {"-i", "inplace"} or "inplace" in token for token in tokens[1:])
        if command_name == "perl":
            return any("i" in token.lstrip("-") for token in tokens[1:] if token.startswith("-"))
        # Creating the top-level repos/ directory is required by sync-repos.
        return not is_repo_root_create(tokens, command_name)

    if command_name in {"git", "git.exe"}:
        lowered = [token.lower() for token in tokens[1:]]
        if any(token in git_write_subcommands for token in lowered):
            return True
        return not any(token in git_read_subcommands for token in lowered)

    if command_name == "find":
        return any(token.lower() in {"-delete", "-exec", "-execdir", "-ok", "-okdir"}
                   for token in tokens[1:])

    return False


def git_output_targets_repo(tokens, in_repos_dir):
    for index, token in enumerate(tokens[1:], start=1):
        target = None
        if token.startswith("--output="):
            target = token.split("=", 1)[1]
        elif token in {"--output", "-o"} and index + 1 < len(tokens):
            target = tokens[index + 1]
        if not target or target == "-":
            continue
        target_is_absolute = bool(re.match(r"^(?:/|[A-Za-z]:[\\/])", target))
        if repo_path.search(target) or (in_repos_dir and not target_is_absolute):
            return True
    return False


# `cwd` is part of Claude Code hook input. It catches `git add .` when the
# command is executed with a repository mirror as its working directory.
cwd = payload.get("cwd") or ""
if not isinstance(cwd, str):
    cwd = ""
in_repos_dir = bool(repo_path.search(cwd))

for segment in re.split(r"&&|\|\||;|\n", command):
    tokens = tokens_for(segment)
    command_name = effective_command(tokens)
    if not command_name:
        continue

    if re.search(r"\b(?:cd|set-location|push-location)\s+", segment, re.IGNORECASE) \
            and repo_path.search(segment):
        in_repos_dir = True

    targets_repos = in_repos_dir or bool(repo_path.search(segment))
    if not targets_repos:
        continue

    if is_write_command(tokens, command_name):
        block(f"{command_name} is not allowed in an analysis mirror")

    if command_name in {"git", "git.exe"} and git_output_targets_repo(tokens, in_repos_dir):
        block("git output to a repository path is not allowed")

    if command_name not in write_commands and command_name not in neutral_commands \
            and command_name not in {"find", "git", "git.exe"}:
        block(f"unrecognized command {command_name} is not allowed near an analysis mirror")

    # Block shell output redirection to a repo path. Input redirection (`<`)
    # remains available for read-only analysis.
    output_redirect = re.search(
        r'''(?:^|[\s])(?:\d+)?(?:>>?|>\|)\s*["']?([^;&|()\s'"`]+)''',
        segment,
        re.IGNORECASE,
    )
    if output_redirect:
        target = output_redirect.group(1)
        target_is_absolute = bool(re.match(r"^(?:/|[A-Za-z]:[\\/])", target))
        if repo_path.search(target) or (in_repos_dir and not target_is_absolute and target != "-"):
            block("shell redirection to a repository path is not allowed")

sys.exit(0)
PY
