# Code Review Quick Reference

## Choose the Right Tool

| Situation | Tool |
|-----------|------|
| Uncommitted changes | `/diff-review` (auto) or `/diff-review-user` (interactive) |
| Branch vs main | `/branch-review` (auto) or `/branch-review-user` (interactive) |
| GitHub PR | `/review-pr <number>` |
| Simplicity check | `/grug-review` |
| Security audit | `critical-code-reviewer` agent |
| CI failure | `/autofix-ci` |

## Interactive vs Non-Interactive

**Use `-user` (interactive) when:**
- Want to approve each fix individually
- Code is in active development or high-risk
- Learning from the review
- Working on shared branches

**Use non-interactive when:**
- Trust automatic fixes
- Review is routine or standard
- Time is limited, changes are low-risk
- Solo work on isolated branch

## Common Workflows

**Before committing:**
```bash
/diff-review          # Quick check
/grug-review          # Check complexity
git add . && /commit
```

**Before PR:**
```bash
/branch-review   # Review all changes
/grug-review     # Simplicity check
```

**Reviewing teammate's PR:**
```bash
/review-pr 123   # Create GitHub review
```

## Related

- [grug-brain.md](grug-brain.md) - Simplicity philosophy underlying reviews
- [comments.md](comments.md) - What makes a good code comment
- [security.md](security.md) - Security review checklist
- [testing.md](testing.md) - Test coverage philosophy
