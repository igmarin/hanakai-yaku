# Skill Catalog

Complete catalog of all skills and workflows in the `hanami-skills` repository.

## Atomic Skills

| Name | Category | Description | Ecosystem Sources |
|---|---|---|---|
| `sequel-migrations` | db | Write and run Sequel database migrations | jeremyevans/sequel |
| `rom-relations` | db | Define ROM Relations with schema and queries | rom-rb/rom, rom-rb/rom-sql |
| `rom-repositories` | db | Create ROM Repositories for persistence | rom-rb/rom, rom-rb/rom-sql |
| `rom-structs-entities` | db | Define ROM Structs and Entities | rom-rb/rom, rom-rb/rom-sql |
| `action-anatomy` | actions | Create Hanami 2.x Actions | hanami/hanami-controller |
| `action-json-api` | actions | Build JSON API responses | hanami/hanami-controller |
| `action-params-validation` | actions | Validate request parameters | hanami/hanami-controller |
| `action-halt-errors` | actions | Handle errors and halting | hanami/hanami-controller |
| `deps-mixin` | di | Inject dependencies with Deps | dry-rb/dry-system |
| `providers` | di | Register external dependencies | dry-rb/dry-system |
| `view-objects` | views | Create Hanami 2.x Views | hanami/hanami-view |
| `view-parts` | views | Use View Parts for decorator logic | hanami/hanami-view |
| `routes-dsl` | routing | Define routes | hanami/hanami-router |
| `slice-anatomy` | slices | Create modular Slices | hanami/hanami |
| `slice-configuration` | slices | Configure Slices | hanami/hanami |
| `test-planning` | testing | Choose the right test type | hanami/hanami-rspec |
| `request-specs` | testing | Write RSpec request specs | hanami/hanami-rspec |
| `action-unit-specs` | testing | Write isolated Action specs | hanami/hanami-rspec |
| `rom-specs` | testing | Write ROM relation/repository specs | hanami/hanami-rspec |
| `hanami-new` | cli | Scaffold new Hanami applications | hanami/hanami |
| `generators` | cli | Generate components | hanami/hanami-cli |
| `db-commands` | cli | Run database CLI commands | hanami/hanami-cli |
| `dev-runtime` | cli | Development server and console | hanami/hanami-cli |
| `result-pattern` | dry-monads | Use dry-monads Success/Failure | dry-rb/dry-monads |
| `settings` | settings | Manage application settings | hanami/hanami |
| `code-review` | code-review | Review Hanami 2.x code | hanami/hanami |
| `security-review` | security-review | Review security concerns | hanami/hanami |
| `refactoring` | refactoring | Refactor Hanami 2.x code | hanami/hanami |

## Workflows

| Name | Description | Constituent Skills |
|---|---|---|
| `tdd-workflow` | TDD feature development | test-planning → request-specs → implement → code-review |
| `crud-resource-workflow` | Full CRUD resource | rom-structs-entities → rom-relations → rom-repositories → action-anatomy → view-objects → request-specs → code-review |
| `api-slice-workflow` | API-only slice | slice-anatomy → action-anatomy → routes-dsl → request-specs → code-review |
| `authentication-workflow` | Authentication | deps-mixin → providers → action-anatomy → action-halt-errors |
| `add-table-column` | Schema migration | sequel-migrations → rom-relations → rom-structs-entities → rom-repositories → request-specs |
| `new-slice` | New slice creation | slice-anatomy → routes-dsl → slice-configuration → deps-mixin → request-specs |
| `validation-contract` | dry-validation | deps-mixin → action-params-validation → result-pattern → action-unit-specs |
| `background-jobs` | Background jobs | providers → deps-mixin → action-anatomy → action-unit-specs |
