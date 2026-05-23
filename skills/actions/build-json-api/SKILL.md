---
name: build-json-api
version: "1.0.0"
license: MIT
description: >
  Use when building JSON API responses, REST API endpoints, or Hanami action
  responses in Hanami 2.x Actions. Covers setting content-type headers,
  serializing Ruby objects to JSON, parsing incoming JSON request bodies,
  content negotiation, and round-trip parse → serialize → parse verification.
  Use when you need to render JSON, build a JSON endpoint, create an API
  controller action, or handle JSON request/response cycles in Hanami 2.x.
ecosystem_sources:
  - hanami/hanami-controller
tags:
  - actions
  - json
  - api
  - serialization
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

2. **Serialize Entities to hashes** before JSON encoding:

   ```ruby
   def handle(request, response)
     response.format = :json
     user = user_repo.by_id(request.params[:id]).one
     response.body = serialize_user(user)
   end

   private

   def serialize_user(user)
     {
       id: user.id,
       email: user.email,
       name: "#{user.first_name} #{user.last_name}",
       role: user.role,
       created_at: user.created_at.iso8601
     }.to_json
   end
   ```

3. **Use a dedicated serializer object** for complex APIs:

   ```ruby
   # app/serializers/user_serializer.rb
   # frozen_string_literal: true

   module MyApp
     module Serializers
       class UserSerializer
         def initialize(user)
           @user = user
         end

         def to_h
           {
             id: @user.id,
             email: @user.email,
             name: "#{@user.first_name} #{@user.last_name}",
             role: @user.role,
             created_at: @user.created_at.iso8601
           }
         end

         def to_json(*args)
           to_h.to_json(*args)
         end
       end
     end
   end
   ```

4. **Verify round-trip parse → serialize → parse** for every serializer:

   ```ruby
   # In tests or REPL:
   user = user_repo.by_id(1).one
   serialized = UserSerializer.new(user).to_json
   parsed = JSON.parse(serialized, symbolize_names: true)

   # Assert parsed data is equivalent to source
   assert_equal user.id, parsed[:id]
   assert_equal user.email, parsed[:email]
   ```

   **Round-trip verification workflow:**
   1. Serialize the entity → call `.to_json`
   2. Parse the result → `JSON.parse(serialized, symbolize_names: true)`
   3. Assert each field matches the source entity
   4. **If a field doesn't match:** check the serializer's `to_h` for that key (missing key, wrong type, unformatted timestamp, nil value)
   5. Fix the serializer → re-run the round-trip → confirm all assertions pass
   6. Repeat for every resource type exposed by the API

5. **Handle request body parsing** — JSON bodies are available via `request.params`:

   ```ruby
   def handle(request, response)
     response.format = :json
     attrs = request.params[:user]
     result = user_repo.create(attrs)

     response.status = 201
     response.body = UserSerializer.new(result).to_json
   end
   ```

6. **Return consistent error shapes**:

   ```ruby
   halt 422, { error: { message: "Validation failed", details: [...] } }.to_json
   ```

7. **Include pagination metadata** for collection endpoints:

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

8. **Rescue parse errors** and return 400:

   ```ruby
   rescue JSON::ParserError
     halt 400, { error: "Invalid JSON body" }.to_json
   end
   ```

---

## Checklist: Common Mistakes & Red Flags

- [ ] `response.format = :json` is set on every JSON action
- [ ] Every entity is serialized through a dedicated serializer or explicit hash — never raw `to_h` or Repository result
- [ ] Round-trip parse → serialize → parse verified for every serializer
- [ ] Timestamps serialized to ISO 8601 via `.iso8601` — never raw `Time#to_json`
- [ ] Error responses follow a consistent shape (`{ error: { message: ..., details: ... } }`)
- [ ] Same serializer used for the same resource across all endpoints
- [ ] No internal or sensitive entity fields leaked through uncontrolled serialization
- [ ] `JSON::ParserError` rescued and returned as 400
