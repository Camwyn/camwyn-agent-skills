#!/usr/bin/env bash
set -e

TARGET_DIR="${1:-$HOME/.agents/skills}"
RULES_DIR="${2:-$HOME/.agents/rules}"
BIN_DIR="${3:-$HOME/.agents/bin}"

echo "========================================"
echo "  Camwyn Agent Skills Installer"
echo "========================================"
echo "Target Directory : $TARGET_DIR"
echo "Rules Directory  : $RULES_DIR"
echo "Bin Directory    : $BIN_DIR"
echo ""

mkdir -p "$TARGET_DIR"
mkdir -p "$RULES_DIR"
mkdir -p "$BIN_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find all directories containing SKILL.md
find "$SCRIPT_DIR/skills" -name "SKILL.md" | while read -r skill_file; do
  skill_folder=$(dirname "$skill_file")
  skill_name=$(basename "$skill_folder")
  echo "  [LINK] Skill: $skill_name -> $skill_folder"
  ln -sfn "$skill_folder" "$TARGET_DIR/$skill_name"
done

# Link behavioral rules
if [ -d "$SCRIPT_DIR/rules" ]; then
  for rule in "$SCRIPT_DIR/rules"/*.md; do
    [ -f "$rule" ] || continue
    rule_name=$(basename "$rule")
    echo "  [LINK] Rule:  $rule_name"
    ln -sf "$rule" "$RULES_DIR/$rule_name"
  done
fi

# Install git post-commit hook if in a git repository
if [ -d "$SCRIPT_DIR/.git/hooks" ] && [ -f "$SCRIPT_DIR/scripts/post-commit" ]; then
  cp "$SCRIPT_DIR/scripts/post-commit" "$SCRIPT_DIR/.git/hooks/post-commit"
  chmod +x "$SCRIPT_DIR/.git/hooks/post-commit" "$SCRIPT_DIR/scripts/obsidian-post-commit.sh" 2>/dev/null || true
  echo "  [HOOK] Installed post-commit hook to $SCRIPT_DIR/.git/hooks/post-commit"
fi

# Install CLI tools into BIN_DIR
if [ -d "$SCRIPT_DIR/bin" ]; then
  for bin_file in "$SCRIPT_DIR/bin"/*; do
    [ -f "$bin_file" ] || continue
    bin_name=$(basename "$bin_file")
    cp "$bin_file" "$BIN_DIR/$bin_name"
    chmod +x "$BIN_DIR/$bin_name" 2>/dev/null || true
    echo "  [CLI]  $bin_name -> $BIN_DIR/$bin_name"
  done
fi

CONFIG_TARGET="$HOME/.agents/obsidian-config.json"
CONFIG_EXAMPLE="$SCRIPT_DIR/skills/obsidian-rag/obsidian-config.json.example"
if [ ! -f "$CONFIG_TARGET" ] && [ -f "$CONFIG_EXAMPLE" ]; then
  echo "  [CONFIG] Creating default config at $CONFIG_TARGET"
  cp "$CONFIG_EXAMPLE" "$CONFIG_TARGET"
fi

echo ""
echo "All skills, rules, and CLI tools installed and active!"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "NOTE: To run 'obsidian-sync' directly, add $BIN_DIR to your PATH:"
  echo "  export PATH=\"\$PATH:$BIN_DIR\""
fi
echo ""
echo "Next Step:"
echo "  Run '/obsidian-setup' in chat to configure your vault, or customize '$CONFIG_TARGET'"
echo ""
