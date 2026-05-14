# Rails to Hanami 2.x Concept Mapping

This document provides a comprehensive mapping of Rails concepts to Hanami 2.x equivalents for developers migrating from Rails.

## Directory Structure

| Rails | Hanami 2.x |
|---|---|
| `app/controllers/` | `app/actions/` |
| `app/models/` | `app/relations/` + `app/repos/` + `app/entities/` |
| `app/views/` | `app/views/` + `app/templates/` |
| `app/helpers/` | View Parts (`app/views/parts/`) |
| `config/initializers/` | `config/register-provider/` |
| `config/routes.rb` | `config/routes.rb` |
| `db/migrate/` | `db/migrate/` |
| `lib/` | `lib/` or slice-specific directories |
| `app/assets/` | `app/assets/` |

## MVC Pattern

| Rails | Hanami 2.x |
|---|---|
| Controller (many actions) | Action (one endpoint per class) |
| ActiveRecord Model | ROM Relation + Repository + Entity |
| ERB View | Hanami View + Template |
| Helper methods | View Parts |
| `before_action` | Explicit auth in each Action or middleware |
| `strong_parameters` | Params DSL block in Action |

## Database Layer

| Rails (ActiveRecord) | Hanami 2.x (ROM/Sequel) |
|---|---|
| `rails db:migrate` | `hanami db migrate` |
| `rails db:rollback` | `hanami db rollback` |
| `rails db:seed` | `hanami db seed` |
| `rails db:create` | `hanami db create` |
| `ActiveRecord::Migration` | `Sequel.migration` |
| `create_table` | `create_table` (Sequel DSL) |
| `add_column` | `alter_table { add_column }` |
| `remove_column` | `alter_table { drop_column }` |
| `t.string` | `column :name, :text` |
| `t.timestamps` | `column :created_at, :timestamptz` |
| `t.references` | `foreign_key` |
| `t.index` | `add_index` |
| `has_many` | `one_to_many` |
| `belongs_to` | `many_to_one` |
| `scope` | Custom query method on Relation |
| `Model.where(...)` | `relation.where(...)` |
| `Model.find(id)` | `repo.by_id(id).one` |
| `Model.create!` | `repo.create(attrs)` |
| `Model.update!` | `repo.update(id, attrs)` |
| `Model.destroy!` | `repo.delete(id)` |
| `Model.all` | `repo.all` |
| `Model.count` | `repo.count` |
| `Model.transaction` | `repo.transaction` |

## Actions / Controllers

| Rails | Hanami 2.x |
|---|---|
| `class UsersController` | `class Index < MyApp::Action` |
| `def index; end` | `def handle(request, response); end` |
| `render json: @user` | `response.format = :json; response.body = user.to_json` |
| `redirect_to user_path` | `response.redirect_to("/users/#{user.id}")` |
| `head :no_content` | `response.status = 204` |
| `params.require(:user)` | Params DSL block |
| `@instance_variables` | Pass data as exposures to View |
| `before_action` | Explicit check in `#handle` or middleware |
| `rescue_from` | `rescue` in `#handle` |
| `render @users` | `response.render(view, users: repo.all)` |

## Views

| Rails | Hanami 2.x |
|---|---|
| `app/views/users/show.html.erb` | `app/templates/users/show.html.erb` + `app/views/users/show.rb` |
| `<%= @user.name %>` | `<%= user.name %>` (local from expose) |
| `helper_method` | View Part methods |
| `content_for` | `expose` with Part methods |
| `render partial: "user"` | Nested View or Part |
| `layout "application"` | `layout "application"` in View class |

## Dependency Injection

| Rails | Hanami 2.x |
|---|---|
| Implicit (models available everywhere) | Explicit via `include Deps["key"]` |
| `before_action :set_user` | `include Deps["repos.user_repo"]` |
| `ApplicationController` deps | Each Action declares its own |
| `Thread.current` | Pass context explicitly |

## Testing

| Rails | Hanami 2.x |
|---|---|
| `spec/requests/` | `spec/requests/` |
| `spec/controllers/` | `spec/actions/` |
| `spec/models/` | `spec/relations/` + `spec/repos/` |
| `FactoryBot.create` | ROM factories or direct repo calls |
| `sign_in user` | Set auth header |
| `type: :controller` | `type: :action` |
| `type: :request` | `type: :request` |

## Configuration

| Rails | Hanami 2.x |
|---|---|
| `config/application.rb` | `config/app.rb` |
| `config/environments/` | `HANAMI_ENV` + manage-settings |
| `config/database.yml` | `DATABASE_URL` env var |
| `config/credentials.yml.enc` | Settings with env vars |
| `dotenv-rails` | Built-in `.env` support |
| `Rails.application.config` | `Hanami.app[:manage-settings]` |

## CLI

| Rails | Hanami 2.x |
|---|---|
| `rails new` | `hanami new` |
| `rails generate` | `hanami generate` |
| `rails server` | `hanami dev` |
| `rails console` | `hanami console` |
| `rails routes` | `hanami routes` |
| `bin/rails` | `hanami` |

## Slices vs Engines

| Rails Engine | Hanami Slice |
|---|---|
| `rails plugin new` | `hanami generate slice` |
| `isolate_namespace` | Natural namespace under `MyApp::Slices::Name` |
| Engine routes | `slices/<name>/config/routes.rb` |
| `main_app.root_path` | `routes.path(:root)` |
| Mount engine | `slice :name, at: "/path"` |
| Cross-engine deps | `import` and `export` |

## Background Jobs

| Rails | Hanami 2.x |
|---|---|
| `ActiveJob` | Sidekiq/GoodJob via provider |
| `perform_later` | `jobs.client.push(...)` |
| `deliver_later` | Enqueue from Action |
| `set_queue_name` | Configured in adapter setup |

## Authentication

| Rails (Devise) | Hanami 2.x |
|---|---|
| `before_action :authenticate_user!` | Explicit auth check in each Action |
| `current_user` | Injected auth service |
| `sign_in` | Custom login Action |
| `sign_out` | Custom logout Action |
| `has_secure_password` | `BCrypt::Password` in auth service |
| `devise_for :users` | Custom routes + Actions |
