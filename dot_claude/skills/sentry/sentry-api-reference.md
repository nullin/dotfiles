# Sentry REST API Reference

Base URL: `https://sentry.io/api/0`

## Authentication

All requests require a Bearer token in the Authorization header:

    Authorization: Bearer {token}

Extract token from .netrc:

    TOKEN=$(awk '/machine sentry.io/{found=1} found && /password/{print $2; exit}' ~/.netrc)

Create tokens at: https://sentry.io/settings/account/api/auth-tokens/

Required scopes: `event:read`, `event:write`, `event:admin` (for delete operations), `project:read`, `org:read`

Set your org slug:

    SENTRY_ORG="your-org-slug"

## Variables

Examples in this reference use these shell variables:

- `$TOKEN` - extracted from .netrc (see Authentication above)
- `$SENTRY_ORG` - organization slug from your Sentry URL
- `$SENTRY_PROJECT` - project slug (needed for project-level endpoints like bulk mutate)
- `$ISSUE_ID` - numeric issue ID (from issue list responses, `id` field)
- `$EVENT_ID` - event ID (from event list responses, `eventID` field)

---

## Issues

### List Organization Issues (preferred)

    GET /organizations/{org}/issues/

Query parameters:

| Parameter     | Type   | Description                                                        |
|---------------|--------|--------------------------------------------------------------------|
| query         | string | Search query (see Search Query Syntax below)                       |
| sort          | string | Sort order: `date`, `new`, `freq`, `user`, `trends`               |
| statsPeriod   | string | Relative time period for stats: `24h`, `14d`, etc.                 |
| project       | int    | Project ID to filter by (repeat for multiple)                      |
| environment   | string | Environment name to filter by (repeat for multiple)                |
| limit         | int    | Number of results per page (max 100, default 25)                   |
| cursor        | string | Pagination cursor from Link header                                 |
| start         | string | Absolute start date: ISO 8601 format                              |
| end           | string | Absolute end date: ISO 8601 format                                |

Example:

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/?query=is:unresolved&sort=date&limit=25"

### List Project Issues (deprecated)

    GET /projects/{org}/{project}/issues/

Deprecated in favor of the organization-level endpoint above. Same query parameters apply.

### Retrieve an Issue

    GET /organizations/{org}/issues/{issue_id}/

Returns full issue details including stats, tags, and metadata.

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/"

### Update an Issue

    PUT /organizations/{org}/issues/{issue_id}/

Request body (JSON):

| Field         | Type   | Values / Description                                               |
|---------------|--------|--------------------------------------------------------------------|
| status        | string | `resolved`, `resolvedInNextRelease`, `unresolved`, `ignored`       |
| statusDetails | object | Additional status context, e.g. `{"ignoreCount": 100}`            |
| assignedTo    | string | User or team: `"username"` or `"team:team-slug"`                   |
| hasSeen       | bool   | Mark as seen/unseen                                                |
| isBookmarked  | bool   | Bookmark the issue                                                 |

Example - resolve an issue:

    curl -s -X PUT -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"status": "resolved"}' \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/"

Example - assign to a user:

    curl -s -X PUT -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"assignedTo": "jane.doe"}' \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/"

### Delete an Issue

    DELETE /organizations/{org}/issues/{issue_id}/

Requires `event:admin` scope. Returns 202 on success. The issue is scheduled for deletion asynchronously.

    curl -s -X DELETE -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/"

### Bulk Mutate Issues

    PUT /projects/{org}/{project}/issues/?id={issue_id}&id={issue_id}

This is the project-level endpoint (no organization-level equivalent exists). Apply the same update to multiple issues at once. Pass issue IDs as repeated `id` query parameters. Request body is the same as Update an Issue.

Example - resolve multiple issues:

    curl -s -X PUT -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"status": "resolved"}' \
      "https://sentry.io/api/0/projects/$SENTRY_ORG/$SENTRY_PROJECT/issues/?id=123&id=456&id=789"

---

## Events

### List Issue Events

    GET /organizations/{org}/issues/{issue_id}/events/

Query parameters:

| Parameter     | Type   | Description                                                        |
|---------------|--------|--------------------------------------------------------------------|
| full          | bool   | Include full event body with entries (exception, stacktrace, etc.) |
| statsPeriod   | string | Relative time period: `24h`, `14d`, etc.                           |
| start         | string | Absolute start date: ISO 8601 format                              |
| end           | string | Absolute end date: ISO 8601 format                                |
| environment   | string | Environment name to filter by                                      |
| query         | string | Search query to filter events                                      |

Example - list events with full stacktraces:

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/events/?full=true"

### Retrieve Latest Event for an Issue

    GET /organizations/{org}/issues/{issue_id}/events/latest/

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/events/latest/"

Note: The `{event_id}` in the path accepts special values: `latest`, `oldest`, `recommended`.

### Retrieve a Specific Event

    GET /organizations/{org}/issues/{issue_id}/events/{event_id}/

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/events/$EVENT_ID/"

### List Tag Values for an Issue

    GET /organizations/{org}/issues/{issue_id}/tags/{tag_key}/values/

Returns all observed values for a specific tag on an issue. Common tag keys: `browser`, `os`, `device`, `environment`, `release`, `server_name`, `url`.

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/$ISSUE_ID/tags/browser/values/"

---

## Projects

### List Organization Projects

    GET /organizations/{org}/projects/

Returns all projects the token has access to within the organization.

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/projects/"

### Get Project Details

    GET /projects/{org}/{project_slug}/

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/projects/$SENTRY_ORG/$SENTRY_PROJECT/"

---

## Organizations

### Get Organization Details

    GET /organizations/{org}/

Returns organization settings, quotas, and metadata.

    curl -s -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/"

---

## Search Query Syntax

Used in the `query` parameter for issue list endpoints.

### Status Filters

| Filter            | Description                      |
|-------------------|----------------------------------|
| `is:unresolved`   | Open issues (default)            |
| `is:resolved`     | Resolved issues                  |
| `is:ignored`      | Ignored/snoozed issues           |

### Assignment Filters

| Filter                | Description                          |
|-----------------------|--------------------------------------|
| `assigned:me`         | Assigned to the token owner          |
| `assigned:#team-slug` | Assigned to a team                   |
| `assigned:jane.doe`   | Assigned to a specific user          |
| `!assigned:me`        | Not assigned to the token owner      |

### Time Filters (firstSeen, lastSeen)

| Filter                      | Description                              |
|-----------------------------|------------------------------------------|
| `firstSeen:-24h`            | First seen in the last 24 hours          |
| `lastSeen:-7d`              | Last seen in the last 7 days             |
| `firstSeen:+2025-01-01`     | First seen after a specific date         |

Time units: `m` (minutes), `h` (hours), `d` (days), `w` (weeks).

### Severity

- `level:error` - error-level issues
- `level:fatal` - fatal-level issues
- `level:warning` - warning-level issues
- `level:info` - info-level issues

### Event Count (timesSeen)

| Filter              | Description                        |
|---------------------|------------------------------------|
| `timesSeen:>100`    | Seen more than 100 times           |
| `timesSeen:>=10`    | Seen 10 or more times              |

### Text Search

| Pattern             | Description                        |
|---------------------|------------------------------------|
| `TypeError`         | Match text in issue title/message  |
| `Type*`             | Wildcard matching                  |

### Negation

Prefix any filter with `!` to negate it:

    !is:resolved
    !assigned:me

### Multiple Values

Use `OR` between values in brackets:

    is:unresolved assigned:[me, #backend-team]

### Tag Filters

Filter by custom or built-in tags:

    browser:Chrome
    os:Windows
    release:1.2.3
    server_name:web-01

---

## Pagination

Sentry uses cursor-based pagination via the `Link` response header.

The Link header contains `rel="previous"` and `rel="next"` entries with `results="true"` or `results="false"` indicating whether more pages exist in that direction.

Example Link header:

    Link: <https://sentry.io/api/0/organizations/my-org/issues/?cursor=1234:0:1>; rel="previous"; results="false",
          <https://sentry.io/api/0/organizations/my-org/issues/?cursor=5678:0:0>; rel="next"; results="true"

To detect more pages, check for `rel="next"; results="true"` in the Link header.

Extracting the next cursor with curl:

    curl -sI -H "Authorization: Bearer $TOKEN" \
      "https://sentry.io/api/0/organizations/$SENTRY_ORG/issues/?query=is:unresolved&limit=25" \
      | grep -i '^link:' \
      | grep -o 'cursor=[^>]*' \
      | tail -1

---

## Response Shapes

### Issue Object (key fields)

| Field            | Type   | Description                                        |
|------------------|--------|----------------------------------------------------|
| id               | string | Issue ID (numeric string)                          |
| shortId          | string | Short identifier, e.g. `PROJECT-1A2B`              |
| title            | string | Issue title / error message                        |
| culprit          | string | Function or module where the error originated      |
| status           | string | `resolved`, `unresolved`, `ignored`                |
| level            | string | Severity: `fatal`, `error`, `warning`, `info`      |
| count            | string | Total event count                                  |
| userCount        | int    | Number of affected users                           |
| firstSeen        | string | ISO 8601 timestamp of first occurrence             |
| lastSeen         | string | ISO 8601 timestamp of most recent occurrence       |
| assignedTo       | object | Assigned user or team (or null)                    |
| project          | object | Project `{id, name, slug}`                         |
| permalink        | string | URL to issue in Sentry UI                          |
| metadata         | object | Additional context: `{type, value, filename}`      |

### Event Object (key fields)

| Field            | Type   | Description                                        |
|------------------|--------|----------------------------------------------------|
| eventID          | string | Unique event identifier                            |
| id               | string | Event ID                                           |
| dateCreated      | string | ISO 8601 timestamp                                 |
| message          | string | Event message                                      |
| title            | string | Event title                                        |
| platform         | string | Platform: `python`, `javascript`, etc.             |
| tags             | array  | Array of `{key, value}` pairs                      |
| context          | object | Additional context data                            |
| entries          | array  | Event data entries (see below)                     |
| user             | object | Affected user: `{id, email, ip_address}`           |

The `entries` array contains structured event data. Each entry has a `type` field:

| Entry type    | Description                                           |
|---------------|-------------------------------------------------------|
| exception     | Exception chain with stacktrace frames                |
| breadcrumbs   | Trail of events leading to the error                  |
| request       | HTTP request details (url, method, headers, data)     |
| message       | Formatted log message                                 |

Exception entries contain `data.values[]`, each with `type`, `value`, and `stacktrace.frames[]` where frames include `filename`, `function`, `lineNo`, `colNo`, `context`, and `absPath`.
