---
name: clean-docs
description: Use when cleaning up or reorganizing a project's docs (README, CLAUDE.md, SECURITY.md). Triggers on "/clean-docs", "clean up the docs", "reorganize documentation".
allowed-tools:
  - Task
arguments:
  - name: iterations
    description: Number of cleanup iterations to run
    default: "2"
---

# Documentation Cleanup

Run the documentation cleanup process **$ARGUMENTS.iterations times sequentially** using subagents.

## Execution

For each iteration (1 through $ARGUMENTS.iterations):

1. Log: "Starting documentation cleanup iteration N of $ARGUMENTS.iterations"
2. Spawn a fresh subagent for the iteration with the **Task tool** (`subagent_type: "general-purpose"`, `model: "opus"`) and the static prompt below. Run the review through the subagent, not inline - a separate context is what gives each pass fresh eyes.
3. Wait for the subagent to complete before starting the next iteration
4. Log the summary of changes from each iteration

Give each subagent only the static prompt below - no summaries, no hints about what changed, no cumulative context from earlier iterations. A clean context is what lets each pass review with fresh eyes and catch issues a primed reviewer would skip.

## Subagent Prompt

Use this prompt for each Task subagent:

```text
Review, reorganize, and commit improvements to the critical documentation files:

1. README.md - Quick start guide and user documentation
2. CLAUDE.md - AI assistant instructions and project guidance
3. docs/SECURITY.md - Security architecture and threat model

## Phase 1: Analysis

Read each file completely. Identify:
- Duplicate content across files
- Inconsistencies between docs
- Misplaced content that belongs elsewhere
- Missing cross-references
- Organizational issues

Document purposes:
- README.md: First contact for new users - concise, getting started focus
- CLAUDE.md: AI assistant context - what an AI needs to work on this codebase
- docs/SECURITY.md: Comprehensive security reference

## Phase 2: Apply Changes

Apply all improvements directly:
- Remove duplicate content (keep in most appropriate file)
- Move misplaced content to proper documents
- Fix inconsistencies
- Add cross-references between documents
- Improve section organization

## Phase 3: Commit

1. Stage all modified documentation files
2. Create a commit with a clear message summarizing changes
3. DO NOT push - leave changes local

## Guidelines

- Be conservative: only make clear improvements
- Preserve all essential information
- Maintain consistent formatting
- Ensure all internal links remain valid
```

## After All Iterations

Summarize the total changes made across all iterations.
