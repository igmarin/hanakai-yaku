# Hanakai Yaku (Skills)

A curated library of atomic skills and callable agents for the Hanami 2.x Ruby framework.

## Purpose

`hanakai-yaku` teaches AI coding agents (and developers) how to build Hanami 2.x applications using production-minded conventions. It covers the full stack: database layer (Sequel, ROM), HTTP layer (Actions, Views, Routing), dependency injection, testing, and agents.

## Repository Structure

```text
hanakai-yaku/
├── skills/           # 29 atomic skills organized by category
│   ├── actions/      # Action anatomy, JSON API, params validation, halt/errors
│   ├── cli/          # hanami new, generate-components, db commands, dev runtime
│   ├── cross-cutting/ # manage-settings, review-code
│   ├── db/           # Sequel migrations, ROM relations, repositories, structs/entities
│   ├── di/           # Deps mixin, register-provider
│   ├── dry-monads/   # Result pattern
│   ├── refactor-code/  # Refactoring conventions
│   ├── routing/      # Routes DSL
│   ├── review-security/  # Security review conventions
│   ├── slices/       # Slice anatomy, configuration
│   ├── testing/      # Test planning, request specs, action unit specs, ROM specs
│   └── views/        # View objects, view parts
├── agents/        # 8 callable agents
│   ├── tdd-loop/
│   ├── build-crud-resource/
│   ├── build-api-slice/
│   ├── setup-authentication/
│   ├── add-table-column/
│   ├── create-new-slice/
│   ├── validation-contract/
│   └── add-background-jobs/
├── mcp_server/       # Ruby MCP server
├── docs/             # Documentation
│   ├── reference/    # Skill catalog, integration matrix
│   ├── using-skills-guide.md  # How to compose skills into agents
│   └── agents/    # Workflow guide
├── CLAUDE.md         # Claude Code configuration
├── AGENTS.md         # OpenAI Codex configuration
├── GEMINI.md         # Gemini CLI configuration
└── CONTRIBUTING.md   # Contribution guidelines
```

## Usage

### MCP Server (Recommended)

The MCP server keeps context small by loading skills on demand:

```bash
cd mcp_server
bundle install
bundle exec ruby server.rb
```

Exposes:
- `list_skills` — Discover available skills
- `use_skill` — Load a specific skill's instructions

### Direct File Reference

Reference skills by canonical name from frontmatter:

- `write-migration`
- `create-action`
- `tdd-loop`

### GitHub CLI

```bash
gh skill install igmarin/hanakai-yaku write-migration
```

## Skill Categories

| Category | Skills |
|---|---|
| Database | `write-migration`, `define-relation`, `create-repository`, `define-entity` |
| Actions | `create-action`, `build-json-api`, `validate-params`, `handle-errors` |
| DI | `inject-dependencies`, `register-provider` |
| Views | `create-view`, `decorate-with-parts` |
| Routing | `define-routes` |
| Slices | `create-slice`, `configure-slice` |
| Testing | `plan-tests`, `write-request-spec`, `write-action-spec`, `write-rom-spec` |
| CLI | `create-app`, `generate-components`, `manage-database`, `run-development` |
| Cross-cutting | `handle-result-pattern`, `manage-settings`, `review-code`, `review-security`, `refactor-code` |

## agents

| Workflow | Description |
|---|---|
| `tdd-loop` | TDD feature development loop |
| `build-crud-resource` | Full CRUD resource implementation |
| `build-api-slice` | API-only slice creation |
| `setup-authentication` | Authentication integration |
| `add-table-column` | Schema migration workflow |
| `create-new-slice` | New slice creation |
| `validation-contract` | dry-validation contract implementation |
| `add-background-jobs` | Background job integration |

## TDD Gate

All code-producing skills enforce the TDD Gate:

1. Write a failing test
2. Run and verify it fails for the right reason
3. Implement the minimal code to make it pass
4. Verify the test passes
5. Refactor if needed

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding new skills.

## License

MIT
