# Request Specs for Order Management API

## Problem/Feature Description

A fulfilment team has built three Hanami actions for an order management API. The actions are in `app/actions/orders/` and handle: listing all orders, creating a new order, and fetching a single order by ID. The implementation is complete but there are no automated tests yet.

The team lead wants a full RSpec request spec suite covering these endpoints before the feature can be merged. She specifically wants tests for success cases and for the error scenarios — a missing order (404) and a badly formed create request (422). The API is backed by a real database, so test isolation is important.

The existing action code is in the `app/actions/orders/` directory. Review it to understand the routes and response shapes, then write the corresponding request specs.

## Output Specification

Produce `spec/requests/orders_spec.rb` — a single RSpec file covering:

1. `GET /orders` — returns a list of orders (200)
2. `POST /orders` — creates an order successfully (201), returns a 422 for invalid input
3. `GET /orders/:id` — returns a single order (200), returns 404 for a missing ID

You do not need to create database seed data or factories; it is fine for the list and show success specs to use whatever setup is appropriate in the test. Focus on the spec file structure, request format, and assertion patterns.
