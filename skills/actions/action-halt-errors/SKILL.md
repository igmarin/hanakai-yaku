---
name: action-halt-errors
version: "1.0.0"
license: MIT
description: >
  Use when handling errors and halting requests in Hanami 2.x Actions. Covers
  halt, exception handling, error responses, and status codes.
ecosystem_sources:
  - hanami/hanami-controller
tags:
  - actions
  - errors
  - halt
  - exceptions
---

# action-halt-errors

Use this skill when handling errors and halting requests in Hanami 2.x Actions.

**Core principle:** Fail fast and return meaningful error responses. Never swallow exceptions or leak internal details.

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

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     halt 404, { error: "User not found" }.to_json unless user

     response.render(view, user: user)
   end
   ```

2. **Halt with consistent error shapes**:

   ```ruby
   halt 422, { error: { message: "Validation failed", details: request.params.errors.to_h } }.to_json
   ```

3. **Rescue exceptions and log them**:

   ```ruby
   def handle(request, response)
     result = create_user.call(request.params[:user])
     response.status = 201
     response.body = result.to_json
   rescue StandardError => e
     Hanami.app[:logger].error(e.message)
     Hanami.app[:logger].error(e.backtrace.first(5).join("\n"))
     halt 500, { error: "Internal server error" }.to_json
   end
   ```

4. **Never expose internal details** in error responses. Log the full exception internally, return a generic message externally:

   ```ruby
   # BAD
   halt 500, { error: e.message }.to_json

   # GOOD
   Hanami.app[:logger].error(e.message)
   halt 500, { error: "Internal server error" }.to_json
   ```

5. **Use appropriate status codes**:

   | Code | Meaning | When to use |
   |---|---|---|
   | 400 | Bad Request | Malformed request body |
   | 401 | Unauthorized | Missing authentication |
   | 403 | Forbidden | Insufficient permissions |
   | 404 | Not Found | Resource does not exist |
   | 422 | Unprocessable Entity | Validation errors |
   | 500 | Internal Server Error | Unexpected exception |

6. **Render error Views** for HTML endpoints:

   ```ruby
   def handle(request, response)
     # ...
   rescue MyApp::NotFoundError
     response.status = 404
     response.render(view: :not_found)
   end
   ```

7. **Invalid params halt automatically**. Do not manually check `request.params.valid?` unless you need custom behavior:

   ```ruby
   # Automatic halt with 422 happens before #handle is called
   # Only define custom error handling if needed:
   def handle(request, response)
     if request.params.errors.any?
       response.status = 422
       response.body = { errors: request.params.errors.to_h }.to_json
       return
     end
     # ...
   end
   ```

8. **Test error responses** in request specs. Assert on status codes and error body shapes.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll return the exception message in the response" | Never expose `e.message` or `e.backtrace` to clients. Log internally, return generic externally. |
| "I'll rescue exceptions silently" | Always log rescued exceptions. Silent failures hide bugs. |
| "I'll use `rescue Exception` instead of `rescue StandardError`" | `Exception` catches system-level errors (SIGTERM, OutOfMemory). Only rescue `StandardError`. |
| "I'll forget to set the response status" | Always set `response.status` or use `halt` with a status code. Default 200 is wrong for errors. |
| "I'll manually validate params instead of using the DSL" | The Params DSL automatically halts on invalid input. Do not duplicate validation in `#handle`. |
| "I'll use `halt` with HTML error messages in JSON APIs" | Match error response format to the endpoint format. JSON APIs return JSON errors. |

---

## Red Flags

- Exception messages exposed in HTTP responses
- Silent exception rescuing without logging
- `rescue Exception` instead of `rescue StandardError`
- Error responses without appropriate status codes
- Manual param validation duplicating the Params DSL
- Inconsistent error response shapes across endpoints
- Stack traces sent to clients

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | Error handling is part of Action implementation. Master Action structure first. |
| **action-params-validation** | Invalid params trigger automatic halts. Understand the Params DSL before handling errors. |
| **action-json-api** | JSON APIs return JSON error responses with consistent shapes. |
| **security-review** | Error handling should not leak sensitive information or system details. |
| **request-specs** (testing) | Test error responses (404, 422, 500) in request specs. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Error Handling) |
|---|---|
| `rescue_from ActiveRecord::RecordNotFound, with: :not_found` | `rescue` in `#handle` or `halt 404` |
| `head :not_found` | `halt 404, { error: "Not found" }.to_json` |
| `render json: { error: "..." }, status: 422` | `halt 422, { error: "..." }.to_json` |
| `Rails.logger.error(e.message)` | `Hanami.app[:logger].error(e.message)` |
| `raise ActiveRecord::RecordInvalid` | Return `Failure` from interactor or `halt 422` |
| `rescue_from StandardError` | `rescue StandardError` in `#handle` |
