# Integration Matrix

This document shows which skills chain to which other skills.

## Skills → Related Skills

| Skill | Chains To |
|---|---|
| `write-migration` | `define-relation`, `define-entity`, `create-repository`, `hanami-manage-database` |
| `define-relation` | `create-repository`, `define-entity`, `write-rom-spec` |
| `create-repository` | `define-relation`, `define-entity`, `create-action`, `handle-result-pattern`, `write-rom-spec` |
| `define-entity` | `define-relation`, `create-repository`, `create-view` |
| `create-action` | `create-view`, `validate-params`, `handle-errors`, `inject-dependencies`, `write-request-spec` |
| `build-json-api` | `create-action`, `validate-params`, `write-request-spec` |
| `validate-params` | `create-action`, `handle-errors`, `handle-result-pattern` |
| `handle-errors` | `create-action`, `validate-params`, `security-review`, `write-request-spec` |
| `inject-dependencies` | `create-action`, `create-repository`, `create-view`, `providers` |
| `providers` | `inject-dependencies`, `settings`, `create-action` |
| `create-view` | `create-action`, `decorate-with-parts`, `create-repository`, `write-request-spec` |
| `decorate-with-parts` | `create-view` |
| `define-routes` | `create-action`, `create-slice`, `write-request-spec` |
| `create-slice` | `define-routes`, `configure-slice`, `inject-dependencies`, `write-request-spec` |
| `configure-slice` | `create-slice`, `inject-dependencies`, `providers`, `settings` |
| `plan-tests` | `write-request-spec`, `write-action-spec`, `write-rom-spec` |
| `write-request-spec` | `create-action`, `create-repository`, `create-view`, `handle-errors` |
| `write-action-spec` | `create-action`, `inject-dependencies` |
| `write-rom-spec` | `define-relation`, `create-repository`, `define-entity` |
| `create-app` | `generators`, `manage-database`, `run-development`, `create-slice` |
| `generators` | `create-action`, `create-view`, `create-slice`, `write-migration` |
| `manage-database` | `write-migration`, `define-relation` |
| `run-development` | `define-relation`, `create-repository` |
| `handle-result-pattern` | `inject-dependencies`, `create-action`, `handle-errors` |
| `settings` | `providers`, `inject-dependencies` |
| `code-review` | `create-action`, `inject-dependencies`, `create-repository`, `create-view`, `write-request-spec` |
| `security-review` | `validate-params`, `handle-errors`, `settings` |
| `refactoring` | `create-action`, `inject-dependencies`, `handle-result-pattern`, `create-repository`, `write-request-spec` |

## Workflows → Skills

| Workflow | Skills |
|---|---|
| `tdd-loop` | plan-tests, write-request-spec, write-action-spec, code-review |
| `build-crud-resource` | define-entity, define-relation, create-repository, create-action, create-view, write-request-spec, code-review |
| `build-api-slice` | create-slice, create-action, define-routes, write-request-spec, code-review |
| `setup-authentication` | inject-dependencies, providers, create-action, handle-errors |
| `add-table-column` | write-migration, define-relation, define-entity, create-repository, write-request-spec |
| `create-new-slice` | create-slice, define-routes, configure-slice, inject-dependencies, write-request-spec |
| `validation-contract` | inject-dependencies, validate-params, handle-result-pattern, write-action-spec |
| `add-background-jobs` | providers, inject-dependencies, create-action, write-action-spec |
