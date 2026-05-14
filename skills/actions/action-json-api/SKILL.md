---
name: action-json-api
version: "1.0.0"
license: MIT
description: >
  Use when building JSON API responses in Hanami 2.x Actions. Covers content
  negotiation, serialization, round-trip parse → serialize → parse requirement.
ecosystem_sources:
  - hanami/hanami-controller
tags:
  - actions
  - json
  - api
  - serialization
---

# action-json-api

Use this skill when building JSON API endpoints in Hanami 2.x Actions.

**Core principle:** JSON APIs must produce predictable, parseable output. Implement round-trip parse → serialize → parse verification for all serializers.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Return JSON | `response.format = :json` |
| Serialize an Entity | `response.body = user.to_h.to_json` or use a serializer object |
| Serialize a collection | `response.body = users.map(&:to_h).to_json` |
| Handle JSON request body | `request.params[:key]` (JSON body is parsed automatically) |
| Content negotiation | Check `request.accept` or force `response.format = :json` |
| Round-trip verification | Parse → Serialize → Parse produces equivalent result |
| Set JSON Content-Type | `response.headers["Content-Type"] = "application/json"` |
| Handle parse errors | Rescue `JSON::ParserError` and halt 400 |

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

5. **Handle request body parsing** automatically. Hanami parses JSON bodies into `request.params`:

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
       page: params[:page] || 1,
       per_page: params[:per_page] || 20,
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

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll return the Entity's `to_h` directly without controlling the shape" | Always use a serializer or explicit hash construction. Entities may contain internal fields that should not be exposed. |
| "I'll skip the round-trip verification" | Round-trip parse → serialize → parse is mandatory. It catches missing fields, type mismatches, and encoding issues. |
| "I'll use `to_json` on the Repository result directly" | Repositories return Entities. Always serialize through a defined serializer. |
| "I'll forget to set `response.format = :json`" | Without setting the format, the response Content-Type may default to HTML. |
| "I'll return different shapes for the same resource in different endpoints" | Consistent serialization is critical for API consumers. Use the same serializer everywhere for a given resource. |
| "I'll serialize `Time` objects without `iso8601`" | Always serialize timestamps to ISO 8601 strings. Raw `Time#to_json` behavior varies by JSON library. |

---

## Red Flags

- Entities serialized directly without a serializer
- Missing round-trip verification in tests
- Inconsistent JSON shapes for the same resource
- Raw database hashes returned as JSON
- Missing `response.format = :json`
- Timestamps not in ISO 8601 format
- Error responses that don't follow a consistent shape

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | JSON API responses are built within Actions. Master Action structure first. |
| **action-params-validation** | JSON request bodies are validated through the Params DSL. |
| **rom-repositories** | Actions fetch data from Repositories before serializing. |
| **request-specs** (testing) | JSON APIs are tested with request specs asserting on response shape. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (JSON API) |
|---|---|
| `render json: @user` | `response.format = :json; response.body = UserSerializer.new(user).to_json` |
| `UserSerializer.new(@user).serializable_hash` | `UserSerializer.new(user).to_h` |
| `ActiveModel::Serializers::JSON` | Custom serializer class or `to_h` method |
| `params.require(:user).permit(...)` | Params DSL block in Action |
| `render json: { error: "Not found" }, status: 404` | `halt 404, { error: "Not found" }.to_json` |
| `JSON.parse(request.body.read)` | `request.params` (automatically parsed) |
| `jbuilder` / `rabl` | Custom serializer classes or `to_h` methods |
