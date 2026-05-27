---
name: review-code
license: MIT
description: >
  Use when reviewing Hanami 2.x code for quality and convention adherence — check Action responsibility at ≤~10 lines delegating business logic, verify DI via `include Deps[]` with no `Hanami.app["key"]` direct access, audit query locations ensuring all DB queries live in Repositories/Relations, inspect Repositories returning Entities not raw hashes, review Views receiving pre-fetched data only, check error handling logging+generic messages without exposing e.message, and assess test coverage for 400/404/422/500 paths. Triggers on phrases
  like 'review my Hanami code', 'check my action', 'code review', or 'dry-rb patterns'.
metadata:
  ecosystem_sources:
  - hanami/hanami
  tags:
  - code-review
  - quality
  - conventions
  - review
  version: 1.0.0
---

# review-code

Use this skill when reviewing Hanami 2.x code for quality and convention adherence.

**Core principle:** Code review catches architectural violations, not just bugs. Focus on structure, boundaries, and testability.

---

## Quick Reference

| Concern | Rule | Priority |
|---|---|---|
| Action responsibility | One Action = one endpoint. No business logic. ≤ ~10 lines of logic. | Blocker if logic leaks |
| Dependency injection | `include Deps[]` only. No `Hanami.app['key']` direct access. | Blocker |
| Query location | All DB queries in Repositories/Relations. No SQL in Actions or Views. | Blocker |
| Repository return types | Return Entities (`auto_struct true`, `struct_namespace`). No raw hashes. | High |
| View simplicity | `expose` blocks receive pre-fetched data only. No DB calls or business logic. | Blocker if DB in View |
| Error handling | Log and return generic messages. No `e.message`/`e.backtrace` in responses. | Blocker |
| Test coverage | Request specs per endpoint. Test 400, 404, 422, 500 paths. Behavior, not implementation. | High |
| Settings usage | No `ENV` access. Use Settings for configuration. | Suggestion |

---

## Review Workflow

Follow this sequence and report violations in priority order:

1. **Check Action responsibility** — Is the Action ≤ ~10 lines? Does it delegate business logic to services or repositories? Flag any SQL, filtering, or domain logic inline in the Action.
2. **Verify DI usage** — Are all dependencies declared via `include Deps[...]`? Flag any `Hanami.app['key']` direct access.
3. **Audit query locations** — Do all DB queries live in Repositories or Relations? Flag SQL in Actions or Views immediately.
4. **Inspect Repositories** — Do they return Entities (not raw hashes)? Is `auto_struct true` / `struct_namespace` configured?
5. **Review Views** — Do `expose` blocks receive pre-fetched data only? Flag any DB calls or business logic.
6. **Check error handling** — Are exceptions logged and generic messages returned? Flag any `e.message` or `e.backtrace` in responses.
7. **Assess test coverage** — Are there request specs for each endpoint? Are 400, 404, 422, and 500 paths tested?

For each violation found, report: **location**, **rule broken**, **concrete fix** (with code where helpful), and **priority** (blocker if it exposes internals or bypasses DI; suggestion otherwise).

---

## Core Rules with Examples

**1. Actions — single-responsibility, delegate logic:**

```ruby
# GOOD
class Index < MyApp::Action
  include Deps["repos.user_repo"]
  def handle(request, response)
    response.render(view, users: user_repo.all)
  end
end

# BAD — business logic and direct ROM access in Action
users = Hanami.app["db.rom"].gateways[:default].dataset(:users).where(status: "active").to_a
active_users = users.select { |u| u.status == "active" }
```

**2. Dependencies — always via `Deps`, never direct container:**

```ruby
# GOOD
include Deps["repos.user_repo"]

# BAD
repo = Hanami.app["repos.user_repo"]
```

**3. Repositories — return Entities, not raw hashes:**

```ruby
# GOOD
class UserRepo < Hanami::DB::Repo[:users]
  struct_namespace MyApp::Entities
  auto_struct true
end

# BAD
def find(id) = users.where(id: id).one.to_h
```

**4. Views — no DB queries or business logic in `expose`:**

```ruby
# GOOD
expose :user  # receives pre-fetched entity from Action

# BAD
expose :user do |request|
  Hanami.app["repos.user_repo"].by_id(request.params[:id]).one
end
```

**5. Error handling — log details, return generic messages:**

```ruby
# GOOD
rescue StandardError => e
  Hanami.app[:logger].error(e.message)
  halt 500, { error: "Internal server error" }.to_json
end

# BAD — leaks internals
halt 500, { error: e.message, backtrace: e.backtrace }.to_json
```

**6. Tests — cover behavior and all error paths:**

```ruby
# GOOD
it "returns 404 for unknown user" do
  get "/users/9999"
  expect(last_response.status).to eq(404)
end

# BAD — tests implementation, not behavior
expect(user_repo).to receive(:active)
```

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
| **review-process** *(from ruby-core-skills)* | Severity levels, structured findings format, re-review criteria. |
