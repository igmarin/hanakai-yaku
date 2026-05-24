# JSON Serializers in Hanami 2.x

This document details serializer conventions, dedicated serializer class patterns, and testing strategies for Hanami JSON APIs.

---

## Dedicated Serializer Pattern

For anything beyond extremely simple key-value outputs, extract serialization logic into a dedicated class. This isolates representation concerns from the Action class and keeps code DRY.

```ruby
# app/serializers/user_serializer.rb
# frozen_string_literal: true

module MyApp
  module Serializers
    class UserSerializer
      def initialize(user)
        @user = user
      end

      # Define a clear representation hash
      def to_h
        {
          id: @user.id,
          email: @user.email,
          name: "#{@user.first_name} #{@user.last_name}",
          role: @user.role,
          created_at: @user.created_at.iso8601 # Always format timestamps explicitly
        }
      end

      # Standard interface expected by JSON encoders
      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
```

---

## Round-Trip Verification Workflow

To guarantee your serializers produce predictable and parseable JSON output, always verify them with a round-trip parse:

```ruby
# Example inside a unit spec or REPL:
user = user_repo.by_id(1).one
serialized = UserSerializer.new(user).to_json
parsed = JSON.parse(serialized, symbolize_names: true)

# Assertions to ensure parseable equivalence:
assert_equal user.id, parsed[:id]
assert_equal user.email, parsed[:email]
```

### Steps to Verify and Debug:

1. **Serialize the entity:** Call `.to_json` on the serializer instance.
2. **Parse the result:** Load the output back into a Ruby hash with `JSON.parse(serialized, symbolize_names: true)`.
3. **Assert equivalence:** Compare parsed hash values against the source entity properties.
4. **Identify mismatches:** If an assertion fails, check `to_h` in your serializer:
   - **Missing Key:** Did you forget to expose a field?
   - **Wrong Type:** Did an integer parse as a string?
   - **Malformed Timestamp:** Is the date-time output standard (like ISO 8601)?
   - **Nil values:** Does your serializer crash or emit bad fields if a value is nil?
5. **Fix & Re-run:** Correct the serializer, rerun the verification, and confirm the assertions pass.

---

## Conventions & Best Practices

* **ISO 8601 Dates:** Do not rely on default `Time#to_s` formatting. Use `.iso8601` for standard-compliant timestamps.
* **Sensitivity Leakage:** Explicitly define keys in `to_h`. Never do generic loops or select all attributes from a repository model, as it risks leaking internal database fields (like `password_digest` or internal flags).
* **Null Handling:** Safely handle optional attributes to prevent `NoMethodError` during serialization:
  ```ruby
  last_login_at: @user.last_login_at&.iso8601
  ```
