---
name: refactor-code
version: "1.0.0"
license: MIT
description: >
  Use when refactoring Hanami 2.x code. Covers extraction of logic from Actions
  into interactors or service objects registered in the DI container.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - refactoring
  - extraction
  - service-objects
  - interactors
---

# refactoring

Use this skill when refactoring Hanami 2.x code to improve structure and maintainability.

**Core principle:** Refactoring preserves behavior. Extract logic from Actions into testable, reusable service objects.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Extract from Action | Move business logic to a service object, inject via `Deps` |
| Extract complex query | Move query to Repository method |
| Extract validation | Use dry-validation Contract |
| Extract side effects | Move to an interactor (email, notifications) |
| Extract repeated logic | Create a module or base class |
| Preserve behavior | Run full test suite before and after refactoring |
| Characterization test | Write a test that captures current behavior before changing code |

---

## Core Rules

1. **Identify extraction candidates** in Actions:

   ```ruby
   # BEFORE: Action with too much logic
   class Create < MyApp::Action
     include Deps["repos.user_repo", "mailer"]

     def handle(request, response)
       attrs = request.params[:user]

       # Validation logic
       return halt 422 unless attrs[:email].include?("@")

       # Business logic
       user = user_repo.create(attrs)

       # Side effect
       mailer.deliver(
         to: user.email,
         subject: "Welcome",
         body: "Welcome, #{user.first_name}!"
       )

       # Notification logic
       admin_notification.send("New user: #{user.email}")

       response.status = 201
       response.body = user.to_json
     end
   end
   ```

2. **Extract validation to a Contract**:

   ```ruby
   # app/contracts/user_contract.rb
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

3. **Extract business logic to a service object**:

   ```ruby
   # app/operations/create_user.rb
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

4. **Extract side effects to an interactor**:

   ```ruby
   # app/operations/send_welcome_email.rb
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

5. **Refactor the Action** to use extracted components:

   ```ruby
   # AFTER: Clean Action
   class Create < MyApp::Action
     include Deps[
       "contracts.user",
       "operations.create_user",
       "operations.send_welcome_email"
     ]

     def handle(request, response)
       validation = contract.call(request.params[:user])
       halt 422, validation.errors.to_h.to_json if validation.failure?

       result = create_user.call(validation.to_h)
       case result
       in Success(user)
         send_welcome_email.call(user)
         response.status = 201
         response.body = user.to_json
       in Failure(error)
         response.status = 422
         response.body = { error: error }.to_json
       end
     end
   end
   ```

6. **Register extracted components** in the container:

   ```ruby
   # config/providers/operations.rb
   Hanami.app.register_provider(:operations) do
     start do
       register("contracts.user", MyApp::Contracts::UserContract.new)
       register("operations.create_user", MyApp::Operations::CreateUser.new)
       register("operations.send_welcome_email", MyApp::Operations::SendWelcomeEmail.new)
     end
   end
   ```

7. **Write characterization tests** before refactoring:

   ```ruby
   # Capture current behavior
   it "creates a user and sends email" do
     post "/users", { user: valid_attrs }.to_json, { "CONTENT_TYPE" => "application/json" }

     expect(last_response.status).to eq(201)
     expect(Mailer.deliveries.last.to).to include("alice@example.com")
   end
   ```

8. **Run the full test suite** after refactoring. All tests must pass without modification.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll refactor without tests" | Never refactor without a passing test suite. Write characterization tests first. |
| "I'll extract too many tiny service objects" | Extract when logic is complex, reusable, or has side effects. Simple Actions do not need extraction. |
| "I'll forget to register extracted components" | Extracted components must be registered in the DI container to be injected. |
| "I'll change behavior during refactoring" | Refactoring preserves behavior. If behavior changes, it's not refactoring — it's a feature change. |
| "I'll extract logic but leave the Action untouched" | The Action must be updated to use the extracted component via `Deps`. |
| "I'll create circular dependencies between extracted objects" | Extracted components should have clear, acyclic dependencies. |

---

## Red Flags

- Refactoring without tests
- Over-extraction (too many tiny objects)
- Extracted components not registered in DI container
- Behavior changes during "refactoring"
- Actions not updated to use extracted components
- Circular dependencies between service objects
- Missing tests for extracted components

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Identify extraction candidates in Actions. |
| **inject-dependencies** | Register and inject extracted components via `Deps`. |
| **dry-monads/handle-result-pattern** | Service objects often return `Success`/`Failure`. |
| **create-repository** | Extract complex queries to Repository methods. |
| **plan-tests** | Write characterization tests before refactoring. |
| **write-request-spec** | Verify full stack behavior after refactoring. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Refactoring) |
|---|---|
| Extract to Service Object | Extract to service object + register in DI container |
| Extract to Form Object | Extract to dry-validation Contract |
| `ActiveRecord::Base` callbacks | Explicit interactor/service object calls |
| `after_create :send_email` | `send_welcome_email.call(user)` in Action or interactor |
| `before_action :authenticate` | `include Deps["authentication"]` + explicit auth check |
| Fat controller → Skinny controller | Fat Action → Extracted service objects |
| `ApplicationController` helpers | Extract to modules or base classes, inject via `Deps` |
