---
name: refactor-code
license: MIT
description: >
  Use when refactoring Hanami 2.x code, slimming down fat actions, moving business
  logic out of actions, or performing a Hanami refactor with dependency injection.
  Extracts logic from Actions into interactors or service objects, registers dependencies
  in the DI container, updates auto-injection via `Deps`, applies dry-validation Contracts
  for extracted validation, and restructures repeated logic into modules or base classes.
  Use when a developer asks to extract class, slim down Hanami controllers, reduce
  fat actions, or reorganise Hanami slices.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - refactoring
  - extraction
  - service-objects
  - interactors
  version: 1.0.0
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

1. **Identify extraction candidates**:
   Locate Actions containing inline validations, complex repo queries, or multiple side effects (emails, notifications).

2. **Extract concerns into dedicated objects**:
   Extract validations to Contracts, business logic to Operation services, and side effects to interactors. For detailed implementations of these extracted classes, see the [EXAMPLES.md Guide](EXAMPLES.md).

3. **Simplify the Action class**:
   Inject the extracted objects via auto-injection (`Deps`) and delegate responsibilities:

   ```ruby
   # AFTER: Cleaned Action delegating to operations
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

4. **Register in the container**:
   Ensure all new classes are registered in a container provider so they are discoverable for injection. See [EXAMPLES.md Provider Registration](EXAMPLES.md#4-di-provider-registration).

5. **Write characterization tests first**:
   Always capture current behavior in request specs before touching code.

6. **Verify the full suite after**:
   Run the test suite to ensure refactoring didn't alter behavior.

---

## Common Mistakes

- **Circular Dependencies:** Ensure extracted components have acyclic dependencies. Use the container to resolve dependencies, not tight constructor nesting.
- **Over-extraction:** Only extract when logic is complex or reusable. Simple CRUD actions do not need separate operations.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Action creation precedes refactoring. |
| **inject-dependencies** | Register and inject extracted components via `Deps`. |
| **handle-result-pattern** | Operations return monadic `Success`/`Failure`. |
| **plan-tests** | Write characterization specs before altering code. |
