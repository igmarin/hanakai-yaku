# Event Ticketing Schema Migration

## Problem/Feature Description

A small startup is building an event ticketing platform using Hanami 2.x with a PostgreSQL database. The engineering team has sketched out the initial data model and now needs the database schema set up before the first sprint can begin.

They need two new tables: `events` (storing title, venue, capacity as an integer, price per ticket stored with decimal precision, start time, end time, and when the record was created/updated) and `tickets` (linking to an event via a foreign key, tracking the ticket holder's name and email, current status — one of "reserved", "confirmed", or "cancelled" — and the purchase timestamp). The `tickets` table has a unique constraint across the event and ticket-holder email to prevent duplicate bookings.

The team also realized they initially forgot to add a `description` column to the `events` table, so a second migration is needed to add it without losing data. A third migration was briefly considered to drop a scratch column called `draft_notes` from `events`, but this is needed now.

## Output Specification

Produce three migration files in `db/migrate/` following the Hanami naming conventions:
- `20240801120000_create_events.rb` — creates the `events` table
- `20240801130000_create_tickets.rb` — creates the `tickets` table
- `20240801140000_add_description_to_events.rb` — adds the `description` column to `events` (nullable text)
- `20240801150000_remove_draft_notes_from_events.rb` — removes the `draft_notes` column from `events` (this column currently holds `:text` data; assume the down migration must restore it)

Each file must be a complete, runnable Sequel migration.
