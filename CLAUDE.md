# Hanakai Yaku (Skills) — Claude Code Configuration

This file instructs Claude Code on how to discover and invoke skills from the `hanakai-yaku` repository.

## Repository Purpose

`hanakai-yaku` is a curated library of atomic skills and callable workflows for the Hanami 2.x Ruby framework. It teaches AI agents how to plan, implement, test, and review Hanami 2.x applications using production-minded conventions.

## Skill Catalog

The repository contains 29 atomic skills and 8 workflows covering:

- **Database layer**: Sequel migrations, ROM Relations, Repositories, Structs/Entities
- **Actions layer**: Action anatomy, JSON API, params validation, halt/errors
- **DI layer**: Deps mixin, register-provider
- **Views layer**: View objects, view parts
- **Routing**: Routes DSL
- **Slices**: Slice anatomy, configuration
- **Testing**: Test planning, request specs, action unit specs, ROM specs
- **CLI**: `hanami new`, generate-components, db commands, dev runtime
- **Cross-cutting**: dry-monads result pattern, manage-settings, code review, security review, refactor-code

## How to Discover Skills

1. **MCP Server** (preferred): The `hanakai-yaku` MCP server exposes `list_skills` and `use_skill` tools. Load skills on demand to keep context small.
2. **Direct file reference**: Reference skills by canonical `name` from frontmatter.
3. **GitHub CLI**: `gh skill install igmarin/hanakai-yaku <canonical-name>`

## How to Invoke a Skill

Reference skills by their canonical `name` from YAML frontmatter:

- `write-migration`
- `define-relation`
- `create-action`
- `tdd-loop`
- `build-crud-resource`

File paths (for reference only):
- `skills/db/write-migration/SKILL.md`
- `skills/actions/create-action/SKILL.md`
- `workflows/tdd-loop/SKILL.md`

## TDD Gate Enforcement

For all code-producing tasks, enforce the TDD Gate:

1. Write a failing test
2. Run the test and verify it fails for the right reason
3. Implement the minimal code to make it pass
4. Run the test and verify it passes
5. Refactor if needed

No exceptions. Tests gate implementation.

## Progressive Disclosure

When loading skills:
1. **Discovery**: Load only the name and description of each skill
2. **Activation**: When a task matches a skill's description, read the full SKILL.md
3. **Execution**: Follow the instructions, optionally executing bundled code or loading referenced files
