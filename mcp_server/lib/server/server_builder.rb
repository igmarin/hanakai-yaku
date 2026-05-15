# frozen_string_literal: true

require_relative "tool_handlers/list_skills"
require_relative "tool_handlers/use_skill"
require_relative "resource_handler"

module Server
  # Builder for configuring the MCP server
  module ServerBuilder
    # Builds and configures the MCP server with tools and resources
    #
    # @param catalog [SkillCatalog] The skill catalog instance
    # @return [MCP::Server] The configured MCP server instance
    def self.build(catalog:)
      resources = build_resources(catalog)
      server = MCP::Server.new(
        name: "hanami-skills",
        version: "1.0.0",
        resources: resources
      )

      define_list_skills_tool(server, catalog)
      define_use_skill_tool(server, catalog)

      server
    end

    # Builds MCP resources for each skill entry
    #
    # @param catalog [SkillCatalog] The skill catalog instance
    # @return [Array<MCP::Resource>] Array of resources keyed by skill:// URIs
    def self.build_resources(catalog)
      catalog.list.map do |entry|
        MCP::Resource.new(
          uri: "skill://#{entry.name}",
          name: entry.name,
          description: entry.description,
          mime_type: "text/markdown"
        )
      end
    end

    # Defines the list_skills tool on the server
    #
    # @param server [MCP::Server] The MCP server instance
    # @param catalog [SkillCatalog] The skill catalog instance
    def self.define_list_skills_tool(server, catalog)
      server.define_tool(
        name: "list_skills",
        description: "List all available Hanami skills with their metadata",
        annotations: {
          read_only_hint: true,
          title: "List Skills"
        }
      ) do |server_context:, **args|
        ToolHandlers::ListSkills.call(catalog: catalog, server_context: server_context, **args)
      end
    end

    # Defines the use_skill tool on the server
    #
    # @param server [MCP::Server] The MCP server instance
    # @param catalog [SkillCatalog] The skill catalog instance
    def self.define_use_skill_tool(server, catalog)
      server.define_tool(
        name: "use_skill",
        description: "Fetch the full content of a specific skill by name",
        input_schema: {
          properties: {
            name: { type: "string", description: "The canonical name of the skill to load" }
          },
          required: ["name"]
        },
        annotations: {
          read_only_hint: true,
          title: "Use Skill"
        }
      ) do |server_context:, **args|
        ToolHandlers::UseSkill.call(catalog: catalog, server_context: server_context, **args)
      end
    end
  end
end
