# frozen_string_literal: true

require "bundler/setup"
require "mcp"
require_relative "skill_catalog"

skills_root = File.expand_path("../skills", __dir__)
workflows_root = File.expand_path("../workflows", __dir__)

catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)

server = MCP::Server.new(name: "hanami-skills", version: "1.0.0")

server.tool("list_skills") do |_args|
  entries = catalog.list.map do |entry|
    {
      name: entry.name,
      description: entry.description,
      category: entry.category,
      ecosystem_sources: entry.ecosystem_sources
    }
  end
  entries
end

server.tool("use_skill") do |args|
  name = args[:name]
  begin
    skill = catalog.fetch(name)
    {
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
  rescue SkillCatalog::SkillNotFoundError => e
    {
      error: e.message,
      available_names: e.available_names
    }
  rescue StandardError => e
    {
      error: "Skill content unavailable: #{name} - #{e.message}"
    }
  end
end

catalog.each do |metadata|
  server.resource("skill://#{metadata.name}", metadata.description) do
    begin
      skill = catalog.fetch(metadata.name)
      skill.content
    rescue StandardError => e
      "Error loading skill #{metadata.name}: #{e.message}"
    end
  end
end

server.run(transport: :stdio)
