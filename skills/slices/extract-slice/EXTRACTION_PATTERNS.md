# Extraction Patterns

## Before/After Directory Mapping

```text
Before (in app module):
  app/
    actions/
      payments/
        create.rb        # App::Actions::Payments::Create
        index.rb         # App::Actions::Payments::Index
    operations/
      payments/
        process_payment.rb  # App::Operations::Payments::ProcessPayment
    repositories/
      payment_repo.rb      # App::Repositories::PaymentRepo
    relations/
      payments.rb          # App::Relations::Payments

After (extracted to slice):
  slices/payments/
    actions/
      create.rb            # Payments::Actions::Create
      index.rb             # Payments::Actions::Index
    operations/
      process_payment.rb   # Payments::Operations::ProcessPayment
    repositories/
      payment_repo.rb      # Payments::Repositories::PaymentRepo
    relations/
      payments.rb          # Payments::Relations::Payments
```

## Namespace Rewrite Rules

| Old namespace | New namespace |
|---------------|---------------|
| `App::Actions::Payments::` | `Payments::Actions::` |
| `App::Operations::Payments::` | `Payments::Operations::` |
| `App::Repositories::` | `Payments::Repositories::` |
| `App::Relations::` | `Payments::Relations::` |

## Deps Key Updates

After extraction, `include Deps[...]` keys must use the slice-qualified path:

```ruby
# Before
include Deps["operations.payments.process_payment"]

# After
include Deps["payments.operations.process_payment"]
```

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Forgot to update `require` paths | Grep for old paths: `rg "require.*app/" slices/` |
| Stale route references in `config/routes.rb` | Update slice prefix in routes |
| Provider still references old namespace | Check `config/providers/` for slice-specific registrations |
| Test helpers still load old module | Update `spec/slices/<slice>/slice_helper.rb` |
| Other slices import the old namespace | Update cross-slice references to use the new public API |

## Post-Extraction Verification

```bash
# Run only the extracted slice's tests
bundle exec rspec spec/slices/payments/

# Run full suite to catch regressions
bundle exec rspec

# Find remaining references to old namespace
rg "App::(Actions|Operations|Repositories|Relations)::Payments" slices/ app/
```
