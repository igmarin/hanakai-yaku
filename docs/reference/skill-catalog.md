# Skill Catalog — hanakai-yaku

Catalog of Hanami, dry-rb, and ROM development skills. 35 skills and 10 personas available.

---

## Quick Navigation

**Skills (35):** `load-context`, `configure-providers`, `implement-di`, `register-provider`, `inject-dependencies`, `create-action`, `validate-params`, `handle-errors`, `build-json-api`, `create-repository`, `define-relation`, `define-entity`, `write-migration`, `create-changeset`, `handle-result-pattern`, `create-operation`, `create-validation-contract`, `review-code`, `review-security`, `manage-settings`, `create-slice`, `configure-slice`, `extract-slice`, `review-slice-boundaries`, `test-slice`, `define-routes`, `create-view`, `decorate-with-parts`, `write-action-spec`, `write-request-spec`, `write-rom-spec`, `create-app`, `generate-components`, `manage-database`, `run-development`

**Personas (10):** `hanami-setup`, `create-new-slice`, `build-api-slice`, `build-crud-resource`, `tdd-loop`, `setup-authentication`, `add-table-column`, `add-background-jobs`, `validation-contract`, `slice-lifecycle`

---

## Category Reference

| Category | Skills | Count |
|----------|--------|-------|
| **Context** | `load-context` | 1 |
| **Providers** | `configure-providers`, `implement-di` | 2 |
| **DI** | `register-provider`, `inject-dependencies` | 2 |
| **Actions** | `create-action`, `validate-params`, `handle-errors`, `build-json-api` | 4 |
| **Persistence** | `create-repository`, `define-relation`, `define-entity`, `write-migration`, `create-changeset` | 5 |
| **dry-monads** | `handle-result-pattern` | 1 |
| **dry-rb** | `create-operation`, `create-validation-contract` | 2 |
| **Testing** | `write-action-spec`, `write-request-spec`, `write-rom-spec` | 3 |
| **Slices** | `create-slice`, `configure-slice`, `extract-slice`, `review-slice-boundaries`, `test-slice` | 5 |
| **Views** | `create-view`, `decorate-with-parts` | 2 |
| **Routing** | `define-routes` | 1 |
| **CLI** | `create-app`, `generate-components`, `manage-database`, `run-development` | 4 |
| **Quality** | `review-code`, `review-security` | 2 |
| **Settings** | `manage-settings` | 1 |

### Personas

| Persona | Focus | Skills Chained |
|---------|-------|----------------|
| `hanami-setup` | Project onboarding | load-context, configure-providers, implement-di |
| `create-new-slice` | Slice scaffolding | create-slice, define-routes, configure-slice, inject-dependencies, write-request-spec |
| `build-api-slice` | REST API slice | create-slice, actions, routes, test, review |
| `build-crud-resource` | Full CRUD | entity, migration, repo, actions, views, test |
| `tdd-loop` | TDD red-green-refactor | test-planning-process, write-request-spec, create-action, review-code |
| `setup-authentication` | Auth implementation | register-provider, inject-dependencies, handle-errors |
| `add-table-column` | Schema changes | write-migration, define-relation, define-entity, create-repository, write-request-spec |
| `add-background-jobs` | Background processing | register-provider, inject-dependencies, create-action, write-request-spec |
| `validation-contract` | Contract validation | inject-dependencies, validate-params, handle-result-pattern, write-action-spec |
| `slice-lifecycle` | Slice lifecycle | create-slice, test-slice, review-slice-boundaries, extract-slice |

---

## See Also

- [Integration Matrix](integration-matrix.md) — How skills chain together
- [Persona Guide](../persona-guide.md) — Persona workflows with diagrams
- [Architecture](../architecture.md) — Repository layout and conventions
