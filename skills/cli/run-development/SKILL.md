---
name: run-development
version: "1.0.0"
license: MIT
description: >
  Use when running Hanami 2.x development commands. Covers hanami dev
  (starting the development server with code reloading), hanami console (REPL
  with full container loaded for exploring the app, accessing slices, inspecting
  registered components, querying relations, and testing repository methods),
  hanami routes (listing all routes), and hanami middleware (inspecting the
  middleware stack).
ecosystem_sources:
  - hanami/hanami-cli
tags:
  - cli
  - development
  - server
  - console
---

# run-development

Use this skill when running Hanami 2.x development commands.

---

## Quick Reference

| Command | Purpose |
|---|---|
| `hanami dev` | Start development server with code reloading |
| `hanami console` | Start interactive REPL with full container loaded |
| `hanami routes` | List all routes |
| `hanami middleware` | List middleware stack |
| `hanami version` | Show Hanami version |

---

## Core Rules

1. **Start the development server**:

   ```bash
   hanami dev
   ```

   Expected behavior:
   - Server starts on `http://localhost:2300`
   - Code reloading is enabled (changes take effect without restart)
   - Shows detailed error pages for exceptions

   **Verify:** Once started, confirm the server is responding:

   ```bash
   curl http://localhost:2300
   ```

   A valid HTTP response (even a 404 or 200) confirms the server is running.

2. **Start the console**:

   **Before starting**, ensure `DATABASE_URL` is set if your app uses a database:

   ```bash
   echo $DATABASE_URL
   ```

   Then start the console:

   ```bash
   hanami console
   ```

   Expected behavior:
   - IRB or Pry starts with the Hanami container loaded
   - Access components directly:

   ```ruby
   app = Hanami.app
   rom = app["db.rom"]
   users = rom.relations[:users]
   users.insert(email: "test@example.com")
   ```

3. **Use the console for exploration**:

   ```ruby
   # Query the database
   Hanami.app["db.rom"].relations[:users].to_a

   # Access a Repository
   Hanami.app["repos.user_repo"].all

   # Access settings
   Hanami.app[:settings].database_url

   # Test a Relation query
   Hanami.app["relations.users"].active.to_a
   ```

4. **Development server behavior**:
   - Does not reload configuration files (requires restart)

5. **Console environment**:
   - Loads the full Hanami application
   - Uses `development` environment by default
   - Can override with `HANAMI_ENV=test hanami console`

6. **List routes**:

   ```bash
   hanami routes
   ```

   Expected output: Table of HTTP methods, paths, and Action names.

7. **List middleware**:

   ```bash
   hanami middleware
   ```

   Expected output: Ordered list of middleware in the stack.

---

## Common Mistakes

- **Config files don't reload**: `hanami dev` reloads Ruby code, not configuration. Restart the server after editing `config/app.rb` or `config/routes.rb`.
- **Missing `DATABASE_URL`**: The console loads the full app and requires `DATABASE_URL` to connect. Run `echo $DATABASE_URL` before starting.
- **Environment awareness**: Always verify `HANAMI_ENV` before running destructive operations in the console — it defaults to `development` but is easy to misconfigure.

---

## Integration

| Related Skill | When to chain |
|---|---|
| [**create-app**](../create-app/SKILL.md) | Development commands are used after creating the app. |
| [**manage-database**](../manage-database/SKILL.md) | Database commands may be needed before starting the dev server. |
