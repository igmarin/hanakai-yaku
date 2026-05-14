# Integration Matrix

This document shows which skills chain to which other skills.

## Skills → Related Skills

| Skill | Chains To |
|---|---|
| `sequel-migrations` | `rom-relations`, `rom-structs-entities`, `rom-repositories`, `hanami-db-commands` |
| `rom-relations` | `rom-repositories`, `rom-structs-entities`, `rom-specs` |
| `rom-repositories` | `rom-relations`, `rom-structs-entities`, `action-anatomy`, `result-pattern`, `rom-specs` |
| `rom-structs-entities` | `rom-relations`, `rom-repositories`, `view-objects` |
| `action-anatomy` | `view-objects`, `action-params-validation`, `action-halt-errors`, `deps-mixin`, `request-specs` |
| `action-json-api` | `action-anatomy`, `action-params-validation`, `request-specs` |
| `action-params-validation` | `action-anatomy`, `action-halt-errors`, `result-pattern` |
| `action-halt-errors` | `action-anatomy`, `action-params-validation`, `security-review`, `request-specs` |
| `deps-mixin` | `action-anatomy`, `rom-repositories`, `view-objects`, `providers` |
| `providers` | `deps-mixin`, `settings`, `action-anatomy` |
| `view-objects` | `action-anatomy`, `view-parts`, `rom-repositories`, `request-specs` |
| `view-parts` | `view-objects` |
| `routes-dsl` | `action-anatomy`, `slice-anatomy`, `request-specs` |
| `slice-anatomy` | `routes-dsl`, `slice-configuration`, `deps-mixin`, `request-specs` |
| `slice-configuration` | `slice-anatomy`, `deps-mixin`, `providers`, `settings` |
| `test-planning` | `request-specs`, `action-unit-specs`, `rom-specs` |
| `request-specs` | `action-anatomy`, `rom-repositories`, `view-objects`, `action-halt-errors` |
| `action-unit-specs` | `action-anatomy`, `deps-mixin` |
| `rom-specs` | `rom-relations`, `rom-repositories`, `rom-structs-entities` |
| `hanami-new` | `generators`, `db-commands`, `dev-runtime`, `slice-anatomy` |
| `generators` | `action-anatomy`, `view-objects`, `slice-anatomy`, `sequel-migrations` |
| `db-commands` | `sequel-migrations`, `rom-relations` |
| `dev-runtime` | `rom-relations`, `rom-repositories` |
| `result-pattern` | `deps-mixin`, `action-anatomy`, `action-halt-errors` |
| `settings` | `providers`, `deps-mixin` |
| `code-review` | `action-anatomy`, `deps-mixin`, `rom-repositories`, `view-objects`, `request-specs` |
| `security-review` | `action-params-validation`, `action-halt-errors`, `settings` |
| `refactoring` | `action-anatomy`, `deps-mixin`, `result-pattern`, `rom-repositories`, `request-specs` |

## Workflows → Skills

| Workflow | Skills |
|---|---|
| `tdd-workflow` | test-planning, request-specs, action-unit-specs, code-review |
| `crud-resource-workflow` | rom-structs-entities, rom-relations, rom-repositories, action-anatomy, view-objects, request-specs, code-review |
| `api-slice-workflow` | slice-anatomy, action-anatomy, routes-dsl, request-specs, code-review |
| `authentication-workflow` | deps-mixin, providers, action-anatomy, action-halt-errors |
| `add-table-column` | sequel-migrations, rom-relations, rom-structs-entities, rom-repositories, request-specs |
| `new-slice` | slice-anatomy, routes-dsl, slice-configuration, deps-mixin, request-specs |
| `validation-contract` | deps-mixin, action-params-validation, result-pattern, action-unit-specs |
| `background-jobs` | providers, deps-mixin, action-anatomy, action-unit-specs |
