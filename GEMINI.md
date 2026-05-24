# Hanakai Yaku (Skills) — Gemini CLI Configuration

This file provides equivalent instructions to `CLAUDE.md` for Gemini CLI.

## Repository Purpose

`hanakai-yaku` is a curated library of 35 atomic skills and 10 callable agents for the Hanami 2.x Ruby framework. It teaches AI coding agents (and developers) how to plan, implement, test, and review Hanami 2.x applications using production-minded conventions. **This repo depends on `ruby-core-skills`** for shared Ruby process skills (`tdd-process`, `refactor-process`, `review-process`, `security-review-process`, `test-planning-process`). These are resolved automatically via pack resolution.

## Skill Catalog

The repository contains 35 atomic skills and 10 agents covering:

- **Database layer**: Sequel migrations, ROM Relations, Repositories, Structs/Entities
- **Actions layer**: Action anatomy, JSON API, params validation, halt/errors
- **DI layer**: Deps mixin, register-provider
- **Views layer**: View objects, view parts
- **Routing**: Routes DSL
- **Slices**: Slice anatomy, configuration
- **Testing**: Request specs, action unit specs, ROM specs
- **CLI**: `hanami new`, generate-components, db commands, dev runtime
- **Cross-cutting**: dry-monads result pattern, manage-settings, code review, security review
- **Process skills** *(from ruby-core-skills)*: `tdd-process`, `refactor-process`, `review-process`, `security-review-process`, `test-planning-process`

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
- `agents/tdd-loop/SKILL.md`

## TDD Gate Enforcement

For all code-producing tasks, enforce the TDD Gate:

1. Write a failing test
2. Run the test and verify it fails for the right reason
3. Implement the minimal code to make it pass
4. Run the test and verify it passes
5. Refactor if needed

No exceptions. Tests gate implementation.

## Gemini-Specific Conventions

When working with Gemini CLI, use `/skill-name` syntax to explicitly invoke a skill:

```text
/write-migration — How do I add a column to an existing table?
/tdd-loop — I need to implement a new user registration feature
```

Or simply describe the task and the agent will load the appropriate skill automatically via MCP.

## Progressive Disclosure

When loading skills:
1. **Discovery**: Load only the name and description of each skill
2. **Activation**: When a task matches a skill's description, read the full SKILL.md
3. **Execution**: Follow the instructions, optionally executing bundled code or loading referenced files
