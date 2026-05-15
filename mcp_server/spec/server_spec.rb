# frozen_string_literal: true

require "tmpdir"
require_relative "spec_helper"
require_relative "../lib/skill_catalog/catalog"
require "mcp"
require "json"

RSpec.describe "MCP Server" do
  let(:fixture_dir) { Dir.mktmpdir("mcp_server_spec") }
  let(:skills_root) { File.join(fixture_dir, "skills") }
  let(:workflows_root) { File.join(fixture_dir, "workflows") }

  before do
    FileUtils.mkdir_p(File.join(skills_root, "db", "test-skill"))
    FileUtils.mkdir_p(File.join(workflows_root, "test-workflow"))

    File.write(
      File.join(skills_root, "db", "test-skill", "SKILL.md"),
      <<~SKILL
        ---
        name: test-skill
        version: "1.0.0"
        license: MIT
        description: A test skill
        ecosystem_sources:
          - hanami/hanami
        ---

        # Test Skill

        ## Quick Reference

        | Scenario | Approach |
        |---|---|
        | Test | Test |
      SKILL
    )

    File.write(
      File.join(workflows_root, "test-workflow", "SKILL.md"),
      <<~SKILL
        ---
        name: test-workflow
        version: "1.0.0"
        license: MIT
        description: A test workflow
        ecosystem_sources:
          - hanami/hanami
        ---

        # Test Workflow

        ## Quick Reference

        | Scenario | Approach |
        |---|---|
        | Test | Test |
      SKILL
    )
  end

  after do
    FileUtils.rm_rf(fixture_dir)
  end

  describe "SkillCatalog initialization" do
    it "initializes catalog with correct paths" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      expect(catalog.skills_root).to eq(skills_root)
      expect(catalog.workflows_root).to eq(workflows_root)
    end

    it "lists all skills and workflows" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      entries = catalog.list
      names = entries.map(&:name)

      expect(names).to include("test-skill", "test-workflow")
      expect(entries.length).to eq(2)
    end

    it "fetches skill content by name" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      skill = catalog.fetch("test-skill")

      expect(skill.name).to eq("test-skill")
      expect(skill.content).to include("# Test Skill")
      expect(skill.metadata.name).to eq("test-skill")
    end
  end

  describe "MCP Resource generation" do
    it "creates resources for all skills" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      resources = catalog.list.map do |entry|
        MCP::Resource.new(
          uri: "skill://#{entry.name}",
          name: entry.name,
          description: entry.description,
          mime_type: "text/markdown"
        )
      end

      expect(resources.length).to eq(2)
      expect(resources.first.uri).to start_with("skill://")
      expect(resources.first.mime_type).to eq("text/markdown")
    end
  end

  describe "list_skills tool response format" do
    it "returns JSON-serializable entries" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      entries = catalog.list.map do |entry|
        {
          name: entry.name,
          description: entry.description,
          category: entry.category,
          ecosystem_sources: entry.ecosystem_sources
        }
      end

      expect(entries).to be_an(Array)
      expect { JSON.generate(entries) }.not_to raise_error
      expect(entries.first).to have_key(:name)
      expect(entries.first).to have_key(:description)
      expect(entries.first).to have_key(:category)
      expect(entries.first).to have_key(:ecosystem_sources)
    end
  end

  describe "use_skill tool response format" do
    it "returns skill content with metadata" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      skill = catalog.fetch("test-skill")

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

      expect(result).to have_key(:name)
      expect(result).to have_key(:content)
      expect(result).to have_key(:metadata)
      expect(result[:metadata]).to have_key(:name)
      expect(result[:metadata]).to have_key(:version)
      expect(result[:metadata]).to have_key(:license)
      expect { JSON.generate(result) }.not_to raise_error
    end
  end

  describe "resource read handler format" do
    it "returns resource with uri, mimeType, and text" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      skill = catalog.fetch("test-skill")

      resource = [{
        uri: "skill://test-skill",
        mimeType: "text/markdown",
        text: skill.content
      }]

      expect(resource).to be_an(Array)
      expect(resource.first).to have_key(:uri)
      expect(resource.first).to have_key(:mimeType)
      expect(resource.first).to have_key(:text)
      expect(resource.first[:uri]).to eq("skill://test-skill")
      expect(resource.first[:mimeType]).to eq("text/markdown")
      expect(resource.first[:text]).to include("# Test Skill")
    end
  end

  describe "error handling" do
    it "raises SkillNotFoundError for unknown skill" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      expect {
        catalog.fetch("nonexistent")
      }.to raise_error(::SkillNotFoundError)
    end

    it "SkillNotFoundError includes available names" do
      catalog = SkillCatalog.new(skills_root: skills_root, workflows_root: workflows_root)
      begin
        catalog.fetch("nonexistent")
      rescue ::SkillNotFoundError => e
        expect(e.available_names).to include("test-skill", "test-workflow")
      end
    end
  end
end
