# Pattern Sampling Guide

How to sample established patterns from a Hanami app without reading every file.

## Action Pattern

Read 2-3 actions across different slices. Note:

```ruby
# Example: slices/api/actions/users/create.rb
module Api
  module Actions
    module Users
      class Create < Api::Action
        include Deps["operations.users.create_user"]

        def handle(req, res)
          result = create_user.call(req.params.to_h)
          case result
          when Dry::Monads::Success
            res.status = 201
            res.body = result.value!.to_json
          when Dry::Monads::Failure
            res.status = 422
            res.body = { errors: result.failure }.to_json
          end
        end
      end
    end
  end
end
```

**Checklist:**
- Does the action use `include Deps[...]`?
- Does it delegate to an operation?
- What response contract does it use? (Success/Failure pattern?)
- What status codes map to what outcomes?

## Operation Pattern

Read 2-3 operations. Note:

- dry-operation vs dry-transaction?
- Step naming conventions?
- How are failures handled? (Failure monad, custom error types?)
- Do operations compose other operations?

## Repository Pattern

Read 2-3 repositories. Note:

- Query method naming conventions? (e.g., `by_email`, `active_since`)
- Do repositories return ROM relations or materialized arrays?
- Custom types usage in queries?

## DI Convention

Check if the app uses:

```ruby
include Deps["operations.users.create_user"]
# or
include Deps["repositories.user_repo"]
# or
include Deps[...]  # auto-injected
```

Note the naming convention for registered components.
