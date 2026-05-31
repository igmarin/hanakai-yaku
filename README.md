# hanakai-yaku
![hanakai-yaku logo](https://github.com/user-attachments/assets/3126b6e0-bbbf-4e00-a226-e3178486becc)

**hanakai-yaku turns AI coding assistants into disciplined Hanami collaborators.**

A curated library of atomic skills for Hanami, dry-rb, and ROM Ruby development. 3 initial skills and 1 agent  (35 skills + 10 agents) that teach AI tools how to configure providers, implement dependency injection, write TDD tests, create repositories, design slices, and build operations — using Hanami conventions.

> **Status:** Experimental — used to validate skill format portability across Ruby frameworks. Not actively maintained as a product. For production Rails AI tooling, see [rails-ai-bridge](https://github.com/igmarin/rails-ai-bridge).

The project is built around one non-negotiable rule:

```text
Write test -> Run test -> Verify it FAILS for the right reason -> Implement -> Verify it PASSES
```

That TDD gate is encoded directly into the skills and agents.

## Part of the AI Skill Ecosystem

This repo is one of 6 in a composable AI skill ecosystem:

| Repo | Role |
|------|------|
| [`ruby-core-skills`](https://github.com/igmarin/ruby-core-skills) | 15 shared Ruby skills + process discipline |
| [`rails-agent-skills`](https://github.com/igmarin/rails-agent-skills) | 28 Rails-specific skills + 9 agents |
| [**`hanakai-yaku`**](https://github.com/igmarin/hanakai-yaku) | 35 Hanami/dry-rb skills + 10 agents |
| [`agnostic-planning-skills`](https://github.com/igmarin/agnostic-planning-skills) | 10 planning skills + 4 agents |
| [`agent-mcp-runtime`](https://github.com/igmarin/agent-mcp-runtime) | Rust CLI runtime (pack resolution, MCP) |
| [`ruby-skill-bench`](https://github.com/igmarin/ruby-skill-bench) | Benchmark/eval engine |

See the [Ecosystem Overview](https://github.com/igmarin/agent-mcp-runtime/blob/main/docs/ecosystem.md) for the full architecture.

*This repo depends on `ruby-core-skills`. See [Migration Guide](https://github.com/igmarin/agent-mcp-runtime/blob/main/docs/migration-guide.md).*

> Supported agent environments
>
> [![Claude](https://img.shields.io/badge/Claude-D97757?logo=claude&logoColor=fff)](#)
> [![Cursor](https://img.shields.io/badge/Cursor-000000?logo=cursor)](#)
> [![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-000?logo=githubcopilot&logoColor=fff)](#)
> [![Google Gemini](https://img.shields.io/badge/Google%20Gemini-886FBF?logo=googlegemini&logoColor=fff)](#)
> [![OpenCode](https://img.shields.io/badge/OpenCode-4285F4?style=for-the-badge&logoColor=white)](#)
> [![Windsurf](https://img.shields.io/badge/Windsurf-0B100F?logo=windsurf&logoColor=fff)](#)
> [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
> [![skills.sh](https://skills.sh/b/igmarin/hanakai-yaku)](https://skills.sh/igmarin/hanakai-yaku)
> [![Smithery](https://img.shields.io/badge/Smithery-orange)](https://smithery.ai/skills/ismael-marin/hanakai-yaku)
>![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/igmarin/hanakai-yaku?utm_source=oss&utm_medium=github&utm_campaign=igmarin%2Fhanakai-yaku&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)
>[![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Figmarin%2Fhanakai-yaku)](https://tessl.io/registry/igmarin/hanakai-yaku)

## Who This Is For

| Reader | What you get |
| Hanami developers | AI-assisted Hanami development: slices, repositories, operations, actions, views. |
| dry-rb users | Guidance on operations, validation contracts, DI patterns, and type-safe design. |
| ROM users | Repository patterns, relation design, changeset composition, migration safety. |
| Team leads | Repeatable workflows for Hanami onboarding, TDD discipline, and slice architecture. |

## Installation

Install skills via tessl.io:

```bash
npx tessl i igmarin/hanakai-yaku
```
or with yarn

```bash
yarn dlx tessl i igmarin/hanakai-yaku
```

Install skills via skills.sh:

```bash
npx skills add igmarin/hanakai-yaku
```

Or via GitHub CLI (v2.90.0+):

```bash
# Install the dependency first
gh skill install igmarin/ruby-core-skills

# Install all skills interactively
gh skill install igmarin/hanakai-yaku

# Install a specific skill
gh skill install igmarin/hanakai-yaku load-context --scope project
```

Or use directly as chat commands (`@skill-name`) in compatible agents (OpenCode, Cursor, Claude Code, Gemini CLI, Windsurf).

## What Is In The Repository

| Area | Purpose |
|------|---------|
| `skills/` | Atomic Hanami skills organized by category: context, providers, actions, persistence, dry-rb, testing, slices, views. |
| `agents/` | Orchestrated agents that chain skills into guided workflows. |
| `docs/` | Architecture, agent guide, reference catalog, and calling conventions. |
| `CONTEXT.md` | Domain glossary — the canonical vocabulary for Hanami concepts. |

## Start Here

Skills are invoked via chat commands:

| Method | Syntax | Example |
|--------|--------|---------|
| **Chat Command** | `@skill-name` | `@load-context` |

```text
@load-context            # Discover the app's slices, providers, and routes
@configure-providers     # Set up providers and settings
@implement-di            # Configure dependency injection patterns
@hanami-setup            # Full project onboarding workflow
```

## Skill Catalog

| Skill | Category | Description |
|-------|----------|-------------|
| `load-context` | Context | Load the Hanami app structure before coding |
| `configure-providers` | Providers | Set up Hanami providers, settings, and .env |
| `implement-di` | Providers | Dependency injection patterns with dry-system |

### Agent

| Agent | Description |
|-------|-------------|
| `hanami-setup` | Project onboarding: Context → Providers → DI → Verify |

See `docs/reference/skill-catalog.md` for the complete catalog.

## How Skills Work

Each skill is a single `SKILL.md` file with YAML frontmatter and a 6-section body:

```text
1. Frontmatter (YAML)       — name, description, metadata
2. Quick Reference          — scannable table for fast lookup
3. HARD-GATE               — non-negotiable blocking rules
4. Core Process             — step-by-step procedure
5. Output Style             — exact shape of artifacts
6. Integration              — predecessor/successor skills
```

## Documentation Map

| Need | Document |
|------|----------|
| Understand the docs system | [docs/index.md](docs/index.md) |
| Browse all skills | [docs/reference/skill-catalog.md](docs/reference/skill-catalog.md) |
| Understand skill chaining | [docs/reference/integration-matrix.md](docs/reference/integration-matrix.md) |
| Follow agent guides | [docs/agent-guide.md](docs/agent-guide.md) |
| Understand repository structure | [docs/architecture.md](docs/architecture.md) |

## Contributing

When contributing skills, agents, or docs:

- Keep generated artifacts in English unless the user explicitly asks for another language.
- Preserve the tests-gate-implementation rule for every code-producing skill.
- Keep public docs consistent with `tile.json`, `agents.json`, and `CONTEXT.md`.
