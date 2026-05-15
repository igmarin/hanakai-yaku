# frozen_string_literal: true

require_relative "../skill_catalog/errors"

module Server
  # Handler for skill://* resources
  module ResourceHandler
    # Serves skill://* resources, returning the full SKILL.md content
    #
    # @param catalog [SkillCatalog] The skill catalog instance
    # @param params [Hash] Request parameters containing the resource URI
    # @option params [String] :uri The skill:// URI to read
    # @param server_context [MCP::ServerContext] The server context for the request
    # @return [Array<Hash>] Array containing the resource content with URI, mimeType, and text
    def self.call(catalog:, params:, server_context:)
      uri = params[:uri].to_s
      name = uri.sub(%r{^skill://}, "")

      begin
        skill = catalog.fetch(name)
        [{
          uri: uri,
          mimeType: "text/markdown",
          text: skill.content
        }]
      rescue ::SkillNotFoundError => e
        [{
          uri: uri,
          mimeType: "text/plain",
          text: "Skill not found: #{e.message}"
        }]
      rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM => e
        $stderr.puts("[ERROR] Failed to load skill #{name}: #{e.message}")
        $stderr.puts(e.backtrace.first(5).join("\n"))
        [{
          uri: uri,
          mimeType: "text/plain",
          text: "Error loading skill #{name}: #{e.message}"
        }]
      end
    end
  end
end
