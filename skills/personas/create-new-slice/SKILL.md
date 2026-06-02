---
name: create-new-slice
license: MIT
type: persona
description: >
  Use when creating a new Slice in Hanami 2.x — including when a user wants to add a slice,
  scaffold a slice, create a new Hanami module, or set up a bounded context. Chains
  create-slice, define-routes, configure-slice, inject-dependencies, and write-request-spec
  to generate the slice, configure routes, set up dependencies, and write smoke tests.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - personas
  - slices
  - modularization
  - bounded-contexts
  version: 1.0.0
---

# create-new-slice

Use this workflow when creating a new Slice in Hanami 2.x.

---

## Workflow

**1. Generate Slice** — Load skill: `create-slice`

Run the generator and register the slice:

```bash
bundle exec hanami generate slice blog
```

```ruby
# config/app.rb
slice :blog, at: "/blog"
```

Verify the slice boots: `bundle exec hanami console` — confirm `Hanami.app[:slices]` includes the new slice.

---

**2. Configure Routes** — Load skill: `define-routes`

Define RESTful routes in the slice:

```ruby
# slices/blog/config/routes.rb
routes.namespace "/blog" do
  resources :posts
end
```

Verify routes are registered: `bundle exec hanami routes` — confirm expected paths appear under the slice namespace.

---

**3. Configure Slice** — Load skill: `configure-slice`

Define slice-specific settings, providers, and auto-registration:

```ruby
# slices/blog/config/slice.rb
module Blog
  class Slice < Hanami::Slice
    # Slice-specific settings
    setting :posts_per_page, default: 10

    # Slice-specific provider
    register_provider :cache do
      start { register(:cache, MyCache.new) }
    end
  end
end
```

Verify providers load without errors: `bundle exec hanami console` — call `Blog::Slice[:cache]` (or relevant key) to confirm resolution.

---

**4. Setup DI** — Load skill: `inject-dependencies`

Import required components from other slices and export what this slice provides:

```ruby
# slices/blog/config/slice.rb
module Blog
  class Slice < Hanami::Slice
    # Import a component from the main app
    import keys: ["persistence.db"], from: :app

    # Export components for other slices
    export keys: ["repositories.posts"]
  end
end
```

Verify cross-slice dependencies resolve:

```ruby
# In hanami console
Blog::Slice["persistence.db"]        # => must not raise
Hanami.app["blog.repositories.posts"] # => must not raise
```

---

**5. Write Tests** — Load skill: `write-request-spec`

Write smoke tests confirming the slice mounts and routes respond:

```ruby
# spec/requests/blog/posts_spec.rb
RSpec.describe "Blog::Posts", type: :request do
  it "lists posts" do
    get "/blog/posts"
    expect(last_response.status).to eq(200)
  end
end
```

Run the smoke tests: `bundle exec rspec spec/requests/blog/` — all examples must pass before considering the slice complete.

---

## Pitfalls

| Mistake | Correct Approach |
|---|---|
| Slice without clear bounded context | Slices represent bounded contexts — do not create slices for arbitrary grouping. |
| Circular dependencies between slices | Slices should be acyclic: Slice A imports from Slice B, not vice versa. |
| Forgetting to register the slice in `config/app.rb` | The slice must be registered in the app to be mounted. |
| Duplicating main app configuration | Slices inherit app configuration — only override when necessary. |
| Defining routes in the main app | Slice routes belong in `slices/<name>/config/routes.rb`. |
| Missing smoke tests for slice routes | Always verify the slice mounts and responds at its path. |
