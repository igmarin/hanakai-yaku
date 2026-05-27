---
name: create-view
license: MIT
description: >
  Use when creating Hanami 2.x Views — define a View class inheriting from `Hanami::View` in `app/views/`, declare exposures via `expose :name` that receive pre-fetched data from Actions (never query the database in Views or templates), place templates alongside Views matching the namespace path, use Parts for decorator-style logic via `expose :model, as: :model_part`, and avoid instance variables in templates (templates receive locals from `expose`). Covers View class structure, expose macro, Tilt/ERB template rendering, layouts, and integration with Actions and Parts.
metadata:
  ecosystem_sources:
  - hanami/hanami-view
  tags:
  - views
  - templates
  - rendering
  - tilt
  version: 1.0.0
---

# create-view

Use this skill when creating Hanami 2.x Views.

**Core principle:** Views are objects, not template files. They encapsulate presentation logic and expose data to templates.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a View | Class inherits from `Hanami::View` in `app/views/` |
| Define exposures | Use `expose :name` to declare what the template receives |
| Expose with transformation | `expose :user { \|user\| UserPresenter.new(user) }` |
| Render a template | View automatically looks up `templates/<path>.html.erb` |
| Pass context | `expose :current_user, as: :current_user` |
| Define a layout | `layout "application"` in the View class |
| Set template format | `format :html` (default) or `format :json` |
| Access exposures in template | `<%= user.name %>` (locals passed to ERB) |

---

## Core Rules

1. **Create the View file** in the app or slice:

   ```ruby
   # app/views/users/show.rb
   # frozen_string_literal: true

   module MyApp
     module Views
       module Users
         class Show < MyApp::View
           expose :user
         end
       end
     end
   end
   ```

2. **Create the template** alongside the View:

   ```erb
   <!-- app/templates/users/show.html.erb -->
   <h1><%= user.name %></h1>
   <p><%= user.email %></p>
   ```

3. **Expose data from the Action**:

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     response.render(view, user: user)
   end
   ```

4. **Transform exposures** within the View:

   ```ruby
   class Show < MyApp::View
     expose :user do |user|
       {
         name: "#{user.first_name} #{user.last_name}",
         email: user.email,
         member_since: user.created_at.strftime("%B %Y")
       }
     end
   end
   ```

5. **Use Parts** for decorator-style logic (`decorate-with-parts`):

   ```ruby
   class Show < MyApp::View
     expose :user, as: :user_part
   end
   ```

6. **Define a layout**:

   ```ruby
   class Show < MyApp::View
     layout "application"
   end
   ```

   ```erb
   <!-- app/templates/layouts/application.html.erb -->
   <!DOCTYPE html>
   <html>
     <head><title>MyApp</title></head>
     <body>
       <%= yield %>
     </body>
   </html>
   ```

7. **Keep Views focused on presentation**. No database queries, no business logic. Views receive prepared data from Actions.

8. **Use explicit exposures**. Do not pass raw params or unparsed data to Views.

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Reality |
|---|---|
| Database queries in View classes or templates | Views are for presentation only. All data fetching happens in Actions via Repositories. |
| `@instance_variables` in templates | Templates receive locals from `expose`. No instance variables. |
| Skipping the View class and rendering templates directly | Always define a View class. It encapsulates presentation logic and makes templates testable. |
| Template path mismatched from View namespace | Templates follow the View namespace: `app/views/users/show.rb` → `app/templates/users/show.html.erb`. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Actions render Views and pass exposures. Master Action structure first. |
| **decorate-with-parts** | Use Parts for complex decorator-style logic in Views. |
| **create-repository** | Actions fetch data from Repositories before passing to Views. |
| **write-request-spec** (testing) | Test the full stack: request → Action → View → template. |
