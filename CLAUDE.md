# Hanami Skills — Claude Code Configuration

This file instructs Claude Code on how to discover and invoke skills from the `hanami-skills` repository.

## Repository Purpose

`hanami-skills` is a curated library of atomic skills and callable workflows for the Hanami 2.x Ruby framework. It teaches AI agents how to plan, implement, test, and review Hanami 2.x applications using production-minded conventions.

## Skill Catalog

The repository contains 29 atomic skills and 8 workflows covering:

- **Database layer**: Sequel migrations, ROM Relations, Repositories, Structs/Entities
- **Actions layer**: Action anatomy, JSON API, params validation, halt/errors
- **DI layer**: Deps mixin, providers
- **Views layer**: View objects, view parts
- **Routing**: Routes DSL
- **Slices**: Slice anatomy, configuration
- **Testing**: Test planning, request specs, action unit specs, ROM specs
- **CLI**: `hanami new`, generators, db commands, dev runtime
- **Cross-cutting**: dry-monads result pattern, settings, code review, security review, refactoring

## How to Discover Skills

1. **MCP Server** (preferred): The `hanami-skills` MCP server exposes `list_skills` and `use_skill` tools. Load skills on demand to keep context small.
2. **Direct file reference**: Reference skills by canonical `name` from frontmatter. File paths: `skills/{category}/{skill-name}/SKILL.md` or `workflows/{workflow-name}/SKILL.md`.
3. **GitHub CLI**: `gh skill install igmarin/hanami-skills <skill-name>`

## How to Invoke a Skill

Reference skills by their canonical `name` from YAML frontmatter:

- `sequel-migrations`
- `rom-relations`
- `action-anatomy`
- `tdd-workflow`
- `crud-resource-workflow`

File paths (for direct reference):
- `skills/db/sequel-migrations/SKILL.md`
- `skills/actions/action-anatomy/SKILL.md`
- `workflows/tdd-workflow/SKILL.md`

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
