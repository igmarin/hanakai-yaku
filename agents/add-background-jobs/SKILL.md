---
name: add-background-jobs
license: MIT
description: >
  Use when integrating background jobs, async jobs, or background processing in Hanami 2.x — including
  Sidekiq integration, GoodJob worker setup, or any job queue configuration. Sets up background job
  providers, injects job-adapter dependencies into Hanami actions, creates job-triggering actions, and
  generates corresponding RSpec tests.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - agents
  - add-background-jobs
  - sidekiq
  - good-job
  version: 1.0.0
---

# add-background-jobs

Use this workflow when integrating background jobs in Hanami 2.x.

**Core principle:** Background jobs are registered components. They are enqueued from Actions and executed asynchronously.

---

## Core Process

1. **[Register Job Adapter]** — Load skill: `register-provider`
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

   **Validation:** Verify registration with `MyApp::App["jobs.client"]` in a Hanami console or container lookup spec. It should return `Sidekiq::Client` without raising `Dry::Container::Error`.

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
   - Handle enqueue failures gracefully — rescue enqueue errors and log them; do not crash the Action
   - Handoff condition: Jobs are enqueued and executed

   ```ruby
   # app/jobs/welcome_email.rb
   module MyApp
     module Jobs
       class WelcomeEmail
         include Sidekiq::Worker

         def perform(user_id)
           user = user_repo.by_id(user_id).one
           mailer.deliver(to: user.email, subject: "Welcome!")
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
     rescue => e
       Hanami.logger.error("Job enqueue failed: #{e.message}")
       response.status = 201 # Still succeed; enqueue failure is non-fatal
     end
   end
   ```

   **Validation:** Confirm jobs are being enqueued by checking the Sidekiq dashboard (`/sidekiq`) or inspecting the Redis queue directly (`Sidekiq::Queue.new.size`). In tests, use `Sidekiq::Testing.fake!` and assert on `MyApp::Jobs::WelcomeEmail.jobs`.

4. **[Write Job Specs]** — Load skill: `write-action-spec`
   - Test job class in isolation with stubbed dependencies
   - Test that Action enqueues the job
   - Handoff condition: Job specs pass

   ```ruby
   # spec/unit/my_app/jobs/welcome_email_spec.rb
   RSpec.describe MyApp::Jobs::WelcomeEmail do
     subject(:job) { described_class.new }

     let(:user_repo) { instance_double(MyApp::Repos::UserRepo) }
     let(:mailer)    { instance_double(MyApp::Mailers::Welcome) }
     let(:user)      { instance_double(MyApp::Entities::User, id: 42, email: "user@example.com") }

     before do
       allow(user_repo).to receive(:by_id).with(42).and_return(double(one: user))
       allow(mailer).to receive(:deliver)
       job.instance_variable_set(:@user_repo, user_repo)
       job.instance_variable_set(:@mailer, mailer)
     end

     it "delivers a welcome email to the user" do
       job.perform(42)
       expect(mailer).to have_received(:deliver).with(to: "user@example.com", subject: "Welcome!")
     end
   end

   # spec/requests/users/create_spec.rb (enqueue assertion)
   RSpec.describe "POST /users" do
     before { Sidekiq::Testing.fake! }
     after  { Sidekiq::Worker.clear_all }

     it "enqueues a WelcomeEmail job on success" do
       expect {
         post "/users", params: { user: { name: "Alice", email: "alice@example.com" } }
       }.to change(MyApp::Jobs::WelcomeEmail.jobs, :size).by(1)

       expect(last_response.status).to eq(201)
     end
   end
   ```

---

## Common Pitfalls

- **Synchronous execution of deferrable work** — Use jobs for emails, notifications, exports, or anything that can be deferred.
- **Missing enqueue error handling** — Rescue enqueue errors and log them. Do not crash the Action on transient queue failures.
- **Direct container access in jobs** — Inject dependencies via DI container; do not access the container directly inside jobs.
- **Passing complex objects as job arguments** — Jobs serialize to JSON. Pass IDs or simple scalar data, never Ruby objects.
- **Missing job tests** — Always test the job class in isolation and verify the Action enqueues correctly.
- **Jobs not registered in DI container** — The job adapter client must be registered as a provider before it can be injected.
