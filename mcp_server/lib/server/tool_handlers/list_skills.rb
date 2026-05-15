# frozen_string_literal: true

module Server
  module ToolHandlers
    # Handler for the list_skills tool
    module ListSkills
      # Returns a list of all available Hanami skills with their metadata
      #
      # @param catalog [SkillCatalog] The skill catalog instance
      # @param server_context [MCP::ServerContext] The server context for the request
      # @param args [Hash] Additional arguments (unused)
      # @return [MCP::Tool::Response] JSON response containing array of skill entries
      def self.call(catalog:, server_context:, **args)
        entries = catalog.list.map do |entry|
          {
            name: entry.name,
            description: entry.description,
            category: entry.category,
            ecosystem_sources: entry.ecosystem_sources
          }
        end
        MCP::Tool::Response.new([{ type: "text", text: entries.to_json }])
      end
    end
  end
end
