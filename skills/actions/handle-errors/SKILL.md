---
name: handle-errors
license: MIT
description: >
  Use when handling errors and halting requests in Hanami 2.x Actions — fail fast with `halt STATUS, {error:}.to_json` for early returns, rescue `StandardError` (never `Exception`) logging full details internally but returning generic messages to clients, let invalid params halt automatically with 422 before `#handle` runs without manual `params.valid?` checks, and match error response format to action format (no HTML errors in JSON actions). Demonstrates halt status codes (404, 422, 500), rescue patterns, and consistent error shapes.
  Use when implementing error handling patterns, exception handling, or returning
  JSON error responses in Hanami actions.
metadata:
  ecosystem_sources:
  - hanami/hanami-controller
  tags:
  - actions
  - errors
  - halt
  - exceptions
  version: "1.0.0"
---

# handle-errors

Use this skill when handling errors and halting requests in Hanami 2.x Actions.

**Core principle:** Fail fast and return meaningful error responses. Never swallow exceptions or leak internal details.

---

## Decision Tree

```
Request arrives at Action
       |
       v
Params invalid? ──yes──> Automatic halt 422 (before #handle is called)
       |
      no
       v
Resource not found? ──yes──> halt 404, { error: "Not found" }.to_json
       |
      no
       v
Unauthorized / Forbidden? ──yes──> halt 401 or halt 403 with JSON error
       |
      no
       v
Unexpected exception? ──yes──> rescue StandardError → log → halt 500
       |
      no
       v
Success → set response.status + response.body
```

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Early return with status | `halt 404, { error: "Not found" }.to_json` |
| Halt for validation errors | Invalid params halt automatically with 422 |
| Halt for unauthorized | `halt 401, { error: "Unauthorized" }.to_json` |
| Halt for forbidden | `halt 403, { error: "Forbidden" }.to_json` |
| Rescue exceptions | `rescue` in `#handle` with logging and generic error response |
| Custom error page | Render a View for 404/500 errors |
| Set status code | `response.status = 201` |
| Log errors | `Hanami.app[:logger].error(exception)` |

---

## Core Rules

1. **Use `halt` for early returns**:
   Halt immediately with a status code and response body for early returns. Do not rely on default success status codes (e.g. 200) for error conditions.

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     halt 404, { error: "User not found" }.to_json unless user

     response.render(view, user: user)
   end
   ```

   > [!CAUTION]
   > **Common Mistake:** Match the error response format to the action format. Do not use `halt` with HTML error pages/strings in a JSON API action.

2. **Halt with consistent error shapes**:
   Ensure all JSON error payloads conform to a unified schema (e.g., `{ error: { message: "...", details: ... } }`).

   ```ruby
   halt 422, { error: { message: "Validation failed", details: request.params.errors.to_h } }.to_json
   ```

3. **Rescue exceptions, log them, and keep details internal**:
   Always rescue `StandardError` (never rescue `Exception` as it catches system-level interrupts like `SIGTERM` or `NoMemoryError`). Log full backtraces internally, but return generic messages externally. Never rescue exceptions silently.

   ```ruby
   def handle(request, response)
     result = create_user.call(request.params[:user])
     response.status = 201
     response.body = result.to_json
   rescue StandardError => e
     # GOOD: Log full details internally
     Hanami.app[:logger].error(e.message)
     Hanami.app[:logger].error(e.backtrace.first(5).join("\n"))
     
     # GOOD: Return generic error message to client
     halt 500, { error: "Internal server error" }.to_json
   end
   ```

   > [!WARNING]
   > **Anti-pattern:** Exposing `e.message` or `e.backtrace` to HTTP clients. This leaks system internals and database schema details.

4. **Render error Views for HTML endpoints**:
   Set `response.status` explicitly and render specialized error views instead of returning raw strings or JSON.

   ```ruby
   def handle(request, response)
     # ...
   rescue MyApp::NotFoundError
     response.status = 404
     response.render(view: :not_found)
   end
   ```

5. **Let invalid params halt automatically**:
   Do not manually inspect `request.params.valid?` or duplicate validation inside `#handle`. The action automatically halts with `422 Unprocessable Entity` before `#handle` runs if params validation fails.

   ```ruby
   # No manual validation checks needed here for standard param schemas
   def handle(request, response)
     # Proceed directly with valid params...
   end
   ```

6. **Test error states in request specs**:
   Always write tests asserting on expected HTTP error status codes (e.g., 404, 422, 500) and verified error payload shapes.

---

## Code Review Checklist

Reviewers should check for these red flags:
- [ ] Exception messages or backtraces returned in HTTP responses.
- [ ] Silent exception rescues (`rescue StandardError => e` without logging).
- [ ] Broad rescues of the base `Exception` class instead of `StandardError`.
- [ ] Manual param validation duplicating rules defined in the action's `params` block.
- [ ] Mismatched format types (e.g. HTML error responses in JSON action routes).

---


## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Error handling is part of Action implementation. Master Action structure first. |
| **validate-params** | Invalid params trigger automatic halts. Understand the Params DSL before handling errors. |
| **build-json-api** | JSON APIs return JSON error responses with consistent shapes. |
| **review-security** | Error handling should not leak sensitive information or system details. |
| **write-request-spec** (testing) | Test error responses (404, 422, 500) in request specs. |
