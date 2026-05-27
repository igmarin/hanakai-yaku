---
name: build-crud-resource
license: MIT
description: >
  Use when implementing a full CRUD resource in Hanami 2.x, including when asked to scaffold,
  generate a resource, create a REST endpoint, or build a new API resource. Chains entity,
  relation, repository, action, view, write-request-spec, and review-code to build the
  complete data-to-HTTP pipeline.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - rom-rb/rom
  tags:
  - agents
  - crud
  - resources
  - full-stack
  version: 1.0.0
---

# build-crud-resource

Use this workflow when implementing a full CRUD resource (Create, Read, Update, Delete) in Hanami 2.x.

**Core principle:** CRUD resources follow a predictable pipeline: data layer → domain layer → HTTP layer → presentation layer.

---

## Pipeline

| Step | Skill | Key Actions | Handoff Condition | If Step Fails |
|---|---|---|---|---|
| 1. Define Entity | [`define-entity`](skills/define-entity.md) | Create Entity class with dry-types attributes | Entity class exists and is valid | Check dry-types attribute definitions; ensure module nesting matches app namespace |
| 2. Run Migration | [`write-migration`](skills/write-migration.md) | Generate migration; run `hanami db migrate` | Migration applied, schema up-to-date | Check for schema conflicts; roll back with `hanami db rollback` and revise |
| 3. Define Relation | [`define-relation`](skills/define-relation.md) | `schema :table_name, infer: true`; add query methods | Relation queries work in console | Confirm table name matches migration; re-run migration if schema is stale |
| 4. Define Repository | [`create-repository`](skills/create-repository.md) | Implement `all`, `by_id`, `create`, `update`, `delete`; `auto_struct true` | Repository methods return Entities | Verify relation is registered in ROM container; check `auto_struct` setting |
| 5. Create Actions | [`create-action`](skills/create-action.md) | Index, Show, Create, Update, Destroy; inject Repo via `Deps`; validate params; handle errors | All Actions respond to HTTP requests | Check DI key spelling; confirm routes are registered in `config/routes.rb` |
| 6. Create Views | [`create-view`](skills/create-view.md) | `expose` data points; templates in `app/templates/` | Views render without errors | Verify `expose` keys match template variable names |
| 7. Write Tests | [`write-request-spec`](skills/write-request-spec.md) | Happy paths + error cases (404, 422); run full suite | All tests pass | Fix failing specs before proceeding; do not skip to review with red tests |
| 8. Review | [`review-code`](skills/review-code.md) | Check Action responsibility, DI, Repository encapsulation, test coverage | No critical violations | Address critical violations before marking resource complete |

> **Tip:** Run `bundle exec rspec spec/requests/` after Steps 5 and 7 to catch regressions early. If tests fail at any point, fix them before advancing to the next step.

---

## Expected File Structure

After completing all steps, the resource should produce this layout (example: `users`):

```
app/
  entities/
    user.rb                        # Step 1
  db/
    migrate/
      YYYYMMDDHHMMSS_create_users.rb  # Step 2
  relations/
    users.rb                       # Step 3
  repositories/
    users_repository.rb            # Step 4
  actions/
    users/
      index.rb                     # Step 5
      show.rb
      create.rb
      update.rb
      destroy.rb
  views/
    users/
      index.rb                     # Step 6
      show.rb
  templates/
    users/
      index.html.erb
      show.html.erb
spec/
  requests/
    users_spec.rb                  # Step 7
```

---

## Code Examples

### Step 1 — Entity (`app/entities/user.rb`)
```ruby
module MyApp
  module Entities
    class User < Hanami::Entity
      attribute :id,    Types::Integer
      attribute :name,  Types::String
      attribute :email, Types::String
    end
  end
end
```

### Step 3 — Relation (`app/relations/users.rb`)
```ruby
module MyApp
  module Relations
    class Users < ROM::Relation[:sql]
      schema :users, infer: true

      def by_id(id)
        where(id: id)
      end
    end
  end
end
```

### Step 4 — Repository (`app/repositories/users_repository.rb`)
```ruby
module MyApp
  module Repositories
    class UsersRepository < MyApp::Repository[:users]
      def all
        users.to_a
      end

      def by_id(id)
        users.by_id(id).one!
      end

      def create(attrs)
        users.changeset(:create, attrs).commit
      end

      def update(id, attrs)
        users.by_id(id).changeset(:update, attrs).commit
      end

      def delete(id)
        users.by_id(id).delete
      end
    end
  end
end
```

### Step 5 — Action (`app/actions/users/index.rb`)
```ruby
module MyApp
  module Actions
    module Users
      class Index < MyApp::Action
        include Deps[repo: "repositories.users_repository"]

        def handle(request, response)
          response.render view, users: repo.all
        end
      end
    end
  end
end
```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| Starting with Actions and working backwards | Start with the data layer (Entity → Relation → Repository), then the HTTP layer. |
| Skipping the Entity and returning raw hashes | Always define Entities. They are the data contract between layers. |
| Putting all CRUD in one Action class | One Action per endpoint: `Users::Index`, `Users::Show`, etc. |
| Skipping Views for JSON-only APIs | Even JSON APIs benefit from explicit Action structure. Skip Views only if truly API-only. |
| Writing tests only after everything is implemented | Follow the TDD workflow: write failing request specs for each endpoint before implementing. |
