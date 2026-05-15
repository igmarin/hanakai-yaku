# frozen_string_literal: true

require_relative "../../skill_catalog/errors"

module Server
  module ToolHandlers
    # Handler for the use_skill tool
    module UseSkill
      # Fetches the full content of a specific skill by name
      #
      # @param catalog [SkillCatalog] The skill catalog instance
      # @param server_context [MCP::ServerContext] The server context for the request
      # @param args [Hash] Arguments containing the skill name
      # @option args [String] "name" The canonical name of the skill to load
      # @return [MCP::Tool::Response] JSON response containing skill content and metadata
      def self.call(catalog:, server_context:, **args)
        name = args["name"] || args[:name]
        unless name.is_a?(String)
          return MCP::Tool::Response.new(
            [{ type: "text", text: { error: "Invalid arguments. Expected: { name: '<skill-name>' }" }.to_json }],
            error: true
          )
        end
        begin
          skill = catalog.fetch(name)
          result = {
            name: skill.name,
            content: skill.content,
            metadata: {
              name: skill.metadata.name,
              version: skill.metadata.version,
              license: skill.metadata.license,
              description: skill.metadata.description,
              ecosystem_sources: skill.metadata.ecosystem_sources,
              tags: skill.metadata.tags,
              category: skill.metadata.category,
              is_workflow: skill.metadata.is_workflow
            }
          }
          MCP::Tool::Response.new([{ type: "text", text: result.to_json }])
        rescue ::SkillNotFoundError => e
          MCP::Tool::Response.new(
            [{ type: "text", text: { error: e.message, available_names: e.available_names }.to_json }],
            error: true
          )
        rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM => e
          # Log filesystem errors with message and backtrace per AGENTS.md conventions
          $stderr.puts("[ERROR] #{e.message}")
          $stderr.puts(e.backtrace.first(5).join("\n"))
          MCP::Tool::Response.new(
            [{ type: "text", text: { error: "Skill content unavailable: #{name} - #{e.message}" }.to_json }],
            error: true
          )
        end
      end
    end
  end
end
