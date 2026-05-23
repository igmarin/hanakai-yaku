#!/usr/bin/env bash
set -euo pipefail

# validate-plugins.sh — checks frontmatter consistency and tile.json ↔ disk sync
# Adapted from rails-agent-skills for hanakai-yaku

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

info()  { echo "  [OK] $*"; }
error() { echo "  [FAIL] $*"; errors=$((errors + 1)); }

echo "=== tile.json inventory check ==="

# Every skill in tile.json must exist on disk
while IFS= read -r path; do
  if [ -f "$ROOT/$path" ]; then
    info "tile.json → disk: $path"
  else
    error "tile.json references missing file: $path"
  fi
done < <(ruby -rjson -e 'JSON.parse(File.read(ARGV[0])).fetch("skills").each { |_,v| puts v.fetch("path") }' "$ROOT/tile.json")

echo ""
echo "=== disk → tile.json check ==="

# Every SKILL.md on disk must be in tile.json
while IFS= read -r file; do
  rel="${file#$ROOT/}"
  if ruby -rjson -e '
    paths = JSON.parse(File.read(ARGV[0])).fetch("skills").values.map { |v| v.fetch("path") }
    exit paths.include?(ARGV[1]) ? 0 : 1
  ' "$ROOT/tile.json" "$rel"; then
    info "disk → tile.json: $rel"
  else
    error "disk has SKILL.md not in tile.json: $rel"
  fi
done < <(find "$ROOT/skills" -name 'SKILL.md' | sort)

echo ""
echo "=== frontmatter name check ==="

while IFS= read -r file; do
  dir_name="$(basename "$(dirname "$file")")"
  fm_name="$(ruby -ryaml -e '
    content = File.read(ARGV[0])
    yaml_end = content.index("---", 3) || content.length
    fm = YAML.safe_load(content[4..yaml_end-1])
    puts fm["name"]
  ' "$file")"
  if [ "$fm_name" = "$dir_name" ]; then
    info "$file: name '$fm_name' matches directory '$dir_name'"
  else
    error "$file: name '$fm_name' does NOT match directory '$dir_name'"
  fi
done < <(find "$ROOT/skills" -name 'SKILL.md' | sort)

echo ""
if [ "$errors" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$errors error(s) found."
  exit 1
fi
