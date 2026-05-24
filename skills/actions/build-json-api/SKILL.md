---
name: build-json-api
license: MIT
description: >
  Use when building JSON API responses, REST API endpoints, or Hanami action responses
  in Hanami 2.x Actions. Covers setting content-type headers, serializing Ruby objects
  to JSON, parsing incoming JSON request bodies, content negotiation, and round-trip
  parse → serialize → parse verification. Use when you need to render JSON, build
  a JSON endpoint, create an API controller action, or handle JSON request/response
  cycles in Hanami 2.x.
metadata:
  ecosystem_sources:
  - hanami/hanami-controller
  tags:
  - actions
  - json
  - api
  - serialization
  version: 1.0.0
---

# build-json-api

Use this skill when building JSON API endpoints in Hanami 2.x Actions.

**Core principle:** JSON APIs must produce predictable, parseable output. Implement round-trip parse → serialize → parse verification for all serializers.

---

## Core Rules

1. **Set the response format** to JSON:

   ```ruby
   def handle(request, response)
     response.format = :json
     # ...
   end
   ```

2. **Use dedicated serializers** to encode response bodies:
   Isolate serialization representation from your Actions. Instantiating a dedicated serializer class keeps action handlers clean. For implementation details and conventions, see [SERIALIZERS.md](SERIALIZERS.md).

   ```ruby
   def handle(request, response)
     response.format = :json
     user = user_repo.by_id(request.params[:id]).one
     
     response.body = MyApp::Serializers::UserSerializer.new(user).to_json
   end
   ```

3. **Verify round-trip serialization**:
   Always assert that a serialized object can be parsed back into equivalent data to prevent schema regressions. For the step-by-step troubleshooting workflow, see the [SERIALIZERS.md Verification Guide](SERIALIZERS.md#round-trip-verification-workflow).

   ```ruby
   # In tests:
   serialized = UserSerializer.new(user).to_json
   parsed = JSON.parse(serialized, symbolize_names: true)

   assert_equal user.email, parsed[:email]
   ```

4. **Handle request body parsing** via `request.params`:
   JSON request payloads are automatically parsed by the framework and accessible directly under params.

   ```ruby
   def handle(request, response)
     response.format = :json
     attrs = request.params[:user]
     result = user_repo.create(attrs)

     response.status = 201
     response.body = UserSerializer.new(result).to_json
   end
   ```

5. **Return consistent error shapes**:
   Ensure all error responses conform to a unified structure:

   ```ruby
   halt 422, { error: { message: "Validation failed", details: [...] } }.to_json
   ```

6. **Include pagination metadata** for collections:
   Expose pagination fields inside a `meta` block sibling to `data`:

   ```ruby
   {
     data: users.map { |u| UserSerializer.new(u).to_h },
     meta: {
       page: request.params[:page] || 1,
       per_page: request.params[:per_page] || 20,
       total: user_repo.count
     }
   }.to_json
   ```

7. **Rescue parse errors** and return bad request (400) status:

   ```ruby
   rescue JSON::ParserError
     halt 400, { error: "Invalid JSON body" }.to_json
   end
   ```

---

## Checklist: Common Mistakes & Red Flags

- [ ] `response.format = :json` is set on every JSON action
- [ ] Every entity is serialized through a dedicated serializer class — never raw repository structures
- [ ] Round-trip parse → serialize → parse verified for all serializers
- [ ] Timestamps formatted to ISO 8601 via `.iso8601`
- [ ] Error responses follow a consistent shape (`{ error: { message: ..., details: ... } }`)
- [ ] `JSON::ParserError` rescued with 400 response

