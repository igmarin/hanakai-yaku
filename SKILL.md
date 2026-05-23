---
name: hanakai-yaku
description: >
  Master orchestrator for hanakai-yaku, a curated library of 31 atomic skills and
  9 callable agents for Hanami, dry-rb, and ROM Ruby development. Covers actions,
  slices, repositories, relations, providers, DI, CLI, testing, views, routing,
  and TDD automation. Enforces Hanami conventions and TDD discipline.
  hanami, dry-rb, rom, ruby, tdd, slices, repositories, operations, providers, di,
  actions, views, routing, cli, testing.
---
# hanakai-yaku

Master entry point. Navigate and activate 31 Hanami, dry-rb, and ROM development skills plus 9 orchestration agents.

**Core principle:** Atomic, task-specific instructions that turn AI coding assistants into disciplined Hanami collaborators through TDD and idiomatic patterns.

## Quick Reference

| Task | Primary Skill |
|------|---------------|
| **Load app context** | `load-context` |
| **Configure providers** | `configure-providers` |
| **Register a provider** | `register-provider` |
| **Inject dependencies** | `implement-di` / `inject-dependencies` |
| **Create an action** | `create-action` |
| **Validate params** | `validate-params` |
| **Handle action errors** | `handle-errors` |
| **Build JSON API** | `build-json-api` |
| **Create a repository** | `create-repository` |
| **Define a relation** | `define-relation` |
| **Define an entity** | `define-entity` |
| **Write a migration** | `write-migration` |
| **Create a view** | `create-view` |
| **Create a slice** | `create-slice` |
| **Define routes** | `define-routes` |
| **Plan tests** | `plan-tests` |
| **Write action specs** | `write-action-spec` |
| **Write ROM specs** | `write-rom-spec` |
| **Handle Result pattern** | `handle-result-pattern` |
| **Refactor code** | `refactor-code` |
| **Review code** | `review-code` |
| **Review security** | `review-security` |
| **Create an app** | `create-app` |
| **Generate components** | `generate-components` |
| **Project onboarding** | `hanami-setup` (agent) |
| **TDD loop** | `tdd-loop` (agent) |

## HARD-GATE

```text
DO NOT propose code, specs, or operations without first running 'load-context'.
Implementation code CANNOT be written until:
  1. The test EXISTS
  2. The test has been RUN
  3. The test FAILS for the right reason (feature missing, not a typo)
```

## Core Process

1. **Context:** Start every session with `load-context`.
2. **Learn patterns:** Use `handle-result-pattern` and `inject-dependencies` to follow conventions.
3. **Build:** Use action, repository, relation, and view skills for implementation.
4. **Test:** Use testing skills with the TDD gate.
5. **Review:** Use `review-code`, `review-security`, and `refactor-code`.

## Skill Catalog

| Category | Skills |
|----------|--------|
| **Context** | `load-context` |
| **Providers** | `configure-providers`, `implement-di`, `register-provider`, `inject-dependencies` |
| **Actions** | `create-action`, `validate-params`, `handle-errors`, `build-json-api` |
| **Persistence** | `create-repository`, `define-relation`, `define-entity`, `write-migration` |
| **dry-rb** | `handle-result-pattern` |
| **Testing** | `plan-tests`, `write-action-spec`, `write-request-spec`, `write-rom-spec` |
| **Slices** | `create-slice`, `configure-slice` |
| **Views** | `create-view`, `decorate-with-parts` |
| **Routing** | `define-routes` |
| **CLI** | `create-app`, `generate-components`, `manage-database`, `run-development` |
| **Quality** | `refactor-code`, `review-code`, `review-security` |
| **Settings** | `manage-settings` |

## Agents

| Agent | Focus |
|-------|-------|
| `hanami-setup` | Project onboarding: Context → Providers → DI → Verify |
| `create-new-slice` | Slice scaffolding with proper structure |
| `build-api-slice` | Full API slice with actions, repos, relations |
| `build-crud-resource` | CRUD resource end-to-end |
| `tdd-loop` | TDD cycle: plan → test → implement → review |
| `setup-authentication` | Authentication with providers and operations |
| `add-table-column` | Safe column additions with migrations |
| `add-background-jobs` | Background job setup with providers |
| `validation-contract` | Validation contract creation |

*See `tile.json` for the complete skill registry and `agents.json` for the agent registry.*

## Integration

- **Source of Truth:** `tile.json` (skill registry), `agents.json` (agent registry)
- **Reference:** `docs/reference/skill-catalog.md`, `docs/reference/integration-matrix.md`
- **Glossary:** `CONTEXT.md` (domain terms)
- **Agent Guidance:** `AGENTS.md`
