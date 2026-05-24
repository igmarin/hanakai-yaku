# Advanced ROM Repositories in Hanami 2.x

This document details advanced database patterns using ROM Repositories: transactions and custom entity mappings.

---

## Transaction Handling

Use database transactions to wrap multi-step writes. ROM automatically rolls back changes if a StandardError exception is raised inside the block.

```ruby
# Example of transaction wrapper returning Success/Failure monads
def transfer_funds(from_id, to_id, amount)
  transaction do
    from_account = accounts.by_id(from_id).one
    to_account   = accounts.by_id(to_id).one

    # Guard against missing records before mutating state
    return Failure(:account_not_found) if from_account.nil? || to_account.nil?
    return Failure(:insufficient_funds) if from_account.balance < amount

    accounts.update(from_id, balance: from_account.balance - amount)
    accounts.update(to_id,   balance: to_account.balance + amount)

    Success(true)
  end
rescue => e
  Failure(e.message)
end
```

---

## Custom Entity Mapping

Repositories retrieve data from Relations and map it to Entities (ROM Structs). By default, ROM returns generic `ROM::Struct` instances. To map to your own typed domain models:

1. Configure the `struct_namespace` to point to your Entities module.
2. Enable `auto_struct true`.

```ruby
# app/repos/user_repo.rb
# frozen_string_literal: true

module MyApp
  module Repos
    class UserRepo < Hanami::DB::Repo[:users]
      # Map database records to MyApp::Entities namespace
      struct_namespace MyApp::Entities
      auto_struct true
    end
  end
end
```
