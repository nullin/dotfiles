---
name: create-claude-md
description: Generate a CLAUDE.md file for a repository by exploring its structure, build system, architecture, and conventions. Use when the user asks to create, add, or generate a CLAUDE.md, when starting work in a repo that lacks one, or when the user mentions "CLAUDE.md" in the context of creating or improving one. Also trigger when user says "add Claude Code guidance" or "set up Claude for this repo".
---

# Create CLAUDE.md

Generate a CLAUDE.md file tailored to a specific repository. The file is written for Claude Code agents - not humans - so it should be terse, actionable, and focused on what an agent needs to work effectively in the codebase.

## Why This Matters

A good CLAUDE.md saves every future Claude Code session from re-discovering the same information. It answers: "What do I need to know to work here?" Bad ones are generic filler. Good ones are specific, opinionated, and save real time.

## Process

### 1. Explore the Repository

Launch an Explore subagent (or do it inline for small repos) to gather:

- **Project purpose**: What does this repo do? One sentence.
- **Languages and tools**: Primary language, framework, build tools
- **Build commands**: How to build, test, lint, format. Exact make/npm/cargo commands.
- **Architecture**: Key directories, packages, and how they relate. Entry points.
- **Extension patterns**: How to add new things (commands, components, endpoints, etc.)
- **Conventions**: Naming, file organization, mock placement, import ordering
- **CI/CD**: What runs on PR, what runs on merge, what runners are used
- **Environment variables**: Anything needed for local dev or testing
- **Prerequisites**: Required tools, auth tokens, dev environment setup

Focus on things that are NOT obvious from reading the code. An agent can always `cat` a file - the CLAUDE.md should capture the non-obvious connections, gotchas, and patterns.

### 2. Check for Reference CLAUDE.md Files

Look for existing CLAUDE.md files in sibling repositories or well-known locations that can serve as a structural reference. If the user has created CLAUDE.md files before, match their established style and section structure.

Common locations to check:
- Sibling repos in the same workspace (e.g., `../other-repo/CLAUDE.md`)
- The user may point you to a reference - ask if unsure

### 3. Write the CLAUDE.md

Follow this section structure (include only sections that have meaningful content for the repo):

```
# CLAUDE.md

Opening line: "This file provides guidance to Claude Code when working with code in this repository."

## Project Overview
- What the project is (one sentence)
- Key binaries, entry points, or services
- If multiple tools/binaries exist, differentiate them clearly

## Build and Development
- Exact commands in a code block (make targets, npm scripts, etc.)
- Single-test-run example if applicable
- Dev environment notes (nix, docker, env vars)
- Prerequisites (required tools, tokens, auth)

## Architecture
- Command/module structure and how things are wired together
- Key packages with one-line descriptions of what they provide
- Extension points: step-by-step for "how to add a new X"
- Data flow or processing pipeline if relevant

## Conventions
- Linter/formatter setup and commands
- File naming and organization patterns
- Mock/test file placement
- Dependency management approach
- Documentation structure

## Best Practices
- Patterns specific to this repo that an agent should follow
- Common pitfalls and how to avoid them

## Code Review Focus
- Specific items to watch for when reviewing code in this repo
- Common mistakes that have been caught in past reviews
- Style rules that differ from language defaults

## CI Jobs
- Table or list of CI jobs with what each does
- Only include if the CI setup is non-trivial

## Environment Variables
- Variables needed for development, testing, or debugging
- Only include if there are repo-specific variables
```

### 4. Writing Style

The audience is a Claude Code agent, not a human developer reading docs.

- **Terse**: Minimum words to convey the point. No filler sentences.
- **Actionable**: Tell the agent what to do or avoid. Not "consider using X" but "use X".
- **Specific over general**: Concrete rules ("error strings must be lowercase") beat vague guidance ("follow best practices").
- **Imperative mood**: "Run `make test`" not "You can run `make test`".
- **No redundancy**: If it is obvious from reading the code, skip it.
- **Code blocks for commands**: Always wrap commands in fenced code blocks with brief descriptions.

Things to avoid:
- Generic advice that applies to any repo ("write tests", "handle errors")
- Verbose explanations of how things work internally (the agent can read the code)
- Repeating information already in README.md or other docs (reference them instead)
- Sections with only one bullet point (merge into another section or drop)

### 5. Calibrate Depth to Repository Complexity

- **Small repos** (single-purpose tool, <20 files): Keep it to Project Overview + Build + Conventions. A 30-line CLAUDE.md is fine.
- **Medium repos** (multiple packages, CI, some architecture): Full structure minus sections that add no value.
- **Large repos** (monorepo, multiple services, complex build): Full structure. Consider subsections in Architecture. Extension point documentation is critical.

### 6. Review Before Finishing

Before presenting the CLAUDE.md to the user:

1. Re-read it as if you are an agent seeing this repo for the first time. Does it answer your first questions?
2. Check that every command listed actually works (verify against Makefile, package.json, etc.)
3. Remove any section that restates what the code already makes obvious
4. Verify no sensitive information (tokens, internal URLs) leaked into the file
