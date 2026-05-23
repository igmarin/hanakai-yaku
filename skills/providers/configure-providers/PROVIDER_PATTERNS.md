# Provider Patterns Reference

## ROM Connection Provider

```ruby
# config/providers/rom.rb
Hanami.app.register_provider(:rom) do
  prepare do
    require "rom"
    require "rom-sql"
  end

  start do
    configuration = ROM::Configuration.new(
      :sql,
      target["settings"].database_url,
      extensions: [:pg_json]
    )

    configuration.auto_registration(
      target.root.join("slices").to_s,
      namespace: false
    )

    register("rom", ROM.container(configuration))
  end
end
```

## Redis Provider

```ruby
# config/providers/redis.rb
Hanami.app.register_provider(:redis) do
  prepare do
    require "redis"
  end

  start do
    client = Redis.new(url: target["settings"].redis_url)
    register("redis", client)
  end
end
```

## HTTP Client Provider

```ruby
# config/providers/http_client.rb
Hanami.app.register_provider(:http_client) do
  prepare do
    require "faraday"
  end

  start do
    client = Faraday.new(
      url: target["settings"].api_base_url,
      headers: { "Authorization" => "Bearer #{target["settings"].api_token}" }
    ) do |f|
      f.request :json
      f.response :json
    end
    register("http_client", client)
  end
end
```

## Background Job Provider

```ruby
# config/providers/sidekiq.rb
Hanami.app.register_provider(:sidekiq) do
  prepare do
    require "sidekiq"
  end

  start do
    Sidekiq.configure_client do |config|
      config.redis = { url: target["settings"].redis_url }
    end

    register("sidekiq.client", Sidekiq::Client)
  end
end
```

## Settings Structure

Every provider that needs configuration reads from settings:

```ruby
# config/settings.rb
module HanamiApp
  class Settings < Hanami::Settings
    setting :database_url, constructor: Types::String
    setting :redis_url, constructor: Types::String
    setting :api_base_url, constructor: Types::String
    setting :api_token, constructor: Types::String
  end
end
```

Settings use dry-types for type safety. The `constructor` coerces the ENV value to the correct type.
