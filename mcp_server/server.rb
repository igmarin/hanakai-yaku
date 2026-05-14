# frozen_string_literal: true

# MCP stdio server for the hanami-skills repository.
#
# This server implements the Model Context Protocol (MCP) to expose Hanami skills
# as tools and resources. It provides two main tools:
#
# - `list_skills`: Lists all available skills with their metadata
# - `use_skill`: Fetches the full content of a specific skill by name
#
# Additionally, it exposes skill://* resources that serve SKILL.md content on demand,
# allowing clients to read skill files directly via the MCP resource protocol.
#
# @see SkillCatalog The catalog class that manages skill discovery and loading
require "bundler/setup"
require "mcp"
require_relative "skill_catalog"

# Initialize paths to skills and workflows directories
skills_root = File.expand_path("../skills", __dir__)
workflows_root = File.expand_path("../workflows", __dir__)

# Initialize the skill catalog with root directories
# @return [SkillCatalog] The catalog instance for skill discovery and loading
catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)

# Build MCP resources for each skill entry
# @return [Array<MCP::Resource>] Array of resources keyed by skill:// URIs
resources = catalog.list.map do |entry|
  MCP::Resource.new(
    uri: "skill://#{entry.name}",
    name: entry.name,
    description: entry.description,
    mime_type: "text/markdown"
  )
end

# Initialize the MCP server with name, version, and resources
# @return [MCP::Server] The configured MCP server instance
server = MCP::Server.new(
  name: "hanami-skills",
  version: "1.0.0",
  resources: resources
)

# Define the list_skills tool
#
# This tool returns a list of all available Hanami skills with their metadata,
# including name, description, category, and ecosystem sources.
#
# @param server_context [MCP::ServerContext] The server context for the request
# @param args [Hash] Additional arguments (unused)
# @return [MCP::Tool::Response] JSON response containing array of skill entries
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

# Define the use_skill tool
#
# This tool fetches the full content of a specific skill by its canonical name,
# including the SKILL.md content and all metadata fields.
#
# @param server_context [MCP::ServerContext] The server context for the request
# @param args [Hash] Arguments containing the skill name
# @option args [String] "name" The canonical name of the skill to load
# @return [MCP::Tool::Response] JSON response containing skill content and metadata
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

# Define the resources read handler
#
# This handler serves skill://* resources, returning the full SKILL.md content
# for the requested skill. Resources are read-only and provide direct access
# to skill files via the MCP resource protocol.
#
# @param params [Hash] Request parameters containing the resource URI
# @option params [String] :uri The skill:// URI to read
# @param server_context [MCP::ServerContext] The server context for the request
# @return [Array<Hash>] Array containing the resource content with URI, mimeType, and text
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

# Initialize the stdio transport and start the MCP server
#
# This creates a stdio-based transport that communicates with MCP clients
# via standard input/output, then opens the transport to begin serving requests.
#
# @return [MCP::Server::Transports::StdioTransport] The initialized transport
transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
