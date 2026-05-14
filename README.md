# Hanami Skills

A curated library of atomic skills and callable workflows for the Hanami 2.x Ruby framework.

## Purpose

`hanami-skills` teaches AI coding agents (and developers) how to build Hanami 2.x applications using production-minded conventions. It covers the full stack: database layer (Sequel, ROM), HTTP layer (Actions, Views, Routing), dependency injection, testing, and workflows.

## Repository Structure

```
hanami-skills/
├── skills/           # 29 atomic skills organized by category
│   ├── actions/      # Action anatomy, JSON API, params validation, halt/errors
│   ├── cli/          # hanami new, generators, db commands, dev runtime
│   ├── code-review/  # Code review conventions
│   ├── db/           # Sequel migrations, ROM relations, repositories, structs/entities
│   ├── di/           # Deps mixin, providers
│   ├── dry-monads/   # Result pattern
│   ├── refactoring/  # Refactoring conventions
│   ├── routing/      # Routes DSL
│   ├── security-review/  # Security review conventions
│   ├── settings/     # Application settings
│   ├── slices/       # Slice anatomy, configuration
│   ├── testing/      # Test planning, request specs, action unit specs, ROM specs
│   └── views/        # View objects, view parts
├── workflows/        # 8 callable workflows
│   ├── tdd-workflow/
│   ├── crud-resource-workflow/
│   ├── api-slice-workflow/
│   ├── authentication-workflow/
│   ├── add-table-column/
│   ├── new-slice/
│   ├── validation-contract/
│   └── background-jobs/
├── mcp_server/       # Ruby MCP server
├── docs/             # Documentation
│   ├── reference/    # Skill catalog, integration matrix
│   └── workflows/    # Workflow guide
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

Reference skills by canonical name or file path:

- `skills/db/sequel-migrations/SKILL.md`
- `skills/actions/action-anatomy/SKILL.md`
- `workflows/tdd-workflow/SKILL.md`

### GitHub CLI

```bash
gh skill install igmarin/hanami-skills sequel-migrations
```

## Skill Categories

| Category | Skills |
|---|---|
| Database | `sequel-migrations`, `rom-relations`, `rom-repositories`, `rom-structs-entities` |
| Actions | `action-anatomy`, `action-json-api`, `action-params-validation`, `action-halt-errors` |
| DI | `deps-mixin`, `providers` |
| Views | `view-objects`, `view-parts` |
| Routing | `routes-dsl` |
| Slices | `slice-anatomy`, `slice-configuration` |
| Testing | `test-planning`, `request-specs`, `action-unit-specs`, `rom-specs` |
| CLI | `hanami-new`, `generators`, `db-commands`, `dev-runtime` |
| Cross-cutting | `result-pattern`, `settings`, `code-review`, `security-review`, `refactoring` |

## Workflows

| Workflow | Description |
|---|---|
| `tdd-workflow` | TDD feature development loop |
| `crud-resource-workflow` | Full CRUD resource implementation |
| `api-slice-workflow` | API-only slice creation |
| `authentication-workflow` | Authentication integration |
| `add-table-column` | Schema migration workflow |
| `new-slice` | New slice creation |
| `validation-contract` | dry-validation contract implementation |
| `background-jobs` | Background job integration |

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
