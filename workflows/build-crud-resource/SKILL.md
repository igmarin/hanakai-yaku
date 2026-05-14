---
name: build-crud-resource
version: "1.0.0"
license: MIT
description: >
  Use when implementing a full CRUD resource in Hanami 2.x. Chains entity,
  relation, repository, action, view, write-request-spec, and code-review.
ecosystem_sources:
  - hanami/hanami
  - rom-rb/rom
tags:
  - workflows
  - crud
  - resources
  - full-stack
---

# build-crud-resource

Use this workflow when implementing a full CRUD resource (Create, Read, Update, Delete) in Hanami 2.x.

**Core principle:** CRUD resources follow a predictable pipeline: data layer → domain layer → HTTP layer → presentation layer.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Define Entity | `define-entity` | Entity class exists with typed attributes |
| 2. Define Relation | `define-relation` | Relation schema matches database |
| 3. Define Repository | `create-repository` | Repository exposes CRUD methods |
| 4. Create Actions | `create-action` | Index, Show, Create, Update, Destroy Actions exist |
| 5. Create Views | `create-view` | Views render for HTML endpoints |
| 6. Write tests | `write-request-spec` | All endpoints have passing request specs |
| 7. Review | `code-review` | No violations found |

---

## Core Process

1. **[Define Entity]** — Load skill: `define-entity`
   - Create Entity class with attributes matching the intended schema
   - Use dry-types for coercion and constraints
   - Handoff condition: Entity class exists and is valid

2. **[Define Relation]** — Load skill: `define-relation`
   - Create Relation with `schema :table_name, infer: true`
   - Add query methods if needed (`active`, `by_email`, etc.)
   - Handoff condition: Relation queries work in console

3. **[Define Repository]** — Load skill: `create-repository`
   - Create Repository wrapping the Relation
   - Implement CRUD methods: `all`, `by_id`, `create`, `update`, `delete`
   - Configure `auto_struct true` and `struct_namespace`
   - Handoff condition: Repository methods return Entities

4. **[Create Actions]** — Load skill: `create-action`
   - Generate Actions: Index, Show, Create, Update, Destroy
   - Inject Repository via `Deps`
   - Implement `#handle` for each endpoint
   - Use `validate-params` for Create/Update
   - Use `handle-errors` for error responses
   - Handoff condition: All Actions respond to HTTP requests

5. **[Create Views]** — Load skill: `create-view`
   - Create Views for HTML endpoints (Index, Show)
   - Define `expose` for each data point
   - Create templates in `app/templates/`
   - Handoff condition: Views render without errors

6. **[Write Tests]** — Load skill: `write-request-spec`
   - Write request specs for all CRUD endpoints
   - Test happy paths and error cases (404, 422)
   - Run full test suite
   - Handoff condition: All tests pass

7. **[Review]** — Load skill: `code-review`
   - Check Action responsibility
   - Check DI usage
   - Check Repository encapsulation
   - Check test coverage
   - Handoff condition: No critical violations

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll start with Actions and work backwards" | Start with the data layer (Entity → Relation → Repository), then the HTTP layer. |
| "I'll skip the Entity and return raw hashes" | Always define Entities. They are the data contract between layers. |
| "I'll put all CRUD in one Action class" | One Action per endpoint. `Users::Index`, `Users::Show`, etc. |
| "I'll skip Views for JSON-only APIs" | Even JSON APIs benefit from explicit Action structure. Skip Views only if truly API-only. |
| "I'll write tests after everything is implemented" | Follow the TDD workflow: write failing request specs for each endpoint before implementing. |

---

## Red Flags

- Starting with Actions instead of data layer
- Missing Entity definitions
- Multiple endpoints in one Action class
- Raw hashes passed between layers
- Tests written after full implementation
- Missing error case tests

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-entity** | Step 1: Define the Entity. |
| **define-relation** | Step 2: Define the Relation. |
| **create-repository** | Step 3: Define the Repository. |
| **create-action** | Step 4: Create Actions. |
| **create-view** | Step 5: Create Views. |
| **write-request-spec** | Step 6: Write tests. |
| **code-review** | Step 7: Review the implementation. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (CRUD Resource) |
|---|---|
| `rails generate scaffold User` | No single scaffold. Generate components individually. |
| `app/models/user.rb` | `app/entities/user.rb` + `app/relations/users.rb` |
| `app/controllers/users_controller.rb` | `app/actions/users/index.rb`, `show.rb`, `create.rb`, etc. |
| `app/views/users/*.html.erb` | `app/views/users/index.rb` + `app/templates/users/index.html.erb` |
| `config/routes.rb` resources | `config/routes.rb` `resources :users` |
| `spec/requests/users_spec.rb` | `spec/requests/users_spec.rb` (same path) |
