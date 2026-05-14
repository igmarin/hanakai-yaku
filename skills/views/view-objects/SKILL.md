---
name: view-objects
version: "1.0.0"
license: MIT
description: >
  Use when creating Hanami 2.x Views. Covers view class structure, expose macro,
  context, and template rendering with Tilt/ERB.
ecosystem_sources:
  - hanami/hanami-view
tags:
  - views
  - templates
  - rendering
  - tilt
---

# view-objects

Use this skill when creating Hanami 2.x Views.

**Core principle:** Views are objects, not template files. They encapsulate presentation logic and expose data to templates.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a View | Class inherits from `Hanami::View` in `app/views/` |
| Define exposures | Use `expose :name` to declare what the template receives |
| Expose with transformation | `expose :user { |user| UserPresenter.new(user) }` |
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

5. **Use Parts** for decorator-style logic (`skills/views/view-parts`):

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

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put database queries in the View" | Views are for presentation only. All data fetching happens in Actions (via Repositories). |
| "I'll pass raw params to the View" | Actions should validate params and prepare data before passing to Views. Views receive clean, validated data. |
| "I'll use instance variables in the template" | Templates receive locals from `expose`. No `@instance_variables`. |
| "I'll skip the View class and render the template directly" | Always define a View class. It encapsulates presentation logic and makes templates testable. |
| "I'll put business logic in the `expose` block" | `expose` blocks transform data for presentation only. Business logic belongs in Actions or interactors. |
| "I'll use a different template path than the View namespace" | Templates follow the View namespace: `app/views/users/show.rb` → `app/templates/users/show.html.erb`. |

---

## Red Flags

- Database queries in View classes or templates
- Raw params passed to Views
- Instance variables (`@variable`) in templates
- Business logic in `expose` blocks
- Views bypassed in favor of direct template rendering
- Templates with complex conditional logic

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | Actions render Views and pass exposures. Master Action structure first. |
| **view-parts** | Use Parts for complex decorator-style logic in Views. |
| **rom-repositories** | Actions fetch data from Repositories before passing to Views. |
| **request-specs** (testing) | Test the full stack: request → Action → View → template. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (View) |
|---|---|
| `app/views/users/show.html.erb` | `app/templates/users/show.html.erb` (template) + `app/views/users/show.rb` (View class) |
| `<%= @user.name %>` | `<%= user.name %>` (local from `expose`) |
| `UsersController#show` | `MyApp::Actions::Users::Show` (Action) renders `MyApp::Views::Users::Show` (View) |
| `render partial: "user"` | Use `expose` with a Part or render a nested View |
| `layout "application"` | `layout "application"` in the View class |
| `helper_method :current_user` | `expose :current_user` in a base View class or pass from Action |
| `content_for :title` | Use `expose` or Part methods for dynamic content |
