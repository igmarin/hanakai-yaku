# Hanami Skills — Gemini CLI Configuration

This file provides equivalent instructions to `CLAUDE.md` for Gemini CLI.

## Repository Purpose

`hanami-skills` is a curated library of atomic skills and callable workflows for the Hanami 2.x Ruby framework.

## Skill Catalog

29 atomic skills and 8 workflows covering database, actions, DI, views, routing, slices, testing, CLI, and cross-cutting concerns.

## How to Discover Skills

1. **MCP Server**: Use `list_skills` to discover, `use_skill` to load
2. **Direct file reference**: Read `SKILL.md` files by path
3. **GitHub CLI**: `gh skill install igmarin/hanami-skills <skill-name>`

## How to Invoke a Skill

Reference by canonical `name`:
- `sequel-migrations`, `rom-relations`, `action-anatomy`, `tdd-workflow`

Paths:
- `skills/{category}/{name}/SKILL.md`
- `workflows/{name}/SKILL.md`

## TDD Gate

Write failing test → verify failure → implement → verify pass → refactor. Mandatory for all code-producing tasks.
