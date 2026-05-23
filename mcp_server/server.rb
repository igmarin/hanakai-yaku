# frozen_string_literal: true

# MCP stdio server for the hanakai-yaku repository.
#
# This server implements the Model Context Protocol (MCP) to expose Hanakai Yaku (Skills)
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
require_relative "lib/skill_catalog/catalog"
require_relative "lib/server/server_builder"
require_relative "lib/server/resource_handler"

skills_root = File.expand_path("../skills", __dir__)
agents_root = File.expand_path("../agents", __dir__)

# Initialize the skill catalog with root directories
# @return [SkillCatalog] The catalog instance for skill discovery and loading
catalog = SkillCatalog.new(skills_root: skills_root, agents_root: agents_root)

# Build and configure the MCP server with tools and resources
# @return [MCP::Server] The configured MCP server instance
server = Server::ServerBuilder.build(catalog: catalog)

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
  Server::ResourceHandler.call(catalog: catalog, params: params, server_context: server_context)
end

# Initialize the stdio transport and start the MCP server
#
# This creates a stdio-based transport that communicates with MCP clients
# via standard input/output, then opens the transport to begin serving requests.
#
# @return [MCP::Server::Transports::StdioTransport] The initialized transport
transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
