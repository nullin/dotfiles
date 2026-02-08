# Custom Agents

This directory contains custom agent definitions that extend Claude's capabilities with specialized expertise and persistent behavior.

## Available Agents

### critical-code-reviewer

**Purpose:** Elite code review focusing on critical bugs, security vulnerabilities, performance issues, and maintainability

**When to use:**
- Security-sensitive code (authentication, payments, data handling)
- Critical features that could cause production incidents
- Pre-production review of high-risk changes
- Performance-critical code paths
- After implementing complex logic

**Model:** Sonnet (high-capability)

**Review Focus:**
1. Correctness and logic (critical priority)
2. Security (OWASP Top 10, injection, crypto)
3. Performance and efficiency (N+1 queries, algorithms)
4. Maintainability (only if significantly impactful)

**Output:** Structured review with severity levels, specific locations, and actionable recommendations

**File:** `critical-code-reviewer.md`

### daily

**Purpose:** Primary personal driver agent for all work across projects and sessions

**When to use:**
- Multi-project work requiring context across sessions
- Building up knowledge over time
- Recurring tasks that benefit from memory
- Personal assistance with persistent preferences

**Model:** Default

**Special Features:**
- **Persistent Memory:** `~/.claude/agent-memory/daily/`
- **Permission Mode:** bypassPermissions (full autonomy)
- **Memory Strategy:** Maintains MEMORY.md index + topic-specific files

**Memory Management:**
- MEMORY.md: High-level index (auto-loaded, keep under 150 lines)
- Topic files: Detailed notes (loaded on-demand by topic)
- Remembers: coding preferences, project architectures, tools, decisions, solutions
- Forgets: temporary debug state, one-off tasks

**File:** `daily.md`

## Custom vs Plugin Agents

### Custom Agents (This Directory)

**Location:** `~/.claude/agents/`

**Characteristics:**
- Defined locally
- Fully under your control
- Can customize: prompt, tools, model, memory
- Persist across Claude Code updates
- Examples: critical-code-reviewer, daily

**Use when:** You need specialized behavior tailored to your workflow

### Plugin Agents (From Installed Plugins)

**Location:** `~/.claude/plugins/cache/`

**Characteristics:**
- Provided by installed plugins
- Updated when plugin updates
- Standardized behaviors
- Examples:
  - `code-reviewer` (pr-review-toolkit, feature-dev)
  - `code-explorer` (feature-dev)
  - `code-architect` (feature-dev)
  - `silent-failure-hunter` (pr-review-toolkit)
  - `comment-analyzer` (pr-review-toolkit)
  - `pr-test-analyzer` (pr-review-toolkit)

**Use when:** Plugin workflows call them automatically

### When to Use Which

| Scenario | Use |
|----------|-----|
| Deep security audit | custom: critical-code-reviewer |
| Personal daily driver | custom: daily |
| PR review from plugin | plugin: agents invoked automatically |
| Feature development workflow | plugin: feature-dev agents |
| Specialized PR analysis | plugin: pr-review-toolkit agents |

## Creating Custom Agents

Each agent is a Markdown file with YAML frontmatter:

```markdown
---
name: agent-name
description: When and why to use this agent
model: sonnet|opus|haiku (optional)
memory: user|none (optional)
permissionMode: default|bypassPermissions (optional)
---

# Agent instructions here

You are an expert in...

## Methodology

1. Step one
2. Step two

## Output Format

Structured output requirements...
```

### Key Elements

1. **YAML frontmatter:**
   - `name` - Agent identifier
   - `description` - Triggers and use cases (shown to Claude)
   - `model` - Which Claude model to use
   - `memory` - Whether agent has persistent memory
   - `permissionMode` - Permission handling

2. **Instructions:**
   - Clear role and expertise
   - Methodology or approach
   - Output format requirements
   - Examples of good behavior

3. **Examples:**
   - Show expected inputs and outputs
   - Demonstrate the agent's style

### Best Practices

- **Be specific:** Clear instructions produce consistent behavior
- **Show examples:** Examples are more powerful than rules
- **Focus expertise:** Agents work best with narrow, deep focus
- **Test thoroughly:** Verify agent behavior matches intent
- **Document triggers:** Help Claude know when to invoke

## Agent Invocation

### From Commands/Skills

Skills and commands can invoke agents using the Task tool:

```markdown
Use the Task tool with:
- subagent_type: "agent-name"
- prompt: "Specific task for the agent"
- description: "Brief summary"
```

### From Conversation

Claude will automatically suggest agents when their description matches the context.

## Memory Management

### Agents with Memory

The `daily` agent demonstrates memory management:

- **MEMORY.md:** Auto-loaded index (first 200 lines)
- **Topic files:** Detailed notes loaded on-demand
- **Update strategy:** After significant work, update relevant files
- **Consolidation:** Periodically merge/clean up files

### Memory Location

Agent memory stored at: `~/.claude/agent-memory/<agent-name>/`

## Troubleshooting

### Agent not being invoked

- Check description matches the scenario
- Verify agent file has correct YAML frontmatter
- Ensure agent name matches invocation

### Agent behaving unexpectedly

- Review instructions for clarity
- Add examples of desired behavior
- Check if model has sufficient capability

### Memory not persisting

- Verify `memory: user` in frontmatter
- Check memory directory exists
- Ensure Write tool is available to agent

## Related

- **Commands:** `~/.claude/commands/` - Reusable command workflows
- **Skills:** `~/.claude/skills/` - User-invocable skills
- **Plugins:** `~/.claude/plugins/` - Installed plugin packages
- **Rules:** `~/.claude/rules/` - Development guidelines

## See Also

- CLAUDE.md - Global configuration and quick reference
- settings.json - Enabled plugins and permissions
