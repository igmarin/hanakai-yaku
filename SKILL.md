---
name: hanakai-yaku
type: catalog
description: >
  Master orchestrator for hanakai-yaku, a curated library of 35 atomic skills and
  10 personas for Hanami, dry-rb, and ROM Ruby development. Covers actions,
  slices, repositories, relations, providers, DI, CLI, testing, views, routing,
  and TDD automation. Enforces Hanami conventions and TDD discipline.
  hanami, dry-rb, rom, ruby, tdd, slices, repositories, operations, providers, di,
  actions, views, routing, cli, testing.
---
# hanakai-yaku

Master entry point. Navigate and activate 35 Hanami, dry-rb, and ROM development skills plus 10 orchestration personas.

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
| **Plan tests** | `test-planning-process` *(from core)* |
| **Write action specs** | `write-action-spec` |
| **Write ROM specs** | `write-rom-spec` |
| **Handle Result pattern** | `handle-result-pattern` |
| **Refactor code** | `refactor-process` *(from core)* |
| **Review code** | `review-code` / `review-process` *(from core)* |
| **Review security** | `review-security` / `security-review-process` *(from core)* |
| **Create an app** | `create-app` |
| **Generate components** | `generate-components` |
| **Project onboarding** | `hanami-setup` (persona) |
| **TDD loop** | `tdd-loop` (persona) |
 
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
5. **Review:** Use `review-code`, `review-security`, and `refactor-process` *(from core)*.
 
## Skill Catalog
 
| Category | Skills |
|----------|--------|
| **Context** | `load-context` |
| **Providers** | `configure-providers`, `implement-di`, `register-provider`, `inject-dependencies` |
| **Actions** | `create-action`, `validate-params`, `handle-errors`, `build-json-api` |
| **Persistence** | `create-repository`, `define-relation`, `define-entity`, `write-migration`, `create-changeset` |
| **dry-rb** | `handle-result-pattern`, `create-operation`, `create-validation-contract` |
| **Testing** | `write-action-spec`, `write-request-spec`, `write-rom-spec` |
| **Slices** | `create-slice`, `configure-slice`, `extract-slice`, `review-slice-boundaries`, `test-slice` |
| **Views** | `create-view`, `decorate-with-parts` |
| **Routing** | `define-routes` |
| **CLI** | `create-app`, `generate-components`, `manage-database`, `run-development` |
| **Quality** | `review-code`, `review-security` |
| **Settings** | `manage-settings` |
| **Core Process** *(from ruby-core-skills)* | `tdd-process`, `refactor-process`, `review-process`, `security-review-process`, `test-planning-process` |

## Personas

| Persona | Focus |
|---------|-------|
| `hanami-setup` | Project onboarding: Context → Providers → DI → Verify |
| `create-new-slice` | Slice scaffolding with proper structure |
| `build-api-slice` | Full API slice with actions, repos, relations |
| `build-crud-resource` | CRUD resource end-to-end |
| `tdd-loop` | TDD cycle: plan → test → implement → review |
| `setup-authentication` | Authentication with providers and operations |
| `add-table-column` | Safe column additions with migrations |
| `add-background-jobs` | Background job setup with providers |
| `validation-contract` | Validation contract creation |
| `slice-lifecycle` | Slice development: Create → Test → Review → Extract |

*See `directory.json` for the complete skill and persona registry.*

## Integration

- **Source of Truth:** `directory.json`
- **Reference:** `docs/reference/skill-catalog.md`, `docs/reference/integration-matrix.md`
- **Glossary:** `CONTEXT.md` (domain terms)
