# CLAUDE.md Maintenance

## Rule

When working in any repository that contains a CLAUDE.md file, check whether your completed work warrants an update to CLAUDE.md before finishing.

## When to Update

Only update CLAUDE.md when there is high confidence the change is needed:

- New command or package added that future agents need to know about
- Existing documented behavior changed in a way that would mislead agents
- Build/test commands changed
- Conventions established or modified that affect how agents should work in the repo

## When NOT to Update

- Minor refactors that don't change architecture or conventions
- Bug fixes within existing patterns
- Changes already covered by existing CLAUDE.md content
- Speculative additions ("might be useful to document")

## Style

CLAUDE.md is for agents, not humans. Keep entries:

- Terse - minimum words to convey the point
- Actionable - tells an agent what to do or avoid
- Flat - avoid deep nesting or verbose explanations
- Consistent - match the existing format and tone of the file
