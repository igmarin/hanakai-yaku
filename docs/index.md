# hanakai-yaku — Docs

Hanami, dry-rb, and ROM development skills and personas.

## Quick Navigation

| Need | Document |
|------|----------|
| Browse all skills and personas | [reference/skill-catalog.md](reference/skill-catalog.md) |
| Understand skill chaining | [reference/integration-matrix.md](reference/integration-matrix.md) |
| Persona workflows with diagrams | [persona-guide.md](persona-guide.md) |
| Repository structure and conventions | [architecture.md](architecture.md) |
| Invoke skills and personas | [calling-skills.md](calling-skills.md) |

## Skill Categories

| Category | Skills | Count |
|----------|--------|-------|
| Context | `load-context` | 1 |
| Providers | `configure-providers`, `implement-di` | 2 |
| DI | `register-provider`, `inject-dependencies` | 2 |
| Actions | `create-action`, `validate-params`, `handle-errors`, `build-json-api` | 4 |
| Persistence | `create-repository`, `define-relation`, `define-entity`, `write-migration`, `create-changeset` | 5 |
| dry-monads | `handle-result-pattern` | 1 |
| dry-rb | `create-operation`, `create-validation-contract` | 2 |
| Testing | `write-action-spec`, `write-request-spec`, `write-rom-spec` | 3 |
| Slices | `create-slice`, `configure-slice`, `extract-slice`, `review-slice-boundaries`, `test-slice` | 5 |
| Views | `create-view`, `decorate-with-parts` | 2 |
| Routing | `define-routes` | 1 |
| CLI | `create-app`, `generate-components`, `manage-database`, `run-development` | 4 |
| Quality | `review-code`, `review-security` | 2 |
| Settings | `manage-settings` | 1 |

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
