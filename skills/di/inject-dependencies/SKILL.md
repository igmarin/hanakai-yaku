---
name: inject-dependencies
license: MIT
description: >
  Use when injecting dependencies in Hanami 2.x. Covers include Deps[], container
  keys, auto-registration rules, no_auto_register_paths, and testing with stubs.
metadata:
  ecosystem_sources:
  - dry-rb/dry-system
  - hanami/hanami
  tags:
  - di
  - dependencies
  - container
  - deps
  version: 1.0.0
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
              # `view` is resolved by Hanami from the Action class name convention
              response.render(view, users: user_repo.all)
            end
         end
       end
     end
   end
   ```

2. **The container key is derived from the file path**:

   ```text
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

5. **Override dependencies in tests** by passing them to `.new`:

   ```ruby
   stub_repo = double("user_repo", all: [])
   action = MyApp::Actions::Users::Index.new(user_repo: stub_repo)
   ```

6. **Never access the container directly**:

   ```ruby
   # BAD
   repo = Hanami.app["repos.user_repo"]

   # GOOD
   include Deps["repos.user_repo"]
   # use user_repo directly
   ```

---

## Anti-Patterns & Mistakes

| Mistake | Correct Approach |
|---|---|
| `Hanami.app['key']` inside an Action | Direct container access is untestable. Always use `include Deps[]`. |
| Guessing container keys | Keys follow `app/{dir}/{name}.rb` → `"{dir}.{name}"`. Learn the rule, do not guess. |
| Auto-registering `relations/`, `structs/`, or `entities/` | These are managed by ROM. Adding them to auto-registration causes boot errors. |
| Custom `initialize` for dependency injection | `Deps` mixin handles constructor injection for you. Do not write custom `initialize` methods for DI. |
| Forgetting to update tests after renaming a file | When you move a file, the container key changes. Update all `Deps[]` references and test stubs. |
| Accessing the full key name as a method | Access by the last segment only: `include Deps["repos.user_repo"]` → use `user_repo`. |
