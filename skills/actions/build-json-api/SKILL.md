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

---

## End-to-End Workflow: Creating a JSON Endpoint

1. **Create the action** and set `response.format = :json`
2. **Add a dedicated serializer** for the entity being returned
3. **Write a round-trip test** asserting serialize → parse produces correct fields
4. **Verify**: run the test; fix serializer if fields are missing or misformatted

---

## Core Rules

1. **Set the response format** to JSON:

   ```ruby
   def handle(request, response)
     response.format = :json
     # ...
   end
   ```

2. **Use dedicated serializers** to encode response bodies.
   For implementation details and conventions, see [SERIALIZERS.md](SERIALIZERS.md).

   ```ruby
   def handle(request, response)
     response.format = :json
     user = user_repo.by_id(request.params[:id]).one
     
     response.body = MyApp::Serializers::UserSerializer.new(user).to_json
   end
   ```

3. **Verify round-trip serialization**:
   Always assert that a serialized object can be parsed back into equivalent data. Format all date/time fields with `.iso8601`. If the assertion fails, check that the serializer maps all fields and that timestamps use `.iso8601`.

   ```ruby
   # In tests:
   serialized = UserSerializer.new(user).to_json
   parsed = JSON.parse(serialized, symbolize_names: true)

   assert_equal user.email, parsed[:email]
   assert_equal user.created_at.iso8601, parsed[:created_at]
   # If assertion fails: verify serializer field mapping and timestamp formatting
   ```

4. **Handle request body parsing** via `request.params`:

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
