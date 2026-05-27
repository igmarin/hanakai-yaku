# User Onboarding Workflow

## Problem/Feature Description

A SaaS application built on Hanami 2.x needs a user onboarding flow. When a new user signs up, the system must: validate the submitted data, persist the new user record to the database, and then dispatch a welcome email through a mailer service. These three steps must happen in sequence, and if any step fails the process should stop and return a clear failure reason — the welcome email must not be sent if the user record could not be saved, for instance.

The team has decided that this logic must live in a dedicated business object, not scattered across the HTTP layer. The HTTP action should only be responsible for calling this object and mapping its result to an HTTP response. The mailer service is already registered in the container at the key `"mailers.welcome_mailer"` and responds to `send_welcome(user)`. The user repository is at `"repos.user_repo"` and responds to `create(attrs)` returning the persisted user struct.

## Output Specification

Produce the following files:

- `app/operations/users/onboard_user.rb` — the business operation class
- `app/actions/users/create.rb` — the Hanami Action that delegates to the operation
- `spec/operations/users/onboard_user_spec.rb` — RSpec unit spec for the operation

The operation spec should test at minimum: the happy path (all steps succeed), the case where validation fails, and the case where persistence fails. Use test doubles for the injected dependencies.
