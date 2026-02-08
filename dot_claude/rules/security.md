# Security Standards

## Pre-Commit Checklist

Before committing code:

- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] Input validation at all system boundaries
- [ ] Authentication and authorization checks on protected endpoints
- [ ] Parameterized SQL queries (never string interpolation)
- [ ] No user input in `eval()`, `exec()`, or shell commands
- [ ] Error messages don't leak sensitive information
- [ ] Dependencies up-to-date (`npm audit`, `pip-audit`, `gosec`)

## Project Tools

- **Pre-commit:** `detect-secrets` for secret scanning
- **Security headers:** CSP, HSTS, X-Content-Type-Options
- **Rate limiting:** On auth endpoints to prevent brute force

## If Secret Leaked

1. **Rotate immediately** - Generate new secret first
2. **Remove from git history** - Use `git-filter-repo` or BFG
3. **Audit for exploitation** - Check logs for unauthorized use

## Never Log Sensitive Data

```python
# BAD - Don't do this!
logger.info(f"User password: {password}")
logger.info(f"Credit card: {credit_card}")
logger.info(f"API key: {api_key}")

# Good - Log safely
logger.info(f"User authenticated: {user_id}")
logger.info(f"Payment processed: {payment_id}")
```

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)

Use `/security-checklist` skill for detailed OWASP Top 10 guidance and examples.

See [grug-brain.md](grug-brain.md) - simplicity helps security.
