---
name: review-code
version: "1.0.0"
license: MIT
description: >
  Use when reviewing Hanami 2.x code. Covers single-responsibility Actions,
  proper DI usage, no direct container access, and ROM query encapsulation in Repositories.
ecosystem_sources:
  - hanami/hanami
tags:
  - code-review
  - quality
  - conventions
  - review
---

# code-review

Use this skill when reviewing Hanami 2.x code for quality and convention adherence.

**Core principle:** Code review catches architectural violations, not just bugs. Focus on structure, boundaries, and testability.

---

## Quick Reference

| Concern | Check |
|---|---|
| Action responsibility | One Action = one endpoint. No business logic. |
| Dependency injection | `include Deps[]` used? No direct container access? |
| Repository encapsulation | All queries in Repositories/Relations? No SQL in Actions? |
| Entity usage | Entities returned from Repositories? No raw hashes passed to Views? |
| View simplicity | No DB queries in Views? No business logic in `expose` blocks? |
| Test coverage | Request specs for endpoints? Unit specs for complex logic? |
| Error handling | Meaningful error responses? No exception message leakage? |
| Settings usage | No `ENV` access? Settings used for configuration? |

---

## Core Rules

1. **Actions must be single-responsibility HTTP handlers**:

   ```ruby
   # GOOD: Action delegates to Repository and renders View
   class Index < MyApp::Action
     include Deps["repos.user_repo"]
     def handle(request, response)
       response.render(view, users: user_repo.all)
     end
   end

   # BAD: Action contains business logic
   class Index < MyApp::Action
     def handle(request, response)
       users = UserRelation.new(Hanami.app["db.rom"]).all
       active_users = users.select { |u| u.status == "active" }
       # ... more logic ...
       response.render(view, users: active_users)
     end
   end
   ```

2. **Dependencies must be injected via `Deps`**:

   ```ruby
   # GOOD: Injected via Deps
   include Deps["repos.user_repo"]

   # BAD: Direct container access
   repo = Hanami.app["repos.user_repo"]
   ```

3. **All database queries must be in Repositories or Relations**:

   ```ruby
   # GOOD: Query in Repository
   class UserRepo < Hanami::DB::Repo[:users]
     def active
       users.where(status: "active").to_a
     end
   end

   # BAD: SQL in Action
   users = Hanami.app["db.rom"].gateways[:default].dataset(:users)
     .where(status: "active")
     .to_a
   ```

4. **Repositories must return Entities, not raw hashes**:

   ```ruby
   # GOOD: Returns Entity
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end

   # BAD: Returns raw hash
   def find(id)
     users.where(id: id).one.to_h
   end
   ```

5. **Views must not contain database queries or business logic**:

   ```ruby
   # GOOD: View receives prepared data
   class Show < MyApp::View
     expose :user
   end

   # BAD: View queries the database
   class Show < MyApp::View
     expose :user do |request|
       Hanami.app["repos.user_repo"].by_id(request.params[:id]).one
     end
   end
   ```

6. **Tests must cover behavior, not implementation**:

   ```ruby
   # GOOD: Tests behavior
   it "returns active users" do
     get "/users?status=active"
     expect(json_body[:users].length).to eq(2)
   end

   # BAD: Tests implementation
   it "calls user_repo.active" do
     expect(user_repo).to receive(:active)
     action.call({})
   end
   ```

7. **Error responses must be meaningful and not leak internals**:

   ```ruby
   # GOOD: Generic error message, details logged
   rescue StandardError => e
     Hanami.app[:logger].error(e.message)
     halt 500, { error: "Internal server error" }.to_json
   end

   # BAD: Leaks exception details
   rescue StandardError => e
     halt 500, { error: e.message, backtrace: e.backtrace }.to_json
   end
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "The Action has 50 lines of business logic" | Actions should be < 10 lines. Extract logic to service objects or interactors. |
| "The Action accesses `Hanami.app['key']` directly" | All dependencies must be injected via `Deps[]`. |
| "SQL fragments appear in Actions or Views" | All queries belong in Relations or Repositories. |
| "Repositories return raw hashes" | Repositories must return Entity objects with `auto_struct true`. |
| "Views query the database" | Views receive data from Actions. No queries in Views. |
| "Exception messages exposed in HTTP responses" | Log internally. Return generic messages externally. |
| "Missing tests for error paths" | Every endpoint must have tests for 400, 404, 422, and 500 cases. |

---

## Red Flags

- Actions with > 10 lines of business logic
- Direct container access (`Hanami.app['key']`)
- SQL or query logic in Actions/Views
- Raw hashes returned from Repositories
- Database queries in Views
- Exception details in HTTP responses
- Missing error path tests
- Untested edge cases

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Review Action structure and responsibility. |
| **inject-dependencies** | Verify proper DI usage. |
| **create-repository** | Verify query encapsulation in Repositories. |
| **create-view** | Verify View simplicity and no DB access. |
| **write-request-spec** | Verify test coverage for all endpoints. |
| **review-security** | Cross-reference security concerns during code review. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Code Review Focus) |
|---|---|
| Fat controllers | Single-responsibility Actions |
| `before_action` callbacks | `Deps` injection and explicit method calls |
| `ApplicationController` shared logic | Each Action declares its own dependencies |
| `Model.find` in controllers | Repository methods injected via `Deps` |
| `render @users` | `response.render(view, users: user_repo.all)` |
| `helper_method` | Part methods or View exposures |
| `rescue_from` in ApplicationController | `rescue` in individual Actions |
