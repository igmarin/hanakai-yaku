# Rails Exception Pattern vs Hanami Result Pattern

This document compares traditional Rails ActiveRecord exception/save patterns against Hanami's monadic Result patterns.

---

## Comparison Table

| Rails (ActiveRecord) | Hanami 2.x (dry-monads Result Pattern) |
|---|---|
| `User.create!(attrs)` (raises on failure) | `create_user.call(attrs)` → `Success(user)` or `Failure(error)` |
| `ActiveRecord::RecordInvalid` exceptions | `Failure({ code: :validation_failed, errors: ... })` (as values) |
| `rescue_from ActiveRecord::RecordNotFound` | Pattern match `Failure` in Action and `halt 404` |
| `if user.save; ...; else; ...; end` | `case result; in Success(v); ...; in Failure(e); ...; end` |
| Service objects (custom class with raise) | `dry-monads` service objects returning `Success`/`Failure` |
| `before_action` for sequential steps | `Do` notation (`yield`) for sequencing multiple operations |

---

## Pattern Example

### Rails Exception Style
```ruby
# Rails Controller
def create
  @user = User.create!(user_params)
  deliver_welcome_email(@user)
  render json: @user, status: :created
rescue ActiveRecord::RecordInvalid => e
  render json: { errors: e.record.errors }, status: :unprocessable_entity
end
```

### Hanami Monadic Style
```ruby
# Hanami Action
def handle(request, response)
  result = create_user.call(request.params[:user])
  
  case result
  in Success(user)
    response.status = 201
    response.body = UserSerializer.new(user).to_json
  in Failure(error_payload)
    response.status = 422
    response.body = { error: error_payload }.to_json
  end
end
```
