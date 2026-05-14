---
name: add-background-jobs
version: "1.0.0"
license: MIT
description: >
  Use when integrating background jobs in Hanami 2.x. Chains providers,
  inject-dependencies, create-action, and write-action-spec.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - workflows
  - add-background-jobs
  - sidekiq
  - good-job
---

# add-background-jobs

Use this workflow when integrating background jobs in Hanami 2.x.

**Core principle:** Background jobs are registered components. They are enqueued from Actions and executed asynchronously.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Register job adapter | `providers` | Job adapter registered in container |
| 2. Inject into Action | `inject-dependencies` | Job adapter injectable via `Deps` |
| 3. Enqueue from Action | `create-action` | Action enqueues job correctly |
| 4. Write job specs | `write-action-spec` | Job class tested in isolation |

---

## Core Process

1. **[Register Job Adapter]** — Load skill: `providers`
   - Choose adapter: Sidekiq, GoodJob, or custom
   - Create `config/providers/background_jobs.rb`
   - Register the adapter client in the `start` block
   - Handoff condition: Adapter accessible via `Deps["jobs.client"]`

   ```ruby
   # config/providers/background_jobs.rb
   Hanami.app.register_provider(:background_jobs) do
     start do
       require "sidekiq"
       Sidekiq.configure_client do |config|
         config.redis = { url: target[:settings].redis_url }
       end
       register("jobs.client", Sidekiq::Client)
     end
   end
   ```

2. **[Inject into Action]** — Load skill: `inject-dependencies`
   - Inject job adapter into Action
   - Handoff condition: Adapter injectable

   ```ruby
   class Create < MyApp::Action
     include Deps["jobs.client", "repos.user_repo"]
   end
   ```

3. **[Enqueue from Action]** — Load skill: `create-action`
   - Define job class
   - Enqueue job from Action after successful operation
   - Handle enqueue failures gracefully
   - Handoff condition: Jobs are enqueued and executed

   ```ruby
   # app/jobs/welcome_email.rb
   module MyApp
     module Jobs
       class WelcomeEmail
         include Sidekiq::Worker

         def perform(user_id)
           user = MyApp::App["repos.user_repo"].by_id(user_id).one
           MyApp::App["mailer"].deliver(to: user.email, subject: "Welcome!")
         end
       end
     end
   end
   ```

   ```ruby
   class Create < MyApp::Action
     def handle(request, response)
       result = create_user.call(request.params[:user])
       case result
       in Success(user)
         jobs.client.push("class" => "MyApp::Jobs::WelcomeEmail", "args" => [user.id])
         response.status = 201
       in Failure(error)
         response.status = 422
       end
     end
   end
   ```

4. **[Write Job Specs]** — Load skill: `write-action-spec`
   - Test job class in isolation with stubbed dependencies
   - Test that Action enqueues the job
   - Handoff condition: Job specs pass

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll run background logic synchronously in the Action" | Use jobs for anything that can be deferred: emails, notifications, exports. |
| "I'll forget to handle job enqueue failures" | Rescue enqueue errors and log them. Do not crash the Action. |
| "I'll access the container directly in the job" | Jobs should receive all data as arguments. If they need Repositories, inject them. |
| "I'll pass complex objects to the job" | Jobs serialize to JSON. Pass IDs or simple data, not objects. |

---

## Red Flags

- Synchronous execution of deferrable work
- Missing job enqueue error handling
- Direct container access in jobs
- Complex objects passed as job arguments
- Missing job tests
- Jobs not registered in DI container

---

## Integration

| Related Skill | When to chain |
|---|---|
| **providers** | Step 1: Register job adapter. |
| **inject-dependencies** | Step 2: Inject adapter into Actions. |
| **create-action** | Step 3: Enqueue jobs from Actions. |
| **write-action-spec** | Step 4: Test job classes. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Background Jobs) |
|---|---|
| `UserMailer.welcome(user).deliver_later` | Enqueue `WelcomeEmail` job from Action |
| `ActiveJob` | Sidekiq, GoodJob, or custom job adapter |
| `perform_later` | `jobs.client.push(class: "...", args: [...])` |
| `rails generate job WelcomeEmail` | Custom job class + provider registration |
| `config.active_job.queue_adapter` | Provider `start` block configures adapter |
| `set_queue_name` | Configured in job class or adapter setup |
