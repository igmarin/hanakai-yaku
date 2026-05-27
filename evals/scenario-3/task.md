# Subscription Signup Endpoint

## Problem/Feature Description

A subscription-based platform is adding a new plan signup flow to its Hanami 2.x API. Users can sign up by providing their email address, chosen plan (the platform offers "basic", "premium", and "enterprise" tiers), billing information nested under a `payment` key (containing `amount` as a whole-number of cents and `currency` as a 3-letter uppercase code), and an optional `referral_code` string.

The intake team has reported that they are receiving garbage data in the database — empty emails, amounts stored as strings instead of integers, and unexpected plan names like "pro" or "trial" that cause downstream errors. The team wants a strict validation layer at the HTTP boundary so that only well-formed requests reach business logic.

The validation rules are:
- `email` is required and must match a basic email pattern
- `plan` is required and must be one of the three supported plan names
- `payment` is a required nested object containing:
  - `amount` as a required integer greater than 0
  - `currency` as a required string with exactly 3 characters
- `referral_code` is optional
- If both `plan` is "basic" and `amount` is greater than 5000, that should be flagged as inconsistent (a cross-field rule)

## Output Specification

Produce `app/actions/subscriptions/create.rb` — the Hanami Action class including its complete params block and `#handle` implementation. The action should return 422 with structured error information when validation fails, and 201 when it succeeds (for now, just acknowledge receipt — no need to persist anything).
