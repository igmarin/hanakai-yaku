# Architecture

This document explains the repository layout and the rationale for each directory.

## Directory Structure

```
hanami-skills/
├── skills/              # Atomic skill documents
├── workflows/           # Orchestrator workflow documents
├── mcp_server/          # Ruby MCP server
├── docs/                # Documentation
│   ├── reference/       # Catalog and integration matrix
│   └── workflows/       # Workflow guide
├── .claude-plugin/      # Claude Code plugin metadata
├── .codex/              # Codex installation instructions
├── .cursor-plugin/      # Cursor plugin metadata
├── .mcp.json            # Local MCP configuration
├── server.json          # MCP Registry metadata
├── registry.json        # MCP registry entry
├── CLAUDE.md            # Claude Code instructions
├── AGENTS.md            # OpenAI Codex instructions
├── GEMINI.md            # Gemini CLI instructions
├── README.md            # Main repository documentation
├── CONTRIBUTING.md        # Contribution guidelines
└── .markdownlint.yaml   # Markdown linting rules
```

## Rationale

### `skills/`

Atomic, self-contained instruction documents. Each skill covers exactly one Hanami 2.x concept. Skills are organized by category (`db/`, `actions/`, `di/`, etc.) to make discovery easy.

**Key design decision:** One `SKILL.md` per directory. This allows each skill to optionally include `scripts/`, `references/`, or `assets/` subdirectories without cluttering the repository root.

### `workflows/`

Higher-level orchestrators that chain multiple skills into complete development loops. Workflows share the same `SKILL.md` format as skills but their Core Process section references constituent skills by canonical name.

### `mcp_server/`

A Ruby MCP server that exposes skills as tools and resources. This enables AI agents to discover and load skills on demand without keeping the entire repository in context.

**Key design decision:** The server is simple — just `list_skills` and `use_skill` tools plus `skill://{name}` resources. Complex registries and discovery are handled by the `SkillCatalog` class.

### `docs/`

Public documentation for developers and contributors. Separated from skills so that agent-facing content (skills) and human-facing content (docs) do not mix.

### Agent Configuration Files

`CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` provide agent-host-specific instructions. Each file tailors the same logical content to its target agent's conventions.

### MCP Distribution Files

`.mcp.json`, `server.json`, and `registry.json` enable distribution to MCP registries and clients. They describe the server, its transport, and how to connect.

## Content vs. Code

The primary deliverable of this repository is **content** (Markdown documents), not application code. The MCP server and validation script are secondary tooling that supports the content.

This content-first approach means:
- Skills can be consumed without running any code
- The MCP server is thin and stateless
- Validation is structural (frontmatter, sections) not behavioral
