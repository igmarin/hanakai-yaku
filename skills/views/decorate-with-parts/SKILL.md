---
name: decorate-with-parts
license: MIT
description: >
  Use when creating View Parts in Hanami 2.x, adding a part class, wrapping exposures
  in Hanami::View::Part, formatting attributes for display, or adding custom helper
  methods to view objects. Defines Part classes that encapsulate presentation logic
  (formatted strings, predicates, delegated attributes), exposes them via the `expose`
  macro, and keeps templates and Views free of complex formatting. Use when working
  with view decoration, view objects, template helpers, or the Ruby view layer in
  a Hanami application.
metadata:
  ecosystem_sources:
  - hanami/hanami-view
  tags:
  - views
  - parts
  - decorators
  - presentation
  version: 1.0.0
---

# decorate-with-parts

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

- **No database queries in Parts.** Parts wrap already-fetched data; queries belong in repositories or actions.
- **No HTML generation in Parts.** Parts return plain strings or booleans; templates produce HTML markup.
- **No business logic in Parts.** Predicates based on simple attribute values are fine; authorization rules and domain decisions belong in interactors or service objects.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-view** | Parts are used within Views. Master View structure first. |
| **create-action** | Actions pass data to Views, which wrap them in Parts. |
| **define-entity** | Parts often wrap Entity objects returned by Repositories. |
