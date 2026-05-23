# Validation Contract Patterns

## Custom Predicates

```ruby
# config/contracts/predicates.rb
require "dry/validation"

Dry::Validation.register_macro(:email_format) do
  key.failure("must be a valid email") unless value.match?(URI::MailTo::EMAIL_REGEXP)
end

# Usage
rule(:email) { key.email_format }
```

## Nested Schemas

```ruby
class OrderContract < Dry::Validation::Contract
  schema do
    required(:customer).hash do
      required(:name).filled(:string)
      required(:email).filled(:string)
    end
    required(:items).array(:hash) do
      required(:product_id).filled(:integer)
      required(:quantity).filled(:integer, gt?: 0)
    end
  end
end
```

## Composed Contracts

```ruby
module Shared
  class PaginationContract < Dry::Validation::Contract
    schema do
      optional(:page).filled(:integer, gt?: 0)
      optional(:per_page).filled(:integer, gt?: 0, lteq?: 100)
    end
  end
end

class Users::IndexContract < Dry::Validation::Contract
  # Compose shared contracts
  config.messages.namespace = :users

  schema do
    optional(:role).filled(:string)
  end

  # Merge pagination schema
  schema do
    import(Shared::PaginationContract.schema)
  end
end
```

## Testing Contracts

```ruby
RSpec.describe Users::CreateContract do
  subject(:contract) { described_class.new }

  context "with valid input" do
    let(:input) { { email: "test@example.com", name: "Test User" } }

    it "is valid" do
      expect(contract.call(input)).to be_success
    end
  end

  context "with missing email" do
    let(:input) { { name: "Test User" } }

    it "has error on email" do
      result = contract.call(input)
      expect(result).to be_failure
      expect(result.errors.to_h).to include(email: ["is missing"])
    end
  end

  context "with invalid email" do
    let(:input) { { email: "not-an-email", name: "Test" } }

    it "has email format error" do
      result = contract.call(input)
      expect(result.errors.to_h).to include(email: ["must be a valid email"])
    end
  end
end
```
