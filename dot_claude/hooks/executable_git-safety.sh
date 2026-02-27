#!/usr/bin/env bash
# Git safety hook: injects current branch context before dangerous git operations.
# Runs as a PreToolUse hook on Bash tool calls.

input=$(cat)

command=$(echo "$input" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

if echo "$command" | grep -qE 'git\s+(push|reset|rebase|merge|checkout|cherry-pick)\b'; then
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "[git-safety] Current branch: $branch"
    fi
fi

exit 0
