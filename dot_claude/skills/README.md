# Skills

This directory contains reusable skills for various workflows.

## Available Skills

### Git & Version Control

- **git-commit** - Create atomic, well-formatted commits following best practices

### Code Review

- **grug-review** - Code review using grug-brain philosophy

### CoreWeave Tools

- **cw-repo** - Create new CoreWeave GitHub repository
- **cw-scaffold** - Add components to existing repository
- **cw-dev** - Setup development environment
- **cw-explore** - Explore CoreWeave repositories

### Infrastructure

- **argocd** - ArgoCD operations
- **kubernetes** - Kubernetes operations
- **teleport** - Teleport access management

### Documentation

- **diataxis-documentation** - Documentation following Diataxis framework
- **clean-copy** - Clean up documentation text
- **humanizer** - Make text more human-friendly

### Repository Management

- **repo-explore** - Explore and analyze external GitHub repositories
- **remember** - Persist information across sessions

### Code Search

- **search-code** - Search Sourcegraph-indexed codebases for implementation patterns and examples

### Atlassian

- **confluence** - Confluence wiki operations

## Usage

Skills are invoked using the `/<skill-name>` syntax.

Example:
```bash
/git-commit
/cw-repo
/grug-review
```

## Creating New Skills

Each skill is a directory containing a `SKILL.md` file with:
- YAML frontmatter (name, description, allowed-tools)
- Instructions for Claude
- Usage guidelines

See existing skills for examples.

## Related

- See `../commands/` for custom commands
- See `../rules/` for development rules and policies
