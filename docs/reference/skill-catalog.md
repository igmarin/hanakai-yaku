# Skill Catalog

Complete catalog of all skills and workflows in the `hanami-skills` repository.

## Atomic Skills

| Name | Category | Description | Ecosystem Sources |
|---|---|---|---|
| `write-migration` | db | Write and run Sequel database migrations | jeremyevans/sequel |
| `define-relation` | db | Define ROM Relations with schema and queries | rom-rb/rom, rom-rb/rom-sql |
| `create-repository` | db | Create ROM Repositories for persistence | rom-rb/rom, rom-rb/rom-sql |
| `define-entity` | db | Define ROM Structs and Entities | rom-rb/rom, rom-rb/rom-sql |
| `create-action` | actions | Create Hanami 2.x Actions | hanami/hanami-controller |
| `build-json-api` | actions | Build JSON API responses | hanami/hanami-controller |
| `validate-params` | actions | Validate request parameters | hanami/hanami-controller |
| `handle-errors` | actions | Handle errors and halting | hanami/hanami-controller |
| `inject-dependencies` | di | Inject dependencies with Deps | dry-rb/dry-system |
| `providers` | di | Register external dependencies | dry-rb/dry-system |
| `create-view` | views | Create Hanami 2.x Views | hanami/hanami-view |
| `decorate-with-parts` | views | Use View Parts for decorator logic | hanami/hanami-view |
| `define-routes` | routing | Define routes | hanami/hanami-router |
| `create-slice` | slices | Create modular Slices | hanami/hanami |
| `configure-slice` | slices | Configure Slices | hanami/hanami |
| `plan-tests` | testing | Choose the right test type | hanami/hanami-rspec |
| `write-request-spec` | testing | Write RSpec request specs | hanami/hanami-rspec |
| `write-action-spec` | testing | Write isolated Action specs | hanami/hanami-rspec |
| `write-rom-spec` | testing | Write ROM relation/repository specs | hanami/hanami-rspec |
| `create-app` | cli | Scaffold new Hanami applications | hanami/hanami |
| `generators` | cli | Generate components | hanami/hanami-cli |
| `manage-database` | cli | Run database CLI commands | hanami/hanami-cli |
| `run-development` | cli | Development server and console | hanami/hanami-cli |
| `handle-result-pattern` | dry-monads | Use dry-monads Success/Failure | dry-rb/dry-monads |
| `settings` | settings | Manage application settings | hanami/hanami |
| `code-review` | code-review | Review Hanami 2.x code | hanami/hanami |
| `security-review` | security-review | Review security concerns | hanami/hanami |
| `refactoring` | refactoring | Refactor Hanami 2.x code | hanami/hanami |

## Workflows

| Name | Description | Constituent Skills |
|---|---|---|
| `tdd-loop` | TDD feature development | plan-tests → write-request-spec → implement → code-review |
| `build-crud-resource` | Full CRUD resource | define-entity → define-relation → create-repository → create-action → create-view → write-request-spec → code-review |
| `build-api-slice` | API-only slice | create-slice → create-action → define-routes → write-request-spec → code-review |
| `setup-authentication` | Authentication | inject-dependencies → providers → create-action → handle-errors |
| `add-table-column` | Schema migration | write-migration → define-relation → define-entity → create-repository → write-request-spec |
| `create-new-slice` | New slice creation | create-slice → define-routes → configure-slice → inject-dependencies → write-request-spec |
| `validation-contract` | dry-validation | inject-dependencies → validate-params → handle-result-pattern → write-action-spec |
| `add-background-jobs` | Background jobs | providers → inject-dependencies → create-action → write-action-spec |
