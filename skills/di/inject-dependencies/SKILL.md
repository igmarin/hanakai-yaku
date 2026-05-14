---
name: inject-dependencies
version: "1.0.0"
license: MIT
description: >
  Use when injecting dependencies in Hanami 2.x. Covers include Deps[],
  container keys, auto-registration rules, no_auto_register_paths, and testing with stubs.
ecosystem_sources:
  - dry-rb/dry-system
  - hanami/hanami
tags:
  - di
  - dependencies
  - container
  - deps
---

# inject-dependencies

Use this skill when injecting dependencies into Hanami 2.x components.

**Core principle:** Dependencies are injected, not looked up. Never access the container directly — always use `include Deps[]`.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Inject a dependency | `include Deps["repos.user_repo"]` |
| Inject multiple dependencies | `include Deps["repos.user_repo", "views.users.index"]` |
| Access injected dependency | Call the method name matching the last segment of the key: `user_repo` |
| Auto-registered key | File `app/repos/user_repo.rb` → key `"repos.user_repo"` |
| Exclude from auto-registration | Add path to `no_auto_register_paths` in the slice config |
| Test with stubs | Pass stubbed dependencies when instantiating the component |
| Override dependency | Pass the dependency as a keyword argument to `.new` |

---

## Core Rules

1. **Always use `include Deps[]`** to inject dependencies:

   ```ruby
   # app/actions/users/index.rb
   # frozen_string_literal: true

   module MyApp
     module Actions
       module Users
         class Index < MyApp::Action
           include Deps["repos.user_repo"]

           def handle(request, response)
             response.render(view, users: user_repo.all)
           end
         end
       end
     end
   end
   ```

2. **The container key is derived from the file path**:

   ```
   app/repos/user_repo.rb     → "repos.user_repo"
   app/views/users/index.rb   → "views.users.index"
   app/relations/users.rb     → "relations.users"
   ```

   Rule: `app/{dir}/{name}.rb` maps to container key `"{dir}.{name}"`.

3. **Certain directories are excluded from auto-registration** because ROM manages them directly:

   - `relations/`
   - `structs/`
   - `entities/`

   These are handled by ROM and should not be auto-registered by dry-system.

4. **Add custom exclusions** in the slice configuration:

   ```ruby
   # config/app.rb
   # frozen_string_literal: true

   module MyApp
     class App < Hanami::App
       config.no_auto_register_paths = ["app/serializers"]
     end
   end
   ```

5. **Inject multiple dependencies** at once:

   ```ruby
   include Deps[
     "repos.user_repo",
     "repos.post_repo",
     "views.users.show"
   ]
   ```

6. **Access injected dependencies** by the last segment of the key:

   ```ruby
   include Deps["repos.user_repo"]
   # Access via: user_repo
   ```

7. **Override dependencies in tests** by passing them to `.new`:

   ```ruby
   stub_repo = double("user_repo", all: [])
   action = MyApp::Actions::Users::Index.new(user_repo: stub_repo)
   ```

8. **Never access the container directly**:

   ```ruby
   # BAD
   repo = Hanami.app["repos.user_repo"]

   # GOOD
   include Deps["repos.user_repo"]
   # use user_repo directly
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll call `Hanami.app['key']` inside the Action" | Direct container access is untestable and hides dependencies. Always use `include Deps[]`. |
| "I'll guess the container key instead of following the file path rule" | Keys follow `app/{dir}/{name}.rb` → `"{dir}.{name}"`. Learn the rule, do not guess. |
| "I'll auto-register relations/ or entities/ directories" | These are managed by ROM. Adding them to auto-registration causes boot errors. |
| "I'll inject dependencies in the constructor instead of using Deps" | `Deps` mixin handles constructor injection for you. Do not write custom `initialize` methods for DI. |
| "I'll forget to update tests when I rename a container key" | When you move a file, the container key changes. Update all `Deps[]` references and test stubs. |
| "I'll pass the full key name when accessing the dependency" | Access by the last segment: `include Deps["repos.user_repo"]` → use `user_repo`, not `repos.user_repo`. |

---

## Red Flags

- Direct container access (`Hanami.app['key']`)
- Custom `initialize` methods for dependency injection
- Auto-registration of `relations/`, `structs/`, or `entities/`
- Guessing container keys instead of following the path rule
- Tests that instantiate components without providing required dependencies
- Dependency names that don't match the last segment of the container key

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Actions inject Repositories and Views via `Deps`. |
| **create-repository** | Repositories are injected into Actions using their container key. |
| **create-view** | Views are injected into Actions using their container key. |
| **register-provider** | Providers register external dependencies that are then injected via `Deps`. |
| **write-action-spec** (testing) | Test Actions by stubbing injected dependencies. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Deps) |
|---|---|
| `User.find(params[:id])` (implicit global model access) | `include Deps["repos.user_repo"]; user_repo.by_id(id).one` (explicit injection) |
| `before_action :set_user` | `include Deps["repos.user_repo"]` and call `user_repo` in `#handle` |
| `helper_method :current_user` | Inject an authentication service via `Deps` |
| `ApplicationController` shared dependencies | Each Action explicitly declares its own `Deps` |
| `Rails.application.routes.url_helpers` | Inject route helpers via `Deps` if needed |
| `Thread.current[:current_user]` | Not used. Pass context explicitly via arguments or injection. |
