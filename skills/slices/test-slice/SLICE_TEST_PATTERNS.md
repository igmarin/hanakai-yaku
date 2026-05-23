# Slice Test Patterns

## Slice-Isolated Test Helper

```ruby
# spec/slices/api/slice_helper.rb
require "hanami/rspec"

RSpec.configure do |config|
  config.before(:suite) do
    Hanami.app.prepare(:api)
  end
end
```

## Database Strategies

### Using ROM's built-in test support

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    Hanami.app.prepare(:api)
  end

  config.around(:each, :db) do |example|
    # Wrap each test in a transaction and rollback
    Hanami.app["api.rom"].gateways[:default].transaction(rollback: :always) do
      example.run
    end
  end
end
```

### Using database_cleaner

```ruby
config.before(:suite) do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with(:truncation)
end

config.around(:each) do |example|
  DatabaseCleaner.cleaning { example.run }
end
```

## Action Spec Pattern

```ruby
# spec/slices/api/actions/users/create_spec.rb
RSpec.describe Api::Actions::Users::Create, :slice do
  let(:create_user) { instance_double(Users::CreateUser) }
  let(:action) { described_class.new(create_user:) }

  before do
    allow(create_user).to receive(:call).and_return(result)
  end

  context "success" do
    let(:user) { double(id: 1, email: "test@example.com") }
    let(:result) { Dry::Monads::Success(user) }

    it "returns 201" do
      response = action.call(email: "test@example.com")
      expect(response.status).to eq(201)
    end
  end

  context "failure" do
    let(:result) { Dry::Monads::Failure(email: ["is invalid"]) }

    it "returns 422" do
      response = action.call(email: "bad")
      expect(response.status).to eq(422)
    end
  end
end
```

## Operation Spec Pattern

```ruby
RSpec.describe Users::CreateUser do
  let(:user_repo) { instance_double(Api::Repositories::UserRepo) }
  let(:operation) { described_class.new(user_repo:) }
end
```

## Integration Spec Pattern

Test the full slice workflow without mocking internal dependencies:

```ruby
RSpec.describe "User registration", :slice, :db do
  it "creates a user through the full stack" do
    action = Api::Actions::Users::Create.new

    response = action.call(
      email: "test@example.com",
      name: "Test User"
    )

    expect(response.status).to eq(201)
    body = JSON.parse(response.body.first)
    expect(body["email"]).to eq("test@example.com")
  end
end
```

## Cross-Slice Mocking

When Slice A needs Slice B's data in a test:

```ruby
# Good: Stub the public interface
let(:payment_action) { instance_double(Payments::Actions::GetStatus) }
before do
  allow(payment_action).to receive(:call).and_return(status_response)
end

# Bad: Reach into another slice's internals
# let(:payment_repo) { Payments::Repositories::PaymentRepo.new }
```

## Slice Test Tagging

Tag all slice tests for easy selective execution:

```ruby
RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/slices/}) do |metadata|
    metadata[:slice] = true
  end
end
```

Run only slice tests: `bundle exec rspec --tag slice`
