---
name: view-parts
version: "1.0.0"
license: MIT
description: >
  Use when creating View Parts in Hanami 2.x. Covers decorator-style logic,
  presentation helpers, and encapsulating complex view behavior.
ecosystem_sources:
  - hanami/hanami-view
tags:
  - views
  - parts
  - decorators
  - presentation
---

# view-parts

Use this skill when creating View Parts for decorator-style logic in Hanami 2.x.

**Core principle:** Parts wrap data with presentation methods. They keep Views and templates free of complex formatting logic.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a Part | Class inherits from `Hanami::View::Part` |
| Expose as a Part | `expose :user, as: :user_part` |
| Define Part methods | Add methods to the Part class for presentation logic |
| Access wrapped data | `value` method returns the raw underlying object |
| Delegate to wrapped data | `delegate :name, :email, to: :value` |
| Use in template | `<%= user_part.display_name %>` |
| Format data | `def formatted_date; value.created_at.strftime("%B %d, %Y"); end` |
| Generate HTML | Keep HTML generation out of Parts. Use helpers or template logic. |

---

## Core Rules

1. **Create the Part class**:

   ```ruby
   # app/views/parts/user.rb
   # frozen_string_literal: true

   module MyApp
     module Views
       module Parts
         class User < Hanami::View::Part
           delegate :name, :email, to: :value

           def display_name
             "#{value.first_name} #{value.last_name}"
           end

           def member_since
             value.created_at.strftime("%B %Y")
           end

           def admin?
             value.role == "admin"
           end
         end
       end
     end
   end
   ```

2. **Expose data as a Part** in the View:

   ```ruby
   class Show < MyApp::View
     expose :user, as: :user_part
   end
   ```

3. **Use Part methods in templates**:

   ```erb
   <h1><%= user_part.display_name %></h1>
   <p>Member since <%= user_part.member_since %></p>

   <% if user_part.admin? %>
     <span class="badge">Admin</span>
   <% end %>
   ```

4. **Keep Parts focused on presentation**. No database queries, no business rules:

   ```ruby
   # GOOD: formatting and simple predicates
   def display_name
     "#{value.first_name} #{value.last_name}"
   end

   # BAD: business logic
   def can_delete?(resource)
     value.role == "admin" && resource.owner_id == value.id
   end
   ```

5. **Delegate common methods** to the wrapped value:

   ```ruby
   delegate :id, :name, :email, :created_at, to: :value
   ```

6. **Access the raw value** with the `value` method when needed:

   ```ruby
   def raw_attributes
     value.to_h
   end
   ```

7. **Do not generate HTML in Parts**. Parts return strings or booleans. Templates handle HTML:

   ```ruby
   # GOOD
   def status_label
     value.active? ? "Active" : "Inactive"
   end

   # BAD
   def status_badge
     "<span class='badge'>#{status_label}</span>"
   end
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put database queries in the Part" | Parts wrap already-fetched data. No queries. |
| "I'll put business rules in the Part" | Parts are for presentation only. Business rules belong in interactors or service objects. |
| "I'll generate HTML strings in the Part" | Parts return plain strings. Templates generate HTML. |
| "I'll use Parts for every single exposure" | Use Parts only when the exposure needs presentation methods. Simple data can be exposed directly. |
| "I'll forget to delegate common methods" | Delegate methods you use in templates to avoid `user_part.value.name` everywhere. |
| "I'll create a Part that wraps multiple unrelated objects" | One Part per wrapped object. `UserPart` wraps a User, `PostPart` wraps a Post. |

---

## Red Flags

- Database queries in Part classes
- Business logic in Part methods
- HTML generation in Part methods
- Parts wrapping multiple unrelated objects
- Missing delegation for commonly accessed attributes
- Parts used for simple data that doesn't need decoration

---

## Integration

| Related Skill | When to chain |
|---|---|
| **view-objects** | Parts are used within Views. Master View structure first. |
| **action-anatomy** | Actions pass data to Views, which wrap them in Parts. |
| **rom-structs-entities** | Parts often wrap Entity objects returned by Repositories. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (View Part) |
|---|---|
| `UserDecorator` (Draper gem) | `MyApp::Views::Parts::User` |
| `user.decorate.name` | `user_part.display_name` |
| `helper_method :formatted_date` | Part method `def formatted_date; ...; end` |
| `app/decorators/user_decorator.rb` | `app/views/parts/user.rb` |
| `delegate :name, to: :object` | `delegate :name, to: :value` |
| Decorator with HTML helpers | Part returns strings; template generates HTML |
