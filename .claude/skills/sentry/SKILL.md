---
name: sentry
allowed-tools: Bash(curl *), Read
description: Use when investigating production errors, analyzing error trends, triaging Sentry issues, querying Sentry API for error data and project health, or working with Sentry dashboards (viewing, creating, updating widgets, modifying filters). Also use when the user mentions a sentry.io URL, dashboard ID, or wants to filter/exclude users from Sentry data.
---

# Sentry

## Prerequisites

**Authentication:** Token stored in `~/.netrc`:

```
machine sentry.io
	password sntrys_YOUR_TOKEN_HERE
```

Create tokens at: https://sentry.io/settings/account/api/auth-tokens/

Required scopes: `event:read`, `event:write`, `event:admin` (delete), `project:read`, `org:read`

**Environment variables:**

- `SENTRY_ORG` (required) - organization slug from your Sentry URL
- `SENTRY_PROJECT` (optional, required for bulk operations) - project slug for project-level endpoints

**Auth pattern for curl commands:**

```bash
TOKEN=$(awk '/machine sentry.io/{found=1} found && /password/{print $2; exit}' ~/.netrc)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/?query=is:unresolved&sort=date&limit=25"
```

## Quick Reference

| Task | Command |
|------|---------|
| List unresolved issues | `GET /organizations/{org}/issues/?query=is:unresolved&sort=date` |
| Search issues | `GET /organizations/{org}/issues/?query={search_terms}` |
| Get issue detail | `GET /organizations/{org}/issues/{id}/` |
| Get latest event + stacktrace | `GET /organizations/{org}/issues/{id}/events/latest/?full=true` |
| Resolve issue | `PUT /organizations/{org}/issues/{id}/` with `{"status":"resolved"}` |
| Ignore issue | `PUT /organizations/{org}/issues/{id}/` with `{"status":"ignored"}` |
| Assign issue | `PUT /organizations/{org}/issues/{id}/` with `{"assignedTo":"user"}` |
| List projects | `GET /organizations/{org}/projects/` |
| Bulk resolve | `PUT /projects/{org}/{project}/issues/?id=X&id=Y` with `{"status":"resolved"}` |
| Get dashboard | `GET /organizations/{org}/dashboards/{dashboard_id}/` |
| Update dashboard | `PUT /organizations/{org}/dashboards/{dashboard_id}/` |
| List dashboards | `GET /organizations/{org}/dashboards/` |
| Discover span fields | `GET /organizations/{org}/spans/fields/?statsPeriod=7d` |
| Get field values | `GET /organizations/{org}/spans/fields/{field}/values/?statsPeriod=7d` |

All endpoints relative to `https://sentry.io/api/0`. See [sentry-api-reference.md](sentry-api-reference.md) for full endpoint parameters and response shapes.

## Workflows

### Investigate a Specific Error

1. Get issue details: `GET /organizations/{org}/issues/{id}/`
2. Get latest event with stacktrace: `GET /organizations/{org}/issues/{id}/events/latest/?full=true`
3. Parse the `entries` array for type `"exception"` to find the stacktrace
4. Check `tags` for environment, release, browser, OS context
5. Open the `permalink` in browser if deeper investigation is needed

### Search for Errors

- By text: `query=database connection timeout`
- By status: `query=is:unresolved`
- By assignment: `query=assigned:me`
- Combined: `query=is:unresolved assigned:me database`
- By time: `query=firstSeen:-2d`
- By frequency: `sort=freq`

### Monitor Error Trends

- Recent: `sort=date&limit=25`
- Most frequent: `sort=freq&limit=25`
- New errors: `sort=new&statsPeriod=24h`
- Most users affected: `sort=user&limit=25`

### Triage Issues

- Resolve: `{"status": "resolved"}`
- Resolve in next release: `{"status": "resolvedInNextRelease"}`
- Ignore: `{"status": "ignored"}`
- Ignore for duration: `{"status": "ignored", "statusDetails": {"ignoreDuration": 60}}`
- Assign: `{"assignedTo": "username"}` or `{"assignedTo": "team:team-slug"}`
- Mark seen: `{"hasSeen": true}`

### View and Update Dashboards

1. Extract dashboard ID from URL: `https://org.sentry.io/dashboard/413288` -> ID is `413288`
2. Extract org slug from URL: `https://coreweave.sentry.io/...` -> org is `coreweave`
3. Fetch dashboard: `GET /organizations/{org}/dashboards/{id}/`
4. The response contains a `widgets` array, each with `queries[].conditions` for filters
5. To update, PUT the full dashboard payload: `{"title": ..., "widgets": [...], "filters": {...}, "period": ...}`

**Updating widget filters:**

When modifying conditions on widgets, use Python to parse and rebuild the JSON payload.
Match widgets by `title` (not `id`) because widget IDs change on every PUT.

```python
import json, subprocess, os

token = os.environ["TOKEN"]

dashboard = json.loads(subprocess.check_output([
    "curl", "-s", "-H", f"Authorization: Bearer {token}",
    f"https://sentry.io/api/0/organizations/{{org}}/dashboards/{{id}}/"
]).decode())

for widget in dashboard["widgets"]:
    if widget["widgetType"] == "issue":
        continue  # issue widgets use different query syntax
    for query in widget["queries"]:
        cond = query["conditions"]
        # modify conditions as needed
        query["conditions"] = cond

payload = {
    "title": dashboard["title"],
    "widgets": dashboard["widgets"],
    "filters": dashboard["filters"],
    "period": dashboard["period"],
}

subprocess.check_output([
    "curl", "-s", "-X", "PUT",
    "-H", f"Authorization: Bearer {token}",
    "-H", "Content-Type: application/json",
    "-d", json.dumps(payload),
    f"https://sentry.io/api/0/organizations/{{org}}/dashboards/{{id}}/"
])
```

### Discover Span Fields and Values

Use the spans fields API to discover available fields and their actual values before writing filters:

1. List all fields: `GET /organizations/{org}/spans/fields/?statsPeriod=7d`
2. Get values for a field: `GET /organizations/{org}/spans/fields/{field}/values/?statsPeriod=7d`

The values endpoint returns objects with a `query` field showing the correct filter syntax. Use this to construct accurate filters rather than guessing.

Example: querying `user` field values returns entries like:
```json
{"name": "username:root", "value": "username:root", "query": "user.username:\"root\""}
```

The `query` field (`user.username:"root"`) is the correct filter syntax - use it directly.

### Bulk Operations

Use the project-level bulk endpoint with `id` query params:

```
PUT /projects/{org}/{project}/issues/?id=123&id=456
```

Same request body as single issue updates.

## Query Syntax Reference

| Filter | Example |
|--------|---------|
| Status | `is:unresolved`, `is:resolved`, `is:ignored` |
| Assignment | `assigned:me`, `assigned:#team-slug`, `!assigned:` |
| Time (first seen) | `firstSeen:-2d` (within 2 days), `firstSeen:+7d` (older than 7 days) |
| Time (last seen) | `lastSeen:-24h` (within 24 hours), `lastSeen:+30d` (older than 30 days) |
| Severity | `level:error`, `level:fatal`, `level:warning` |
| Event count | `timesSeen:>100` |
| Tags | `browser:Chrome`, `tag:custom-key:value` |
| Text | `connection timeout` (free text) |
| Wildcards | `message:"*Timeout*"` |
| Negation | `!browser:Chrome`, `!message:"*health*"` |
| Multiple values | `release:[1.0, 2.0]` |

## Span/Widget Query Syntax

Span-based widgets (type `spans`) use a different query syntax from issue widgets. The key differences:

### Field Names

The `user` field is a composite that stores values like `username:root`. For filtering, use the specific sub-field instead:

| Composite field | Sub-fields | Filter syntax |
|-----------------|------------|---------------|
| `user` | `user.username`, `user.email`, `user.id` | `user.username:"root"` |

**Do not** use the composite field with Contains for username filtering. Use the sub-field with exact match:
- Correct: `!user.username:"root"`
- Wrong: `!user:Containsusername:root`

### Contains Operator (Unicode Gotcha)

The `Contains` operator in Sentry's internal representation uses Unicode private-use character `\uf00d` as delimiters. What displays as `cli.name:Containscw` is actually stored as `cli.name:\uf00dContains\uf00dcw`.

When programmatically removing or replacing conditions that use `Contains`, match on the Unicode character:

```python
CONTAINS_MARKER = '\uf00d'
# Filter out parts containing the marker
parts = conditions.split()
filtered = [p for p in parts if f'{CONTAINS_MARKER}Contains{CONTAINS_MARKER}' not in p]
```

Plain string `.replace('Contains', ...)` will not match because the visible text differs from the stored bytes.

### Common Span Filters

| Filter | Example |
|--------|---------|
| Field contains value | `cli.name:Containscw` (displayed), uses `\uf00d` internally |
| Exact match | `user.username:"nmakar"` |
| Negation | `!user.username:"root"` |
| Not empty | `!user:""` |
| Wildcard | `component.name:*` |
| Transaction flag | `is_transaction:True` |

## Pagination

Sentry uses cursor-based pagination via the `Link` header. Default page size varies by endpoint - use `limit` to control (max 100). Always check the `Link` header for the next page cursor when processing large result sets.

## Common Mistakes

- **Wrong org slug:** Use the URL slug from sentry.io (e.g., `my-company`), not the display name (e.g., "My Company"). Extract from URL: `https://coreweave.sentry.io/...` means org is `coreweave`
- **Missing scopes:** 403 errors mean the token lacks required scopes - check token settings
- **Unencoded queries:** URL-encode the `query` parameter when it contains spaces or special characters
- **Forgetting pagination:** Large result sets are paginated - check the `Link` header for additional pages
- **Using deprecated endpoints:** Prefer `/organizations/{org}/issues/` over `/projects/{org}/{project}/issues/` for listing issues
- **Widget IDs change on PUT:** After updating a dashboard, all widget IDs are regenerated. Never cache or hardcode widget IDs - match widgets by `title` instead
- **Composite vs sub-fields:** The `user` field stores composite values like `username:root`. For filtering, use `user.username:"root"` not `user:Containsusername:root`. Always check the spans fields values endpoint to discover correct filter syntax
- **Unicode in Contains operator:** The `Contains` operator uses `\uf00d` (Unicode private-use character) as internal delimiters. Plain string operations like `.replace('Contains', ...)` silently fail. Use unicode-aware matching (see Span/Widget Query Syntax section)
- **SENTRY_ORG not set:** If `$SENTRY_ORG` is empty, API calls return 404. When working with dashboard URLs, extract the org directly from the URL rather than relying on the env var
- **Issue vs span widget types:** Issue widgets (`widgetType: "issue"`) use issue search syntax (`is:unresolved`). Span widgets (`widgetType: "spans"`) use span search syntax (`user.username:"root"`). Don't mix them
