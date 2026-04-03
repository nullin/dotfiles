---
name: reminders
description: Use when user says "/reminders", "show my reminders", "add a reminder", "complete a reminder", or wants to interact with Apple Reminders.
allowed-tools:
  - Bash(osascript:*)
---

# Apple Reminders

Manage Apple Reminders via `osascript -l JavaScript` (JXA). The MCP server (`mcp-server-apple-events`) is unreliable - use these commands directly.

$ARGUMENTS

## Quick Reference

| Operation | Command pattern |
|-----------|----------------|
| List all | `listReminders()` |
| List by list | `listReminders("Personal")` |
| Search | `searchReminders("keyword")` |
| Create | `createReminder("Title", {list, dueDate, note})` |
| Complete | `completeReminder("Title")` |
| Delete | `deleteReminder("Title")` - **confirm first** |
| Show lists | `listReminderLists()` |

Default list: "Reminders" when not specified.

## Tagging Convention

All reminders use `#hashtag` tags in the body field for grouping and search. Multiple tags are space-separated.

**Active tags:**

| Tag | Use for |
|-----|---------|
| `#cw-eng-cli` | cw CLI tool work |
| `#devex-docs` | Documentation sites and content |
| `#ci` | CI/CD pipelines and workflows |
| `#infra` | Infrastructure, ArgoCD, clusters |
| `#followup` | Pinging someone or waiting on feedback |
| `#pre-screen` | Candidate screening |
| `#personal` | Non-work items |
| `#planning` | OKRs, strategy, roadmap |
| `#tooling` | Developer tools and setup |
| `#gen-ci-workflow` | Generic CI workflow project |

**Auto-tagging rule:** When creating a reminder, YOU MUST infer appropriate tags from the reminder title and context. Do not ask the user which tags to apply - pick the best match(es) from the table above. Always set at least one tag in the body field. If no existing tag fits, create a new descriptive tag.

## Commands

### List reminders

Skips notes for speed. To get notes for a specific reminder, use search.

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const results = [];
for (const list of app.lists()) {
  for (const r of list.reminders.whose({completed: false})()) {
    let entry = r.name() + " | list:" + list.name();
    try { const d = r.dueDate(); if (d) entry += " | due:" + d.toISOString().split("T")[0]; } catch(e) {}
    results.push(entry);
  }
}
results.join("\n");
'
```

Filter by list:

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const list = app.lists.byName("LIST_NAME");
const results = [];
for (const r of list.reminders.whose({completed: false})()) {
  let entry = r.name();
  try { const d = r.dueDate(); if (d) entry += " | due:" + d.toISOString().split("T")[0]; } catch(e) {}
  results.push(entry);
}
results.join("\n");
'
```

### Search reminders

Uses `_contains` for fast server-side filtering by name:

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const results = [];
for (const list of app.lists()) {
  const matches = list.reminders.whose({completed: false, name: {_contains: "SEARCH_TERM"}})();
  for (const r of matches) {
    results.push(r.name() + " | list:" + list.name());
  }
}
results.join("\n");
'
```

### Create reminder

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const list = app.lists.byName("LIST_NAME");
const props = {name: "TITLE"};
// Tags go in body: props.body = "#tag1 #tag2";
// Optional due date: props.dueDate = new Date("YYYY-MM-DD");
const r = app.Reminder(props);
list.reminders.push(r);
"Created: " + r.name();
'
```

### Complete reminder

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
let found = false;
for (const list of app.lists()) {
  const matches = list.reminders.whose({name: "TITLE", completed: false})();
  if (matches.length > 0) {
    matches[0].completed = true;
    found = true;
    break;
  }
}
found ? "Completed" : "Not found";
'
```

### Delete reminder

**Always confirm with user before deleting.**

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
for (const list of app.lists()) {
  const matches = list.reminders.whose({name: "TITLE"})();
  if (matches.length > 0) {
    app.delete(matches[0]);
    "Deleted";
    break;
  }
}
'
```

### List reminder lists

```bash
osascript -l JavaScript -e '
const app = Application("Reminders");
const results = [];
for (const list of app.lists()) {
  const count = list.reminders.whose({completed: false})().length;
  results.push(list.name() + " (" + count + " incomplete)");
}
results.join("\n");
'
```

## Safety Rules

- Confirm before deleting reminders
- Confirm before bulk operations (completing or deleting multiple)
- When creating, default to "Reminders" list unless user specifies otherwise
- Match reminders by name case-sensitively for complete/delete operations

## Troubleshooting

If `osascript` returns permission errors, check **System Settings > Privacy & Security > Reminders** and ensure the terminal app has access.
