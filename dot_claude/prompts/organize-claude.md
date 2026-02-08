# Organize Claude Configuration

## Usage

```text
/ralph-loop:ralph-loop "@.claude/prompts/organize-claude.md After each iteration, notify me on Slack." --completion-promise "ORGANIZED" --max-iterations 10
```

Reorganize CLAUDE.md and the contents of this project's `.claude/` directory.

## Goals

- Move content from CLAUDE.md into organized files within `.claude/`
- Keep CLAUDE.md focused on essential quick-start information
- Use your judgement to determine if content should be a skill or rule:
  - **Skills**: Step-by-step procedures, workflows, troubleshooting guides
  - **Rules**: Conventions, policies, constraints, best practices

## Guidelines

- Review current CLAUDE.md sections and `.claude/` structure
- Identify content that would be better as a standalone skill or rule
- Ensure no duplication between CLAUDE.md and `.claude/` files
- Maintain clear references in CLAUDE.md to moved content
- **Commit after each change**: After making changes, commit them (but do not push)

## Completion

Only emit the completion promise if you made **no changes** during this iteration. If you made any changes (edits, new files, commits), continue to the next iteration to check for more improvements.

If you reviewed everything and found nothing to change, emit:

<promise>ORGANIZED</promise>
