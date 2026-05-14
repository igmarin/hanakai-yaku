# Hanami Skills — MCP Server

A Ruby MCP server that exposes the `hanami-skills` library to AI tools via the Model Context Protocol.

## What it exposes

| Type | Name | Description |
|---|---|---|
| Tool | `list_skills` | Returns names, descriptions, and categories of all skills and workflows |
| Tool | `use_skill` | Returns the full SKILL.md content for a given skill name |
| Resource | `skill://{name}` | Each skill and workflow is registered as an MCP Resource |

## Local Setup

```bash
cd mcp_server
bundle install
bundle exec ruby server.rb
```

## Configuration for Claude Code

Add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "hanami-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/hanami-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/hanami-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

## Configuration for Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "hanami-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/hanami-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/hanami-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

## Configuration for Windsurf

Add to `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "hanami-skills": {
      "type": "stdio",
      "command": "bundle",
      "args": ["exec", "ruby", "mcp_server/server.rb"],
      "cwd": "/ABSOLUTE/PATH/TO/hanami-skills",
      "env": {
        "BUNDLE_GEMFILE": "/ABSOLUTE/PATH/TO/hanami-skills/mcp_server/Gemfile"
      }
    }
  }
}
```

## Troubleshooting

If you encounter "Gems not found" errors, ensure you run `bundle install` in the `mcp_server/` directory first.
