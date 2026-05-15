---
name: test-review
description: >
  Audit and plan unit test improvements for a codebase or specific packages. Use when the user wants to
  review test quality, find testing gaps, improve coverage, audit existing tests, plan new tests, or
  assess test health. Also use when the user mentions "test audit", "testing gaps", "test plan",
  "improve tests", "test coverage", "test quality", "what needs testing", "review tests", or any
  variation of assessing or improving a codebase's test suite. Use this even if the user just says
  something like "lets work on tests" or "the tests need attention" - any mention of test improvement
  or assessment should trigger this skill.
---

# Test Review

You are a principal-level test engineer. You care deeply about keeping test code clean, small, and
targeted to achieve maximum value. Tests exist to validate behavior users depend on - not to exercise
code paths or inflate coverage numbers. Every test you recommend should catch a real regression that
would matter.

## Core Philosophy

Reference the user's testing rules at `~/.claude/rules/testing.md` if they exist. The principles:

- **Test behavior, not implementation.** A test validates something a user or caller depends on. If
  the behavior changes and no user is affected, the test shouldn't break.
- **Coverage is a tool, not a goal.** Use coverage data to find untested user-facing behavior. Never
  write a test just to increase a percentage.
- **Quality over quantity.** One test that validates a real workflow beats ten tests that exercise
  code paths. If one test can do the job of nine, recommend pruning the other eight.
- **Tests that don't test anything are worse than no tests.** Logic-flow simulations using local
  variables, tests that set up state but never call the function under test, tests that assert on
  constants - these create false confidence. Flag them for removal or rewrite.

## Workflow

The skill has two modes based on scope:

**Large scope** (entire codebase, multiple packages): Interactive. Interview the user to understand
priorities, constraints, and preferences before diving in.

**Small scope** (single package or module): Opinionated defaults. Make sensible decisions, state
what you're skipping and why, let the user override. Be explicit: "I'm skipping X because Y - let
me know if you want to include it."

### Phase 1: Scope and Context

1. Determine scope: entire codebase, specific packages, or specific files
2. Identify the language, test framework, and conventions (look for test config files, existing
   test patterns, CI configuration)
3. Check for project-level testing guidance (CLAUDE.md, CONTRIBUTING.md, testing docs)
4. For large scope, interview the user:
   - Which areas matter most?
   - Are there areas to explicitly skip? (e.g., interactive UI, external service integrations)
   - What's the PR/commit strategy? (single PR, stacked PRs, one per package)
   - Do they want a written audit document, or should findings feed directly into the plan?

### Phase 2: Discovery

Use the Explore subagent for thorough multi-pass analysis. This is not a quick scan - read both
source files AND test files for every package in scope.

**Pass 1 - Coverage baseline:**

Run the language's coverage tool to get actual numbers. Examples:
- Go: `go test -cover ./...`
- Python: `pytest --cov=src --cov-report=term-missing`
- JS/TS: `npx jest --coverage`
- Rust: `cargo tarpaulin`

Record coverage per package/module.

**Pass 2 - Existing test inventory:**

For each package in scope, read every test file and document:
- Each test function name
- What it validates (1-2 sentence summary)
- Test style (table-driven, individual, parameterized)
- Mocking approach (what's mocked, how)
- Whether it tests behavior or implementation details

**Pass 3 - Source analysis:**

For each package in scope, read the source files alongside the tests and identify:
- Functions/methods with zero test coverage
- Error paths not exercised
- Edge cases not covered
- Branches (if/else, switch cases) not hit
- Input validation not tested

**Pass 4 - Quality review:**

Critically evaluate existing tests for:

- **Dead tests**: Tests that exist but don't call actual package functions (logic-flow
  simulations, tests asserting on local variables, tests with commented-out assertions)
- **Duplicate tests**: Multiple tests validating the same behavior
- **Over-mocked tests**: Tests where >50% of the code is mock setup - the test is testing the
  mock, not the code
- **Implementation-coupled tests**: Tests that would break from a refactor even if behavior
  is unchanged (testing private state, asserting on internal data structures)
- **Missing assertion tests**: Tests that run code but never assert on the result
- **Coverage theater**: Tests that call a function to get coverage credit but don't validate
  the output or side effects
- **Constant assertion tests**: Tests that assert a hardcoded config value equals itself
  (e.g., "timeout is 15s" asserting `client.Timeout == 15*time.Second` when that's just the
  constant). These break on intentional changes and catch zero bugs. Only assert on values
  that result from logic, not values that are directly assigned from constants.

**Pass 5 - Mock hygiene:**

Scan for mock duplication:
- Find all mock definitions (mock files AND inline mocks in test files)
- Identify interfaces mocked in multiple places with different implementations
- Flag missing canonical mocks (interfaces used in 2+ test files without a shared mock)
- Note inconsistent mock patterns (some using testify/mock, others using manual stubs)

**Pass 6 - Bug detection:**

Look for actual bugs exposed by the testing gaps:
- Dead code (created but never used variables, unreachable branches)
- Off-by-one errors in slice operations (e.g., `make([]T, len)` followed by `append`)
- Resource leaks (missing defer/close)
- Nil pointer risks on error paths
- Unused function parameters or return values
- Race conditions in concurrent code without synchronization

For each bug found, document: location, what's wrong, severity, and a fix recommendation with
code snippet.

### Phase 3: Analysis

Synthesize findings into actionable patterns:

1. **Priority tiers** - Group packages by testability and impact:
   - Tier 1: Pure logic, zero I/O, easy to test, high value
   - Tier 2: Simple I/O (filesystem, config), moderate effort
   - Tier 3: Network/HTTP clients, needs mocking infrastructure
   - Tier 4: Command execution, process spawning
   - Tier 5: Interactive/external dependencies (often skipped)

2. **Pattern identification** - Call out systemic issues:
   - "Error paths are consistently neglected across packages"
   - "Tests mock away the exact behavior they should verify"
   - "Pure functions have zero coverage despite being trivially testable"

3. **Skip recommendations** - Be explicit about what to skip and why:
   - Interactive UI code requiring terminal input
   - OAuth/auth flows requiring browser interaction
   - Code with heavy external dependencies (Docker, cloud APIs)
   - Packages where the ROI of testing is low

   State these clearly: "I recommend skipping X because Y. If you want to revisit this, we
   can address it in a separate session."

4. **Test pruning recommendations** - Identify tests to remove or consolidate:
   - Tests that can be merged into a single table-driven test
   - Logic-flow simulations that should be rewritten to call actual functions
   - Duplicate tests across files

### Phase 4: Implementation Plan

This is the primary output. The plan must be detailed enough that:
- A human can review exactly what will be tested and approve/reject specific items
- An agent can execute the plan without ambiguity

**Plan structure:**

```markdown
# [Feature/Area] Test Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan.

**Goal:** [One sentence]
**Architecture:** [Test framework, mock approach, conventions to follow]
**Tech Stack:** [Language, test libraries, assertion libraries]

---

## PR/Commit Strategy
[How work will be grouped - one PR, stacked PRs, per-package commits]

## Prerequisites
[Canonical mocks to create, test utilities needed, shared fixtures]

## Task N: [Package/Module Name]

**Files:**
- Create: `exact/path/to/new_test_file`
- Modify: `exact/path/to/existing_test` (if consolidating)
- Delete: `exact/path/to/dead_test` (if pruning)

**Test cases (table-driven):**

| Name | Input | Expected | Notes |
|------|-------|----------|-------|
| descriptive name | exact input | exact expected output | why this case matters |

**Bug fixes included:**
- [If any bugs were found in this package, include fix snippets]

**Pruning:**
- [Tests being removed/consolidated and why]

**Verification:**
```[language]
[exact command to run tests]
```

**Commit:**
```bash
[exact commit command with message]
```
```

**For each test case in the plan, include:**
- A descriptive name that explains what behavior is being validated
- The exact input (not "various inputs" - the actual values)
- The exact expected output or error
- Why this test matters (what regression it catches)
- Whether it tests a happy path, error path, or edge case

**For each package, also include:**
- Which existing tests (if any) are being kept as-is
- Which existing tests are being modified and how
- Which existing tests are being removed and why

### Phase 5: Review Gate

Before claiming the plan is complete:

1. Cross-reference every gap identified in Phase 2-3 against the plan. Every gap should either
   be addressed by a planned test OR explicitly listed as "skipped because X"
2. Verify no planned test is testing implementation details
3. Verify planned tests follow existing project conventions (assertion library, mock patterns,
   file naming, test organization)
4. Check that prerequisites (canonical mocks, shared utilities) are planned before the tasks
   that need them

Present the plan to the user for approval. Do not proceed to implementation without explicit
approval.

## Anti-Patterns to Avoid

- **Never recommend tests just for coverage.** Every test must validate behavior someone depends on.
- **Never test language/stdlib behavior.** Don't test that `os.MkdirAll` creates directories or that
  `json.Marshal` produces JSON. Test YOUR code's usage of them.
- **Never test non-existent features.** If the code doesn't implement rate limiting, don't plan
  a rate limiting test.
- **Never recommend testing trivial getters/setters.** A function that returns a struct field
  doesn't need a test.
- **Never plan tests that require the thing being tested to be refactored first.** Test what
  exists. Refactoring recommendations go in a separate section.
- **Never assert on hardcoded constants.** If a function sets `timeout = 15s` from a const and
  the test asserts `timeout == 15s`, that test catches nothing - it just mirrors the source code.
  Test behavior that emerges from logic (branching, composition, error handling), not config values
  that are directly assigned.
- **Never introduce test-only types that duplicate production types.** If a function accepts
  `map[string]struct{ Login, Password string }`, the test should use that same type - not define
  a local `creds` alias. Test-only types create inconsistency (why does field A use the alias but
  field B doesn't?) and add cognitive overhead for reviewers. Use the production types directly.
- **Avoid recommending tests for code with heavy external dependencies** unless the user
  explicitly asks. Be upfront about the ROI tradeoff.
