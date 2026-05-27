---
name: run-development
license: MIT
description: >
  Use when running Hanami 2.x development commands. Covers hanami dev
  (starting the development server with code reloading), hanami console (REPL
  with full container loaded for exploring the app, accessing slices, inspecting
  registered components, querying relations, and testing repository methods),
  hanami routes (listing all routes), and hanami middleware (inspecting the
  middleware stack).
metadata:
  version: "1.0.0"
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

   **Verify:** Once started, confirm the server is responding:

   ```bash
   curl http://localhost:2300
   ```

   **Error recovery:**
   - Port already in use: `lsof -ti:2300 | xargs kill -9` or change port in `config/app.rb`
   - Server fails to start: Check `config/app.rb` and `config/routes.rb` for syntax errors
   - Does not reload configuration files (requires restart after editing `config/app.rb` or `config/routes.rb`)

2. **Start the console**:

   **Before starting**, ensure `DATABASE_URL` is set if your app uses a database:

   ```bash
   echo $DATABASE_URL
   ```

   Then start the console:

   ```bash
   hanami console
   ```

   Uses `development` environment by default; override with `HANAMI_ENV=test hanami console`.

   Access components directly:

   ```ruby
   app = Hanami.app
   rom = app["db.rom"]
   users = rom.relations[:users]
   users.insert(email: "test@example.com")
   ```

   **Error recovery:**
   - Database connection refused: Verify `DATABASE_URL` is set and database server is running
   - Boot errors: Check `config/providers/` for missing dependencies or configuration issues

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

4. **List routes and middleware**:

   ```bash
   hanami routes
   hanami middleware
   ```

---

## Common Mistakes

- **Config files don't reload**: `hanami dev` reloads Ruby code only. Restart the server after editing configuration files.
- **Environment awareness**: Always verify `HANAMI_ENV` before running destructive operations in the console — it defaults to `development` but is easy to misconfigure.

---

## Integration

| Related Skill | When to chain |
|---|---|
| [**create-app**](../create-app/SKILL.md) | Development commands are used after creating the app. |
| [**manage-database**](../manage-database/SKILL.md) | Database commands may be needed before starting the dev server. |
