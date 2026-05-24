# ROM Relations Associations & Advanced Queries

This document details database relations, associations, and custom queries in Hanami 2.x using `rom-rb`.

---

## Defining Associations

Relations declare how different tables link to one another. Use these association macros:

```ruby
# app/relations/posts.rb
module MyApp
  module Relations
    class Posts < Hanami::DB::Relation
      schema :posts, infer: true do
        # belongs_to relationship
        associations do
          many_to_one :users, as: :author
        end
      end
    end
  end
end
```

```ruby
# app/relations/users.rb
module MyApp
  module Relations
    class Users < Hanami::DB::Relation
      schema :users, infer: true do
        # has_many relationship
        associations do
          one_to_many :posts, as: :posts
        end
      end
    end
  end
end
```

---

## Advanced Custom Queries

Custom queries are defined directly as public methods in the Relation class. Use standard Sequel query builder patterns (like `where`, `order`, `select`):

```ruby
class Users < Hanami::DB::Relation
  schema :users, infer: true

  # Reusable active scope filter
  def active
    where(status: "active")
  end

  # Lookup filter by attribute
  def by_email(email)
    where(email: email)
  end

  # Sorting query
  def newest
    order { created_at.desc }
  end
end
```
