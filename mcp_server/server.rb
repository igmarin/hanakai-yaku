# frozen_string_literal: true

# MCP stdio server for the hanami-skills repository.
# Exposes two tools — list_skills and use_skill — plus skill://* resources
# that serve SKILL.md content on demand.
require "bundler/setup"
require "mcp"
require_relative "skill_catalog"

skills_root = File.expand_path("../skills", __dir__)
workflows_root = File.expand_path("../workflows", __dir__)

catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)

resources = catalog.list.map do |entry|
  MCP::Resource.new(
    uri: "skill://#{entry.name}",
    name: entry.name,
    description: entry.description,
    mime_type: "text/markdown"
  )
end

server = MCP::Server.new(
  name: "hanami-skills",
  version: "1.0.0",
  resources: resources
)

server.define_tool(
  name: "list_skills",
  description: "List all available Hanami skills with their metadata",
  annotations: {
    read_only_hint: true,
    title: "List Skills"
  }
) do |server_context:, **args|
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
  rescue SkillCatalog::SkillNotFoundError => e
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

server.resources_read_handler do |params, server_context:|
  uri = params[:uri].to_s
  name = uri.sub(%r{^skill://}, "")

  begin
    skill = catalog.fetch(name)
    [{
      uri: uri,
      mimeType: "text/markdown",
      text: skill.content
    }]
  rescue SkillCatalog::SkillNotFoundError => e
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

transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
