# hanakai-yaku — Agent Guidance

This file tells AI agents how to use this repository.

## What This Repository Is

A curated library of 35 atomic skills for Hanami, dry-rb, and ROM Ruby development, plus 10 callable agents that chain skills into guided workflows. Skills are executable instructions — not documentation. They guide agents through structured workflows with hard gates. **This repo depends on `ruby-core-skills`** for shared Ruby process skills (test planning, refactoring process). These are resolved automatically via pack resolution.

## How Skills Are Organized

Each skill lives in its own directory with a `SKILL.md` entry point:

```
skill-name/
├── SKILL.md          # Entry point — always read this first
├── EXAMPLES.md       # Concrete input/output examples (when present)
├── TEMPLATE.md       # Output structure (when present)
└── HEURISTICS.md     # Reference tables (when present)
```

Read `SKILL.md` first. Load supporting files only when the skill links to them and the content is needed.

## Skill Selection

All skills are organized by category:

| Category | Path | Skills |
|----------|------|--------|
| **Actions** | `skills/actions/` | `build-json-api`, `create-action`, `handle-errors`, `validate-params` |
| **CLI** | `skills/cli/` | `create-app`, `generate-components`, `manage-database`, `run-development` |
| **Context** | `skills/context/` | `load-context` |
| **Cross-cutting** | `skills/cross-cutting/` | `manage-settings`, `review-code` |
| **Persistence** | `skills/db/` | `create-changeset`, `create-repository`, `define-entity`, `define-relation`, `write-migration` |
| **DI** | `skills/di/` | `inject-dependencies`, `register-provider` |
| **dry-monads** | `skills/dry-monads/` | `handle-result-pattern` |
| **dry-rb** | `skills/dry-rb/` | `create-operation`, `create-validation-contract` |
| **Providers** | `skills/providers/` | `configure-providers`, `implement-di` |
| **Security** | `skills/review-security/` | `review-security` |
| **Routing** | `skills/routing/` | `define-routes` |
| **Slices** | `skills/slices/` | `configure-slice`, `create-slice`, `extract-slice`, `review-slice-boundaries`, `test-slice` |
| **Testing** | `skills/testing/` | `write-action-spec`, `write-request-spec`, `write-rom-spec` |
| **Views** | `skills/views/` | `create-view`, `decorate-with-parts` |
| **Core Skills** *(from ruby-core-skills)* | *(external)* | `tdd-process`, `refactor-process`, `review-process`, `security-review-process`, `test-planning-process` |

## Non-Negotiable Rule

**Tests gate implementation.** This applies to every skill that produces code:

```
Write test → Run test → Verify it FAILS for the right reason → Implement → Verify it PASSES
```

Every code-producing skill contains a `HARD-GATE` section enforcing this.

## Agents

| Agent | Path | Purpose |
|-------|------|---------|
| **add-background-jobs** | `agents/add-background-jobs/` | Background jobs: register adapter → inject → enqueue → test |
| **add-table-column** | `agents/add-table-column/` | Schema changes: generate migration → update data layer → test |
| **build-api-slice** | `agents/build-api-slice/` | API Slices: create slice → define actions → routes → test |
| **build-crud-resource** | `agents/build-crud-resource/` | Full CRUD: entity → migration → repo → actions → views → test |
| **create-new-slice** | `agents/create-new-slice/` | New Slice: generate → configure routes → setup DI → test |
| **hanami-setup** | `agents/hanami-setup/` | Project onboarding: context → providers → DI → verify |
| **setup-authentication** | `agents/setup-authentication/` | Auth implementation: DI → register provider → actions → error handling |
| **slice-lifecycle** | `agents/slice-lifecycle/` | Slice lifecycle: create → test → review → extract |
| **tdd-loop** | `agents/tdd-loop/` | TDD: plan *(from core)* → test → implement → review |
| **validation-contract** | `agents/validation-contract/` | Validation: define contract → register DI → inject → handle results → test |

## Workflow Chaining

Each skill's **Integration** table names the next skill to load. Follow it. Skills are building blocks; agents are the primary unit of value.

## Output Language

All generated artifacts must be in **English** unless the user explicitly requests another language.

## Context First

Before any Hanami implementation or review, load context with `load-context` to discover the app's slices, providers, settings, routes, and established patterns.
