# Sourcegraph Code Insights GraphQL API Reference

Endpoint: `https://coreweave.sourcegraphcloud.com/.api/graphql`

## Authentication

All requests require a token in the Authorization header:

    Authorization: token {token}

Extract token from .netrc:

    TOKEN=$(awk '/machine coreweave.sourcegraph.com/{found=1} found && /password/{print $2; exit}' ~/.netrc)

## Variables

Examples in this reference use these shell variables:

- `$TOKEN` - extracted from .netrc (see above)
- `$SG_ENDPOINT` - defaults to `https://coreweave.sourcegraphcloud.com`
- `$DASHBOARD_ID` - base64-encoded dashboard ID from URL
- `$VIEW_ID` - insight view ID from query responses

Base curl pattern:

    curl -s "${SG_ENDPOINT:-https://coreweave.sourcegraphcloud.com}/.api/graphql" \
      -H "Authorization: token $TOKEN" \
      -H 'Content-Type: application/json' \
      -d '{"query":"...", "variables": {...}}'

---

## Queries

### insightsDashboards

List or fetch dashboards.

| Parameter | Type   | Description                              |
|-----------|--------|------------------------------------------|
| first     | Int    | Number of results to return              |
| after     | String | Pagination cursor                        |
| id        | ID     | Fetch a specific dashboard by ID         |

### insightViews

List or fetch insight views.

| Parameter            | Type                      | Description                              |
|----------------------|---------------------------|------------------------------------------|
| first                | Int                       | Number of results to return              |
| after                | String                    | Pagination cursor                        |
| id                   | ID                        | Fetch a specific view by ID              |
| excludeIds           | [ID!]                     | Exclude specific view IDs                |
| find                 | String                    | Search views by text                     |
| isFrozen             | Boolean                   | Filter by frozen status                  |
| filters              | InsightViewFiltersInput   | Apply repo/context filters               |
| seriesDisplayOptions | SeriesDisplayOptionsInput | Override display options                 |

### insightSeriesQueryStatus

Returns overall backfill queue status. No arguments.

### insightAdminBackfillQueue

Admin view of the backfill queue.

| Parameter  | Type                 | Description                    |
|------------|----------------------|--------------------------------|
| first      | Int                  | Forward pagination count       |
| last       | Int                  | Backward pagination count      |
| after      | String               | Forward cursor                 |
| before     | String               | Backward cursor                |
| orderBy    | BackfillQueueOrderBy | Sort field                     |
| descending | Boolean              | Sort direction                 |
| states     | [String!]            | Filter by backfill states      |
| textSearch | String               | Search text                    |

### insightViewDebug

Debug info for a specific insight view.

| Parameter | Type | Description          |
|-----------|------|----------------------|
| id        | ID!  | Insight view ID      |

---

## Mutations

### createInsightsDashboard

| Input field | Type                          | Required | Description          |
|-------------|-------------------------------|----------|----------------------|
| title       | String!                       | yes      | Dashboard title      |
| grants      | InsightsPermissionGrantsInput!| yes      | Visibility grants    |

### updateInsightsDashboard

| Parameter | Type                           | Required | Description          |
|-----------|--------------------------------|----------|----------------------|
| id        | ID!                            | yes      | Dashboard to update  |
| input     | UpdateInsightsDashboardInput!  | yes      | Fields to update     |

UpdateInsightsDashboardInput:

| Field  | Type                         | Required | Description          |
|--------|------------------------------|----------|----------------------|
| title  | String                       | no       | New title            |
| grants | InsightsPermissionGrantsInput| no       | New grants           |

### deleteInsightsDashboard

| Parameter | Type | Required | Description          |
|-----------|------|----------|----------------------|
| id        | ID!  | yes      | Dashboard to delete  |

### addInsightViewToDashboard

| Input field  | Type | Required | Description              |
|--------------|------|----------|--------------------------|
| insightViewId| ID!  | yes      | View to add              |
| dashboardId  | ID!  | yes      | Target dashboard         |

### removeInsightViewFromDashboard

| Input field  | Type | Required | Description              |
|--------------|------|----------|--------------------------|
| insightViewId| ID!  | yes      | View to remove           |
| dashboardId  | ID!  | yes      | Source dashboard         |

### createLineChartSearchInsight

| Input field     | Type                                    | Required | Description                    |
|-----------------|-----------------------------------------|----------|--------------------------------|
| dataSeries      | [LineChartSearchInsightDataSeriesInput!]!| yes      | Series definitions             |
| repositoryScope | RepositoryScopeInput                    | no       | Default repo scope             |
| timeScope       | TimeScopeInput                          | no       | Default time scope             |
| options         | LineChartOptionsInput!                  | yes      | Chart options (title)          |
| dashboards      | [ID!]                                   | no       | Dashboards to add view to      |
| viewControls    | InsightViewControlsInput                | no       | Filters and display options    |

### updateLineChartSearchInsight

| Parameter | Type                                | Required | Description                    |
|-----------|-------------------------------------|----------|--------------------------------|
| id        | ID!                                 | yes      | View to update                 |

UpdateLineChartSearchInsightInput:

| Field              | Type                                    | Required | Description                    |
|--------------------|-----------------------------------------|----------|--------------------------------|
| dataSeries         | [LineChartSearchInsightDataSeriesInput!]!| yes      | Series definitions             |
| repositoryScope    | RepositoryScopeInput                    | no       | Default repo scope             |
| timeScope          | TimeScopeInput                          | no       | Default time scope             |
| presentationOptions| LineChartOptionsInput!                  | yes      | Chart options (title)          |
| viewControls       | InsightViewControlsInput!               | yes      | Filters and display options    |

### createPieChartSearchInsight

| Input field         | Type                  | Required | Description                    |
|---------------------|-----------------------|----------|--------------------------------|
| query               | String!               | yes      | Search query                   |
| repositoryScope     | RepositoryScopeInput! | yes      | Repo scope                     |
| presentationOptions | PieChartOptionsInput! | yes      | Chart options (title, threshold)|
| dashboards          | [ID!]                 | no       | Dashboards to add view to      |

### updatePieChartSearchInsight

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id        | ID!  | yes      | View to update |

UpdatePieChartSearchInsightInput:

| Field               | Type                  | Required | Description                    |
|---------------------|-----------------------|----------|--------------------------------|
| query               | String!               | yes      | Search query                   |
| repositoryScope     | RepositoryScopeInput! | yes      | Repo scope                     |
| presentationOptions | PieChartOptionsInput! | yes      | Chart options                  |

### deleteInsightView

| Parameter | Type | Required | Description          |
|-----------|------|----------|----------------------|
| id        | ID!  | yes      | View to delete       |

### saveInsightAsNewView

Clone an existing insight view.

| Input field  | Type                       | Required | Description                    |
|--------------|----------------------------|----------|--------------------------------|
| insightViewId| ID!                        | yes      | Source view to clone           |
| options      | LineChartOptionsInput!     | yes      | New chart options (title)      |
| dashboard    | ID                         | no       | Dashboard to add clone to      |
| viewControls | InsightViewControlsInput   | no       | Override filters/display       |

### updateInsightSeries

Enable or disable a specific series.

| Input field | Type    | Required | Description          |
|-------------|---------|----------|----------------------|
| seriesId    | String! | yes      | Series to update     |
| enabled     | Boolean | no       | Enable/disable       |

### retryInsightSeriesBackfill

| Parameter | Type | Required | Description              |
|-----------|------|----------|--------------------------|
| id        | ID!  | yes      | Series backfill to retry |

### moveInsightSeriesBackfillToFrontOfQueue / moveInsightSeriesBackfillToBackOfQueue

| Parameter | Type | Required | Description              |
|-----------|------|----------|--------------------------|
| id        | ID!  | yes      | Series backfill to move  |

---

## Type Reference

### Output Types

#### InsightsDashboard

| Field  | Type                       | Description              |
|--------|----------------------------|--------------------------|
| id     | ID!                        | Dashboard ID             |
| title  | String                     | Dashboard title          |
| views  | InsightViewConnection      | Insight views on dashboard|
| grants | InsightsPermissionGrants   | Visibility permissions   |

#### InsightView

| Field                        | Type                       | Description                          |
|------------------------------|----------------------------|--------------------------------------|
| id                           | ID!                        | View ID                              |
| defaultFilters               | InsightViewFilters         | Default repo/context filters         |
| appliedFilters               | InsightViewFilters         | Currently applied filters            |
| dataSeries                   | [InsightsSeries!]!         | Computed data points                 |
| presentation                 | InsightPresentation        | Title and display config (union)     |
| dataSeriesDefinitions        | [InsightSeriesDefinition!]!| Series query definitions             |
| dashboardReferenceCount      | Int                        | Number of dashboards referencing this|
| isFrozen                     | Boolean                    | Whether view is frozen               |
| defaultSeriesDisplayOptions  | SeriesDisplayOptions       | Default sort/limit options           |
| appliedSeriesDisplayOptions  | SeriesDisplayOptions       | Currently applied options            |
| dashboards                   | InsightsDashboardConnection| Dashboards containing this view      |
| seriesCount                  | Int                        | Number of series                     |
| repositoryDefinition         | InsightRepositoryDefinition| Repo scope (union)                   |
| timeScope                    | InsightTimeScope           | Time scope (union)                   |

#### InsightPresentation (union)

- **LineChartInsightViewPresentation**: `title: String`, `seriesPresentation: [LineChartSeriesPresentation!]!`
- **PieChartInsightViewPresentation**: `title: String`, `otherThreshold: Float`

#### SearchInsightDataSeriesDefinition

| Field                      | Type                       | Description                    |
|----------------------------|----------------------------|--------------------------------|
| seriesId                   | String                     | Series identifier              |
| query                      | String                     | Sourcegraph search query       |
| repositoryDefinition       | InsightRepositoryDefinition| Repo scope for this series     |
| timeScope                  | InsightTimeScope           | Time scope for this series     |
| generatedFromCaptureGroups | Boolean                    | Uses capture group extraction  |
| isCalculated               | Boolean                    | Is a calculated series         |
| groupBy                    | GroupByField               | Group results by field         |

#### InsightsSeries (data points)

| Field    | Type                | Description              |
|----------|---------------------|--------------------------|
| seriesId | String              | Series identifier        |
| label    | String              | Series label             |
| points   | [InsightDataPoint!]!| Time-series data points  |
| status   | InsightSeriesStatus | Backfill status          |

#### InsightRepositoryDefinition (union)

- **InsightRepositoryScope**: `repositories: [String!]!` - explicit repo list
- **RepositorySearchScope**: `search: String`, `allRepositories: Boolean` - dynamic scope

#### InsightTimeScope (union)

- **InsightIntervalTimeScope**: `unit: TimeIntervalStepUnit`, `value: Int`

#### InsightViewFilters

| Field            | Type     | Description              |
|------------------|----------|--------------------------|
| includeRepoRegex | String   | Include repos matching   |
| excludeRepoRegex | String   | Exclude repos matching   |
| searchContexts   | [String] | Search context filters   |

#### SeriesDisplayOptions

| Field       | Type              | Description          |
|-------------|-------------------|----------------------|
| sortOptions | SeriesSortOptions | Sort configuration   |
| limit       | Int               | Max series to show   |
| numSamples  | Int               | Number of samples    |

#### SeriesSortOptions

| Field     | Type               | Description      |
|-----------|--------------------|------------------|
| mode      | SeriesSortMode     | Sort mode        |
| direction | SeriesSortDirection| Sort direction   |

#### InsightsPermissionGrants

| Field         | Type     | Description                  |
|---------------|----------|------------------------------|
| users         | [ID!]!   | User IDs with access         |
| organizations | [ID!]!   | Org IDs with access          |
| global        | Boolean  | Visible to all               |

### Input Types

#### LineChartSearchInsightDataSeriesInput

| Field                      | Type                            | Required | Description                    |
|----------------------------|---------------------------------|----------|--------------------------------|
| seriesId                   | String                          | no       | Existing series ID (for update)|
| query                      | String!                         | yes      | Sourcegraph search query       |
| options                    | LineChartDataSeriesOptionsInput!| yes      | Label and color                |
| repositoryScope            | RepositoryScopeInput            | no       | Override repo scope            |
| timeScope                  | TimeScopeInput                  | no       | Override time scope            |
| generatedFromCaptureGroups | Boolean                         | no       | Use capture groups             |
| groupBy                    | GroupByField                    | no       | Group by field                 |

#### LineChartDataSeriesOptionsInput

| Field     | Type   | Description              |
|-----------|--------|--------------------------|
| label     | String | Series display label     |
| lineColor | String | Hex color for the line   |

#### LineChartOptionsInput

| Field | Type   | Description          |
|-------|--------|----------------------|
| title | String | Chart title          |

#### PieChartOptionsInput

| Field          | Type  | Description                    |
|----------------|-------|--------------------------------|
| title          | String| Chart title                    |
| otherThreshold | Float | Threshold for "other" bucket   |

#### RepositoryScopeInput

| Field              | Type      | Description                          |
|--------------------|-----------|--------------------------------------|
| repositories       | [String!]!| Explicit list of repo names          |
| repositoryCriteria | String    | Dynamic repo selection query         |

#### TimeScopeInput

| Field        | Type                  | Description          |
|--------------|-----------------------|----------------------|
| stepInterval | TimeIntervalStepInput | Interval config      |

#### TimeIntervalStepInput

| Field | Type                 | Description          |
|-------|----------------------|----------------------|
| unit  | TimeIntervalStepUnit | Time unit            |
| value | Int                  | Number of units      |

#### InsightViewControlsInput

| Field                | Type                      | Description          |
|----------------------|---------------------------|----------------------|
| filters              | InsightViewFiltersInput    | Repo/context filters |
| seriesDisplayOptions | SeriesDisplayOptionsInput  | Sort and limit       |

#### InsightViewFiltersInput

| Field            | Type     | Description              |
|------------------|----------|--------------------------|
| includeRepoRegex | String   | Include repos matching   |
| excludeRepoRegex | String   | Exclude repos matching   |
| searchContexts   | [String] | Search context filters   |

#### SeriesDisplayOptionsInput

| Field       | Type                  | Description          |
|-------------|-----------------------|----------------------|
| sortOptions | SeriesSortOptionsInput| Sort configuration   |
| limit       | Int                   | Max series to show   |
| numSamples  | Int                   | Number of samples    |

#### SeriesSortOptionsInput

| Field     | Type               | Description      |
|-----------|--------------------|------------------|
| mode      | SeriesSortMode     | Sort mode        |
| direction | SeriesSortDirection| Sort direction   |

#### InsightsPermissionGrantsInput

| Field         | Type    | Description                  |
|---------------|---------|------------------------------|
| users         | [ID!]   | User IDs with access         |
| organizations | [ID!]   | Org IDs with access          |
| global        | Boolean | Visible to all               |

### Enums

#### TimeIntervalStepUnit

`HOUR`, `DAY`, `WEEK`, `MONTH`, `YEAR`

#### SeriesSortMode

`RESULT_COUNT`, `LEXICOGRAPHICAL`, `DATE_ADDED`

#### SeriesSortDirection

`ASC`, `DESC`

#### GroupByField

`REPO`, `LANG`, `PATH`, `AUTHOR`, `DATE`
