# Persona Guide

This guide explains how personas work in hanakai-yaku.

## What Is a Persona?

A persona is an orchestrating skill that chains multiple atomic skills together into a guided workflow. Unlike atomic skills (which handle one specific task), personas manage multi-phase processes with hard gates between phases.

## Available Personas

| Persona | Skills Chained | Phases |
|---------|---------------|--------|
| `hanami-setup` | `load-context` → `configure-providers` → `implement-di` | Context → Providers → DI → Verify |
| `create-new-slice` | `create-slice` → `define-routes` → `configure-slice` → `inject-dependencies` → `write-request-spec` | Slice → Routes → Config → DI → Test |
| `build-api-slice` | create-slice → actions → routes → test → review | Slice → Actions → Routes → Test → Review |
| `build-crud-resource` | entity → migration → repo → actions → views → test | Data → Persistence → API → UI → Test |
| `tdd-loop` | `test-planning-process` → write-request-spec → create-action → review-code | Plan → Test → Implement → Review |
| `setup-authentication` | register-provider → inject-dependencies → create-action → handle-errors | Provider → DI → Actions → Errors |
| `add-table-column` | write-migration → define-relation → define-entity → create-repository → write-request-spec | Migration → Relation → Entity → Repo → Test |
| `add-background-jobs` | register-provider → inject-dependencies → create-action → write-request-spec | Provider → DI → Action → Test |
| `validation-contract` | inject-dependencies → validate-params → handle-result-pattern → write-action-spec | DI → Validation → Result → Test |
| `slice-lifecycle` | create-slice → test-slice → review-slice-boundaries → extract-slice | Create → Test → Review → Extract |

## Persona Structure

Each persona is defined as `skills/personas/<name>/SKILL.md` with:

- `type: persona` in YAML frontmatter
- Multiple phases with hard gates between them
- Error recovery procedures (on timeout, resume from last completed phase)
- Dependencies array listing which atomic skills it chains

## Invoking a Persona

Personas are invoked the same way as atomic skills. In supported environments:

- **Chat command:** `@persona-name` (e.g., `@hanami-setup`)
- **OpenCode subagent:** Reference in `.opencode/agents/<name>.md`
- **Direct file:** `{file:./skills/personas/<name>/SKILL.md}`
