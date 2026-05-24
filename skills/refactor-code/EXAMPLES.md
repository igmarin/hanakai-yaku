# Code Refactoring - Detailed Class Examples

This document lists the complete, extracted component implementations designed to slim down complex Hanami Actions.

---

## 1. dry-validation Contract

Define request parameter validation rules inside a dedicated Contract:

```ruby
# app/contracts/user_contract.rb
# frozen_string_literal: true

module MyApp
  module Contracts
    class UserContract < Dry::Validation::Contract
      params do
        required(:email).value(:string, format?: /\A.+@.+\z/)
        required(:first_name).value(:string, min_size?: 1)
      end
    end
  end
end
```

---

## 2. Extracted Operation Service

Handle core business logic database persistence using dry-monads results:

```ruby
# app/operations/create_user.rb
# frozen_string_literal: true

module MyApp
  module Operations
    class CreateUser
      include Dry::Monads[:result]
      include Deps["repos.user_repo"]

      def call(attrs)
        user = user_repo.create(attrs)
        Success(user)
      rescue StandardError => e
        Failure("Database error: #{e.message}")
      end
    end
  end
end
```

---

## 3. Side Effect Interactor

Isolate external integrations (like mailers or API webhooks) into dedicated interactors:

```ruby
# app/operations/send_welcome_email.rb
# frozen_string_literal: true

module MyApp
  module Operations
    class SendWelcomeEmail
      include Deps["mailer"]

      def call(user)
        mailer.deliver(
          to: user.email,
          subject: "Welcome",
          body: "Welcome, #{user.first_name}!"
        )
      end
    end
  end
end
```

---

## 4. DI Provider Registration

Register your contracts and operations inside container providers to expose them to Auto-Injection:

```ruby
# config/providers/operations.rb
# frozen_string_literal: true

Hanami.app.register_provider(:operations) do
  start do
    register("contracts.user", MyApp::Contracts::UserContract.new)
    register("operations.create_user", MyApp::Operations::CreateUser.new)
    register("operations.send_welcome_email", MyApp::Operations::SendWelcomeEmail.new)
  end
end
```
