---
name: plan-review
description: >
  Adversarial review of an implementation plan or spec before touching code. Challenges
  architectural decisions, surfaces hidden constraints and assumptions, and runs a
  Codex-driven production gap analysis to catch issues while changes are still free.
  Use this before executing any plan - the goal is to be the engineering lead who
  reviews a junior's proposal before it gets built.

  Trigger on: "plan-review", "/plan-review", "review this plan", "stress-test this
  plan", "challenge my plan", "is my plan solid", "adversarial plan review", "review
  the plan before we build", "check the plan", "is this ready to implement", or any
  request to validate a plan, spec, or design doc before implementation. Also trigger
  after writing-plans produces a plan and the user asks whether it's ready.
argument-hint: "path to plan file, or omit to find the most recent plan"
---

# Plan Review

Adversarial review of a plan or spec before any code is written. The goal is to
catch architectural flaws, hidden assumptions, and production gaps while changes
are still cheap - not after three days of implementation.

Treat the plan as a proposal from a junior engineer. Review it like an engineering
lead would: question every significant decision, surface what was never said out loud,
and find the gaps that only show up in production.

**Announce at start:** "I'm using the plan-review skill to stress-test this plan."

## Step 1: Load the Plan

If a path is in `$ARGUMENTS`, read that file. If the plan was shared inline in the
conversation, work from that. Otherwise find the most recent plan:

```bash
ls -t docs/superpowers/plans/*.md 2>/dev/null | head -1
find . -path "*/plans/*.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -1
```

Read the full plan content before proceeding. Don't review from memory or summaries.

## Step 2: Determine Plan Scope

Before checking completeness, identify what kind of plan this is. Scope determines
which areas are required vs. inherited from the existing system.

- **Greenfield** - new project or system built from scratch. All six areas are required.
- **New service/component** - a standalone new piece within an existing org. Architecture
  and deployment required; data model and file structure may be partial.
- **Feature addition** - new functionality added to an existing codebase. Goal and testing
  are always required. Architecture, data model, and deployment are often implicit
  (inherited from the existing system) - only flag them missing if their absence would
  actually block implementation or cause ambiguity, not just because they weren't
  restated.

State the scope you've identified before proceeding. This scopes every step that follows.

## Step 3: Completeness Check

Verify the plan covers what it needs to given its scope (determined above). Missing
areas are cheap to add now and costly to discover mid-implementation.

| Area | Greenfield | New service | Feature addition |
|------|-----------|-------------|-----------------|
| **Goal** | Required | Required | Required |
| **Architecture** | Required | Required | Only if meaningfully new |
| **Data model** | Required | Required | Only if schema changes |
| **File structure** | Required | Required | Only if new files/packages |
| **Testing** | Required | Required | Required |
| **Deployment / integration** | Required | Required | Only if deploy process changes |

For every area, assign one of these statuses - always produce an entry for all six
rows, never silently omit one:

- **Present** - the plan covers it
- **Partial** - covered but incomplete in a way worth noting
- **Absent** - required for this scope and missing; flag it
- **Skipped - [reason]** - not required for this scope; briefly state why
  (e.g. "Skipped - feature addition, deployment inherited from existing service")

If two or more *required* areas (given the scope) are absent, the plan needs more
definition before adversarial review is useful. Tell the user what's missing and why
it matters.

## Step 4: Architectural Decision Audit

For each technology, library, service, or framework named in the plan, challenge it
with a skeptic's eye. The goal is not to reject choices but to make the reasoning
explicit before it's load-bearing.

For each significant decision, ask:

- **Cost**: Is this paid when a free or self-hosted alternative exists?
- **Fit**: Does this match the stated constraints (budget, platform, compliance)?
- **Redundancy**: Does something already in the stack solve this?
- **Lock-in**: What does this choice foreclose or make expensive later?
- **Assumptions**: What scale, traffic, or team knowledge does this assume?

Output only real concerns. Don't manufacture challenges for decisions that are clearly
justified or standard for the context.

| Decision | Challenge | Alternative Worth Considering |
|----------|-----------|-------------------------------|

If no decisions warrant challenge, say so explicitly.

## Step 5: Constraint and Assumption Inventory

The most dangerous assumptions are the ones never written down. Walk through each
category and flag whether it is addressed, absent, or unclear in the plan:

- **Budget**: Any cost constraints? Any paid services that need approval?
- **Platform**: Cloud provider, K8s, serverless, on-prem? Existing commitments?
- **Database**: New instance or existing? Specific type? Managed or self-hosted?
- **Auth**: Reusing existing auth or building new? Any SSO/SAML requirements?
- **Scale**: Expected load or traffic patterns that would affect the architecture?
- **Compliance**: Any regulatory, security, or privacy requirements?
- **Adjacent systems**: Known issues or quirks in systems this will integrate with?
- **Team knowledge**: Any technologies here the team hasn't used before?

Note any assumption that, if wrong, would require a rewrite rather than a patch.

## Step 6: Production Gap Analysis via Codex

Use a fresh Codex session to stress-test the plan for production readiness. A
separate model reviewing the plan avoids the self-validation problem - Codex
approaches it without the context that shaped it, which surfaces different gaps.

Open a Codex session with the full plan:

```
mcp__codex-cli__codex(prompt: "
You are reviewing an implementation plan for production readiness before any code
is written. Find gaps that won't appear in development but will cause real problems
in production. Be specific. Only surface issues that actually apply to this plan -
skip theoretical concerns that aren't relevant.

<plan>
[full plan content]
</plan>

Check each area below. For each gap you find: name it, explain when it would surface
(dev? staging? production at scale?), and describe the fix.

DATA LAYER
- DB indexes: are all columns used in WHERE clauses, ORDER BY, joins, or foreign
  key lookups covered? A missing index is invisible until the table has rows.
- N+1 queries: does the plan load a list then query each item individually?
- Unbounded queries: any query that returns an unlimited result set?
- Connection pooling: is the connection strategy mentioned for the expected load?

TIME AND STATE
- Timezone handling: any date comparisons, scheduled jobs, streak logic, or
  'created today' checks that assume a specific timezone?
- Concurrent writes: any operations where two requests could race? Is there
  locking or idempotency?
- State transitions: are all states and transitions defined, including error states?

RELIABILITY
- External call failures: what happens when a third-party API is slow or down?
  Are there timeouts, retries, circuit breakers?
- Partial failure: can an operation fail halfway through? Is it resumable or
  does it need manual cleanup?
- Rate limits: does the plan hit any API that has rate limits without handling them?

OBSERVABILITY
- Silent failures: what happens when something fails without raising an exception?
- Missing signals: are there operations where 'it ran but produced wrong data'
  would be undetectable?

MIGRATION AND DEPLOYMENT
- Table locks: does any migration lock a table in production? Is there a
  zero-downtime alternative?
- Rollback: if deployment fails, is there a rollback path that does not lose data?
- Dual-read period: does the plan handle the window when old and new code run
  simultaneously?

DATA CORRECTNESS
- For every metric, field, or piece of data displayed in the UI or consumed
  downstream: is there a corresponding collection, computation, or write step?
  Missing data sources produce silent gaps - the plan builds the UI but nothing
  populates it.
- For any job or importer that writes rows: is there an upsert/dedup strategy,
  or will every run append duplicate rows?

SECURITY
- Input validation: are user inputs validated at system entry points?
- Credentials: are any secrets or tokens mentioned in the plan stored securely?
- Authorization: are there new endpoints or operations without explicit authz checks?

Group your findings by category. Keep each finding to 2-3 sentences.
")
```

If Codex surfaces significant gaps, continue the session to dig into any area that
needs more depth.

## Step 7: Deliver the Report

```markdown
## Plan Review: [Plan Name]

**Scope:** Greenfield | New service/component | Feature addition
[One sentence describing what the scope determination was based on]

### Verdict
**Ready to execute** | **Minor revisions needed** | **Significant gaps - revise before building**

[2-3 sentences on overall quality and the single biggest concern, if any]

---

### Completeness

| Area | Status | Notes |
|------|--------|-------|
| Goal | Present / Partial / Absent / Skipped - [reason] | |
| Architecture | Present / Partial / Absent / Skipped - [reason] | |
| Data model | Present / Partial / Absent / Skipped - [reason] | |
| File structure | Present / Partial / Absent / Skipped - [reason] | |
| Testing | Present / Partial / Absent / Skipped - [reason] | |
| Deployment / integration | Present / Partial / Absent / Skipped - [reason] | |

### Architectural Decisions to Revisit
[Table from Step 4, or "No challenges - decisions look sound"]

### Hidden Assumptions
[List from Step 5 - assumptions that would cause a rewrite if wrong, or "None found"]

### Production Gaps
[Codex findings from Step 6, grouped by category]

---

### Before You Build
- [ ] [specific change to make to the plan]
- [ ] ...

[If nothing: "Plan looks solid. Proceed to execution."]
```

After delivering the report, offer: "Want me to update the plan to address any of these?"

---

## What "ready to execute" looks like

A plan that passes review:
- Covers all six spec areas
- Technology choices match stated constraints
- No assumption that would require a rewrite if wrong
- DB indexes on all query columns
- Pagination on all list operations
- Error handling named at every external boundary
- Migration strategy that does not lock production tables
