# Testing with Dependency Injection

## Stubbing Injected Dependencies

Hanami actions and operations receive dependencies through the constructor. In tests, pass test doubles:

### Action Testing

```ruby
# spec/slices/api/actions/users/create_spec.rb
RSpec.describe Api::Actions::Users::Create do
  let(:create_user) { instance_double(Users::CreateUser) }
  let(:action) { described_class.new(create_user:) }

  context "with valid params" do
    let(:user) { User.new(id: 1, email: "test@example.com") }

    before do
      allow(create_user).to receive(:call).and_return(Dry::Monads::Success(user))
    end

    it "returns 201 with user data" do
      response = action.call("email" => "test@example.com")
      expect(response.status).to eq(201)
    end
  end

  context "with invalid params" do
    before do
      allow(create_user).to receive(:call)
        .and_return(Dry::Monads::Failure(email: ["is invalid"]))
    end

    it "returns 422 with errors" do
      response = action.call("email" => "invalid")
      expect(response.status).to eq(422)
    end
  end
end
```

### Operation Testing

```ruby
# spec/slices/api/operations/users/create_user_spec.rb
RSpec.describe Users::CreateUser do
  let(:user_repo) { instance_double(Api::Repositories::UserRepo) }
  let(:send_welcome) { instance_double(Notifications::SendWelcome) }
  let(:operation) { described_class.new(user_repo:, send_welcome:) }

  it "persists the user and sends welcome notification" do
    allow(user_repo).to receive(:create).and_return(user)
    allow(send_welcome).to receive(:call).and_return(Dry::Monads::Success(true))

    result = operation.call(email: "test@example.com", name: "Test")
    expect(result).to be_success
    expect(user_repo).to have_received(:create).with(email: "test@example.com", name: "Test")
    expect(send_welcome).to have_received(:call).with(user)
  end
end
```

## Deps Conventions

| Consumer | Typical Deps |
|----------|-------------|
| Action | One operation, sometimes a repository for reads |
| Operation | Repositories, other operations, external service clients |
| Repository | None — auto-registered by ROM |
| View | Repositories for read-only data, presentation helpers |
