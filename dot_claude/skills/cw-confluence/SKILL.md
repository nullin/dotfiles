---
name: confluence
description: CoreWeave Confluence API operations for reading, creating, updating, and managing wiki pages
---

# Confluence API

## When to Use

- Reading or updating Confluence pages
- Creating documentation pages
- Managing attachments
- Searching for pages in the Network Datapath space

## Prerequisites

Uses the same API token as Jira CLI (stored in `~/.netrc`).

## Command Formatting

When using curl with JSON bodies, put the entire command on a single line to avoid permission issues:

```bash
# CORRECT: Single line
curl -s -X POST "..." --netrc -H "Content-Type: application/json" -d '{"key": "value"}'

# WRONG: Newlines in JSON may trigger issues
curl -s -X POST "..." --netrc -H "Content-Type: application/json" -d '{
  "key": "value"
}'
```

## Confirmation Requirements

**IMPORTANT: All write operations to Confluence require explicit user confirmation.**

Before executing any of these operations, you must:
1. Show the user exactly what will be created/modified/deleted
2. Include the page title, content summary, and target space
3. Wait for explicit approval ("yes", "go ahead", "create it", etc.)
4. Only execute after receiving approval

Write operations include:
- Creating pages (POST to /wiki/api/v2/pages)
- Updating pages (PUT to /wiki/api/v2/pages)
- Deleting pages (DELETE to /wiki/api/v2/pages)
- Uploading attachments (POST to /wiki/rest/api/content/.../attachment)

Read operations (GET requests) do not require confirmation.

## Spaces

```bash
# List all spaces
curl -s "https://coreweave.atlassian.net/wiki/api/v2/spaces" --netrc | jq '.results[] | {id, key, name}'

# Get space by key (returns numeric ID needed for other calls)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/spaces?keys=NTWRKDP" --netrc | jq '.results[0] | {id, key, name, homepageId}'
```

## Pages

```bash
# List pages in space (use numeric space ID)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/spaces/321880319/pages?limit=50" --netrc | jq '.results[] | {id, title}'

# Read page content
curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>?body-format=storage" --netrc | jq '{title, body: .body.storage.value}'

# Search pages by title (exact match)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages?title=<title>&space-id=321880319" --netrc | jq '.results[] | {id, title}'

# Search pages by title pattern (partial match)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages?title=migration&space-id=321880319" --netrc | jq '.results[] | {id, title}'

# Get page children (child pages)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>/children" --netrc | jq '.results[] | {id, title}'
```

## Update Page

**Confirmation required** - see Confirmation Requirements above.

```bash
# Get current version first
VERSION=$(curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>" --netrc | jq '.version.number')

# Update page content
curl -s -X PUT "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>" --netrc -H "Content-Type: application/json" -d '{"id": "<page-id>", "status": "current", "title": "Page Title", "body": {"representation": "storage", "value": "<p>New content</p>"}, "version": {"number": '$((VERSION + 1))'}}'
```

## Create Page

**Confirmation required** - see Confirmation Requirements above.

```bash
curl -s -X POST "https://coreweave.atlassian.net/wiki/api/v2/pages" --netrc -H "Content-Type: application/json" -d '{"spaceId": "321880319", "status": "current", "title": "New Page Title", "parentId": "<parent-page-id>", "body": {"representation": "storage", "value": "<p>Page content</p>"}}'
```

## Delete Page

**Confirmation required** - see Confirmation Requirements above.

```bash
# Move page to trash
curl -s -X DELETE "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>" --netrc

# Verify page status (will show "trashed")
curl -s "https://coreweave.atlassian.net/wiki/api/v2/pages/<page-id>" --netrc | jq '.status'
```

## Attachments

Attachments must be uploaded using the REST API v1 (v2 doesn't support attachments yet).

**Confirmation required for uploads** - see Confirmation Requirements above.

```bash
# Upload attachment to a page
curl -s -X POST "https://coreweave.atlassian.net/wiki/rest/api/content/<page-id>/child/attachment" --netrc -H "X-Atlassian-Token: nocheck" -F "file=@/path/to/file.md" | jq '.results[0] | {id, title, fileSize: .extensions.fileSize}'

# List attachments on a page
curl -s "https://coreweave.atlassian.net/wiki/rest/api/content/<page-id>/child/attachment" --netrc | jq '.results[] | {id, title, downloadLink: ._links.download}'

# Update/replace an attachment (upload with same filename)
curl -s -X POST "https://coreweave.atlassian.net/wiki/rest/api/content/<page-id>/child/attachment" --netrc -H "X-Atlassian-Token: nocheck" -F "file=@/path/to/file.md"
```

**Link to attachments inline in page content:**

Attachments linked inline appear as clickable links in the page content (not at the bottom).

```html
<!-- Link to an attachment -->
<p><ac:link><ri:attachment ri:filename="myfile.md" /></ac:link></p>

<!-- Link with custom text -->
<p>Download the <ac:link><ri:attachment ri:filename="config.json" /><ac:plain-text-link-body><![CDATA[configuration file]]></ac:plain-text-link-body></ac:link></p>

<!-- List of attachment links -->
<ul>
<li><ac:link><ri:attachment ri:filename="file1.md" /></ac:link> - Description</li>
<li><ac:link><ri:attachment ri:filename="file2.md" /></ac:link> - Description</li>
</ul>
```

## Common Space IDs

| Space | Key | ID |
|-------|-----|-----|
| Network Datapath | NTWRKDP | 321880319 |

## Body Formats

- `storage` - Confluence storage format (HTML-like)
- `atlas_doc_format` - Atlassian Document Format (JSON)
- `view` - Rendered HTML (read-only)

## Pagination

Most list endpoints support `limit` and `cursor` parameters:

```bash
# First page
curl -s "https://coreweave.atlassian.net/wiki/api/v2/spaces/321880319/pages?limit=25" --netrc | jq '{results: .results, next: ._links.next}'

# Next page (use cursor from previous response)
curl -s "https://coreweave.atlassian.net/wiki/api/v2/spaces/321880319/pages?limit=25&cursor=<cursor>" --netrc
```

## Common HTML Storage Patterns

```html
<!-- Headings -->
<h1>Title</h1>
<h2>Subtitle</h2>

<!-- Lists -->
<ul><li>Item 1</li><li>Item 2</li></ul>
<ol><li>First</li><li>Second</li></ol>

<!-- Code blocks -->
<ac:structured-macro ac:name="code"><ac:plain-text-body><![CDATA[code here]]></ac:plain-text-body></ac:structured-macro>

<!-- Links -->
<a href="https://example.com">Link text</a>

<!-- Tables -->
<table><tbody><tr><th>Header</th></tr><tr><td>Data</td></tr></tbody></table>
```

## Error Checking

```bash
# Check if operation succeeded
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://coreweave.atlassian.net/wiki/api/v2/pages" --netrc -H "Content-Type: application/json" -d '...')
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
  echo "Success: $BODY"
else
  echo "Failed with code $HTTP_CODE: $BODY"
fi
```

## Reference

- [Confluence REST API v2 docs](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/)
