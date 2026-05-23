# Changeset Patterns

## Create Changeset with Timestamps

```ruby
module Api
  module Changesets
    class CreateUser < ROM::Changeset::Create
      map do |attrs|
        now = Time.now
        attrs.merge(created_at: now, updated_at: now)
      end
    end
  end
end
```

## Update Changeset with Allowed Keys

```ruby
class UpdateUser < ROM::Changeset::Update
  map do |attrs|
    attrs.merge(updated_at: Time.now)
  end

  def allowed_keys
    [:name, :email, :role]
  end

  # Never allow these fields to be mass-updated
  def disallowed_keys
    [:encrypted_password, :admin, :id]
  end
end
```

## Changeset with Contract Validation

```ruby
class CreateUser < ROM::Changeset::Create
  map do |attrs|
    attrs.merge(created_at: Time.now)
  end

  def default_contract
    Users::CreateContract.new
  end
end
```

The changeset calls the contract before persisting. If validation fails, the changeset raises a `ROM::CommandError`.

## Composing Changesets

```ruby
# Chain: validate → set defaults → persist
users.changeset(CreateUser, attrs)
     .map { |attrs| attrs.merge(created_by: current_user.id) }
     .commit
```

## Testing Changesets

```ruby
RSpec.describe Api::Changesets::CreateUser do
  let(:changeset) { user_repo.users.changeset(described_class, attrs) }

  context "with valid attrs" do
    let(:attrs) { { email: "test@example.com", name: "Test" } }

    it "creates a user with timestamps" do
      result = changeset.commit
      expect(result.email).to eq("test@example.com")
      expect(result.created_at).to be_a(Time)
    end
  end
end
```
