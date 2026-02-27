---
name: sentry
description: Use when investigating production errors, analyzing error trends, triaging Sentry issues, or querying Sentry API for error data and project health.
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

## Pagination

Sentry uses cursor-based pagination via the `Link` header. Default page size varies by endpoint - use `limit` to control (max 100). Always check the `Link` header for the next page cursor when processing large result sets.

## Common Mistakes

- **Wrong org slug:** Use the URL slug from sentry.io (e.g., `my-company`), not the display name (e.g., "My Company")
- **Missing scopes:** 403 errors mean the token lacks required scopes - check token settings
- **Unencoded queries:** URL-encode the `query` parameter when it contains spaces or special characters
- **Forgetting pagination:** Large result sets are paginated - check the `Link` header for additional pages
- **Using deprecated endpoints:** Prefer `/organizations/{org}/issues/` over `/projects/{org}/{project}/issues/` for listing issues
