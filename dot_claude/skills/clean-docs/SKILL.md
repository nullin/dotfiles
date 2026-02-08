<!-- Install: copy to .claude/commands/ in your project, then run with /clean-docs -->
---
description: Review, reorganize, and commit documentation improvements
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
2. Use the **Task tool** with `subagent_type: "general-purpose"` and `model: "opus"` to run the cleanup
3. Wait for the subagent to complete before starting the next iteration
4. Log the summary of changes from each iteration

**Important: Do NOT pass any context from previous iterations to subsequent ones.** Each subagent should receive only the static prompt below - no summaries, no hints about what changed, no cumulative context. This ensures each iteration approaches the documentation with fresh eyes and may catch issues that a biased reviewer would skip.

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
