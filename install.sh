#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the absolute directory of this install script
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define XDG target destinations
CONFIG_DIR="$HOME/.config/hyperion"
TEMPLATES_DIR="$HOME/.local/share/hyperion/templates"
THEMES_DIR="$HOME/.local/share/hyperion/themes"

echo "=========================================="
echo " Installing/Updating My Launcher Assets"
echo "=========================================="

# 1. Ensure target directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$THEMES_DIR"

# 2. Update Assets & Templates (Always sync changes from repo)
echo "-> Syncing assets and templates to $TEMPLATES_DIR..."
cp -ru "$REPO_DIR/templates/"* "$TEMPLATES_DIR/"
# Using cp with update (-u) and recursive (-r) flags.
# It only copies if the source file is newer than the destination file.
echo "-> Syncing assets and templates to $THEMES_DIR..."
cp -ru "$REPO_DIR/themes/"* "$THEMES_DIR/"

# 3. Handle Configuration (Do NOT overwrite existing user configs)
if [[ ! -f "$CONFIG_DIR/config.yaml" ]]; then
  echo "-> No existing config found. Provisioning default config..."
  if [[ -f "$REPO_DIR/config/config.yaml" ]]; then
    cp "$REPO_DIR/config/config.yaml" "$CONFIG_DIR/config.yaml"
  else
    echo "---" >"$CONFIG_DIR/config.yaml"
  fi
  echo "   Config created at $CONFIG_DIR/config.yaml"
else
  echo "-> Existing config found at $CONFIG_DIR/config.yaml (Skipped to prevent overwriting)."
fi
