# Operation Patterns

## Sequential Operation (dry-operation)

```ruby
module Orders
  class PlaceOrder < Dry::Operation
    include Deps["repositories.order_repo", "repositories.inventory_repo"]

    def call(input)
      attrs  = step validate(input)
      order  = step persist(attrs)
      step reserve_inventory(order)
      step notify(order)
      order
    end

    private

    def validate(input)
      contract = OrderContract.new
      result = contract.call(input)
      result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
    end

    def persist(attrs) = Success(order_repo.create(attrs))
    def reserve_inventory(order) = # ...
    def notify(order) = # ...
  end
end
```

## Transaction with Rollback (dry-transaction)

```ruby
module Payments
  class ProcessPayment < Dry::Transaction
    include Deps["repositories.payment_repo", "repositories.ledger_repo"]

    map :validate
    tee :log_attempt
    step :charge
    step :record
    step :notify

    private

    def validate(input) = # ...
    def log_attempt(input) = # ... (tee: runs but doesn't affect flow)
    def charge(input) = # ...
    def record(input) = # ...
    def notify(input) = # ...
  end
end
```

Use `dry-transaction` when you need:
- Multiple steps with independent success/failure
- Rollback-like behavior
- Auditing/logging via `tee` steps

Use `dry-operation` when you need:
- Simple sequential workflow
- Early exit on first failure
- Less ceremony

## Error Handling

Operations return `Failure` — never raise exceptions for business errors:

```ruby
# Good
def charge(amount)
  response = payment_gateway.charge(amount)
  response.success? ? Success(response) : Failure(payment_failed: response.error)
end

# Bad
def charge(amount)
  payment_gateway.charge!(amount) # raises on failure
end
```

## Testing Operations

```ruby
RSpec.describe Users::CreateUser do
  let(:user_repo) { instance_double(Api::Repositories::UserRepo) }
  let(:operation) { described_class.new(user_repo:) }

  context "with valid input" do
    before { allow(user_repo).to receive(:create).and_return(user) }

    it "returns Success with the user" do
      result = operation.call(email: "test@example.com")
      expect(result).to be_success
      expect(result.value!).to eq(user)
    end
  end

  context "with invalid input" do
    it "returns Failure with errors" do
      result = operation.call(email: "invalid")
      expect(result).to be_failure
      expect(result.failure).to include(:email)
    end
  end
end
```
