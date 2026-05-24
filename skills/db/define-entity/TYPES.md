# Entity Attributes & dry-types Reference

This document covers type definitions, constraints, and default value mapping for Hanami DB Entities.

---

## Basic dry-types Core

The standard type namespace `Types` is defined by the framework. Common types include:

* `Types::Integer`
* `Types::String`
* `Types::Time`
* `Types::Bool`
* `Types::Float`
* `Types::Decimal`

---

## Coercions & Constraints

You can apply type-level constraints and validation rules to attributes:

```ruby
# Enforce string format (e.g. Email regex)
attribute :email, Types::String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.\w+\z/)

# Numeric range boundary constraints
attribute :age, Types::Integer.constrained(gt: 0)

# Set defaults and restrict to specific enums
attribute :role, Types::String.default("member").enum("admin", "member", "guest")
```

---

## Handling Optional / Nullable Values

By default, an attribute requires a value matching its type. If the database allows `NULL`, declare it as `optional`:

```ruby
# Correct optional string declaration
attribute :middle_name, Types::String.optional

# Handling optional timestamps
attribute :last_login_at, Types::Time.optional
```
