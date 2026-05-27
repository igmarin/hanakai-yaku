# Product Catalog Endpoint

## Problem/Feature Description

An e-commerce company is building a Hanami 2.x API for its product catalog. The API needs a `GET /products/:id` endpoint that returns a single product's details as JSON. If the product exists, respond with its data. If it does not exist, return a meaningful JSON error response with the appropriate HTTP status code. If an unexpected error occurs during retrieval, log it and return a safe generic error message — never expose internal details to the client.

The product data is managed through a repository class that already exists (`app/repos/product_repo.rb`, class `MyApp::Repos::ProductRepo`), which has a method `by_id(id)` that returns a relation. Calling `.one` on it returns the product struct or `nil` if not found. The action should get the product repo from the container without looking it up directly by key at runtime.

## Output Specification

Produce the following files:

- `app/actions/products/show.rb` — the Hanami Action class for the endpoint
- `config/routes.rb` — (or the relevant route addition) showing how the route is registered

The action file should be complete and runnable. Show the full module/class structure with the dependency injection wiring and the `#handle` implementation.
