# Jira

Access Jira using the `jira` CLI command.

```bash
# View issue
jira issue view PROJ-123

# List issues assigned to me
jira issue list -a $(jira me)

# Create issue
jira issue create -p PROJ -t Task -s "Summary"
```
