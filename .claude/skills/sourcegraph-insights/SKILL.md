---
name: sourcegraph-insights
allowed-tools: Bash(curl *), Read
description: Use when managing Sourcegraph Code Insights dashboards and insight views via the GraphQL API. Triggers on "sourcegraph dashboard", "sourcegraph insight", "code insight", "insight view", or when the user shares a coreweave.sourcegraphcloud.com/insights URL.
---

# Sourcegraph Code Insights API

## Prerequisites

**Authentication:** Token stored in `~/.netrc`:

```
machine coreweave.sourcegraph.com
	password sgp_YOUR_TOKEN_HERE
```

Create tokens at: https://coreweave.sourcegraphcloud.com/users/YOUR_USERNAME/settings/tokens

**Auth pattern for curl commands:**

```bash
TOKEN=$(awk '/machine coreweave.sourcegraph.com/{found=1} found && /password/{print $2; exit}' ~/.netrc)
curl -s 'https://coreweave.sourcegraphcloud.com/.api/graphql' \
  -H "Authorization: token $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ currentUser { username } }"}'
```

**Endpoint override:** Set `SG_ENDPOINT` to use a different instance. Default: `https://coreweave.sourcegraphcloud.com`

## Quick Reference

### Queries

| Task | Query |
|------|-------|
| List dashboards | `insightsDashboards(first: 50)` |
| Get dashboard by ID | `insightsDashboards(id: "DASHBOARD_ID")` |
| List all insight views | `insightViews(first: 50)` |
| Get insight view by ID | `insightViews(id: "VIEW_ID")` |
| Search insight views | `insightViews(find: "search term")` |
| Check backfill status | `insightSeriesQueryStatus` |

### Mutations

| Task | Mutation |
|------|----------|
| Create dashboard | `createInsightsDashboard(input: CreateInsightsDashboardInput!)` |
| Update dashboard | `updateInsightsDashboard(id: ID!, input: UpdateInsightsDashboardInput!)` |
| Delete dashboard | `deleteInsightsDashboard(id: ID!)` |
| Add insight to dashboard | `addInsightViewToDashboard(input: AddInsightViewToDashboardInput!)` |
| Remove insight from dashboard | `removeInsightViewFromDashboard(input: RemoveInsightViewFromDashboardInput!)` |
| Create line chart insight | `createLineChartSearchInsight(input: LineChartSearchInsightInput!)` |
| Update line chart insight | `updateLineChartSearchInsight(id: ID!, input: UpdateLineChartSearchInsightInput!)` |
| Create pie chart insight | `createPieChartSearchInsight(input: PieChartSearchInsightInput!)` |
| Update pie chart insight | `updatePieChartSearchInsight(id: ID!, input: UpdatePieChartSearchInsightInput!)` |
| Delete insight view | `deleteInsightView(id: ID!)` |
| Clone insight to new view | `saveInsightAsNewView(input: SaveInsightAsNewViewInput!)` |
| Enable/disable series | `updateInsightSeries(input: UpdateInsightSeriesInput!)` |

## Reading Dashboard Data

To get a dashboard with its insight views, use nested fragments:

```graphql
{
  insightsDashboards(id: "DASHBOARD_ID") {
    nodes {
      id
      title
      grants { users { id } organizations { id } global }
      views {
        nodes {
          id
          ... on InsightView {
            presentation {
              ... on LineChartInsightViewPresentation { title seriesPresentation { seriesId label color } }
              ... on PieChartInsightViewPresentation { title otherThreshold }
            }
            dataSeriesDefinitions {
              ... on SearchInsightDataSeriesDefinition {
                seriesId
                query
                generatedFromCaptureGroups
                isCalculated
                groupBy
                repositoryDefinition {
                  ... on InsightRepositoryScope { repositories }
                  ... on RepositorySearchScope { search allRepositories }
                }
                timeScope { ... on InsightIntervalTimeScope { unit value } }
              }
            }
            defaultFilters { includeRepoRegex excludeRepoRegex searchContexts }
            defaultSeriesDisplayOptions { limit numSamples sortOptions { mode direction } }
            repositoryDefinition {
              ... on InsightRepositoryScope { repositories }
              ... on RepositorySearchScope { search allRepositories }
            }
            timeScope { ... on InsightIntervalTimeScope { unit value } }
            isFrozen
            dashboardReferenceCount
            seriesCount
          }
        }
      }
    }
  }
}
```

## Dashboard ID Extraction

Dashboard IDs in URLs are base64-encoded. The URL path segment after `/dashboards/` is the GraphQL ID:

```
https://coreweave.sourcegraphcloud.com/insights/dashboards/ZGFzaGJvYXJkOnsi...
```

Use that full base64 string as the `id` parameter in queries.

## Common Mistakes

- **Using `title` on InsightView directly:** The title lives under `presentation { ... on LineChartInsightViewPresentation { title } }`, not on InsightView itself
- **Using `query` on InsightsSeries:** The query field is on `SearchInsightDataSeriesDefinition` (via `dataSeriesDefinitions`), not on `InsightsSeries` (via `dataSeries`). `dataSeries` returns time-series data points; `dataSeriesDefinitions` returns the series configuration
- **Confusing `dataSeries` vs `dataSeriesDefinitions`:** `dataSeries` = computed data points with `points[]`. `dataSeriesDefinitions` = the search queries and configuration that define each series
- **Missing inline fragments:** InsightView fields require `... on InsightView { }`. Presentation requires `... on LineChartInsightViewPresentation { }` or `... on PieChartInsightViewPresentation { }`
- **Wrong netrc machine name:** Use `coreweave.sourcegraph.com` (not `coreweave.sourcegraphcloud.com`) in `~/.netrc`
- **Forgetting grants on dashboard create:** `createInsightsDashboard` requires `grants` - use `{global: true}` for org-wide visibility or `{users: [userId]}` for personal
- **Stale seriesId on update:** Series IDs are regenerated on every `updateLineChartSearchInsight` call. If you pass `seriesId` values from a previous response, the API creates new series and the label-to-query mapping gets scrambled. When updating all series at once, omit `seriesId` entirely to let the API generate fresh IDs with correct mapping. Only include `seriesId` when updating a subset of series in-place.
- **`archived:no` disallowed in repositoryCriteria:** The `archived` filter cannot be used in the `repositoryCriteria` field of `repositoryScope`. Put `archived:no` in each series `query` instead.
- **Missing `.yaml` workflow files:** GitHub Actions workflows can use either `.yml` or `.yaml` extensions. Use `file:\.github/workflows/.*\.ya?ml` (not `\.yml`) to match both.
- **`repo:has.file()` not supported in insights queries:** The `repo:has.file(path:...)` predicate works in live search but silently fails in insight backfill workers (0 pending, 0 completed, 0 failed, no data). Use `repo:has.path(...)` in the series `repositoryCriteria` instead. Each series can have its own `repositoryScope` override with a per-series `repositoryCriteria`.

See [sourcegraph-insights-api-reference.md](sourcegraph-insights-api-reference.md) for full type definitions.
