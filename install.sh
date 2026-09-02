#!/usr/bin/env bash
#
# Dotfiles installer for Firefox Monochrome Theme
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREFOX_SRC="$SCRIPT_DIR/firefox"

echo "==> Firefox Monochrome Theme Installer"

# 1. Detect OS and Firefox profiles path
if [[ "$OSTYPE" == "darwin"* ]]; then
  BASE_DIR="$HOME/Library/Application Support/Firefox/Profiles"
elif [[ "$OSTYPE" == "linux"* ]]; then
  BASE_DIR="$HOME/.mozilla/firefox"
else
  echo "Unsupported OS: $OSTYPE. Please specify profile directory manually as first argument."
  exit 1
fi

PROFILE_DIR="${1:-}"

if [[ -z "$PROFILE_DIR" ]]; then
  if [[ ! -d "$BASE_DIR" ]]; then
    echo "Error: Firefox profiles directory not found at $BASE_DIR"
    exit 1
  fi

  # Find default / default-release profile
  PROFILE_DIR=$(find "$BASE_DIR" -maxdepth 1 -type d \( -name "*.default-release" -o -name "*.default" \) | head -n 1)

  if [[ -z "$PROFILE_DIR" || ! -d "$PROFILE_DIR" ]]; then
    echo "Error: Could not automatically find default Firefox profile in $BASE_DIR"
    echo "Usage: $0 /path/to/firefox/profile"
    exit 1
  fi
fi

echo "==> Target Profile: $PROFILE_DIR"

# 2. Backup existing configuration if present
BACKUP_DIR="$PROFILE_DIR/chrome_backup_$(date +%Y%m%d_%H%M%S)"
if [[ -d "$PROFILE_DIR/chrome" || -f "$PROFILE_DIR/user.js" ]]; then
  echo "==> Backing up existing configuration to: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  [[ -d "$PROFILE_DIR/chrome" ]] && cp -r "$PROFILE_DIR/chrome" "$BACKUP_DIR/"
  [[ -f "$PROFILE_DIR/user.js" ]] && cp "$PROFILE_DIR/user.js" "$BACKUP_DIR/"
fi

# 3. Install chrome directory and user.js
echo "==> Installing chrome/ stylesheets and extension-icons..."
mkdir -p "$PROFILE_DIR/chrome/extension-icons"
cp "$FIREFOX_SRC/chrome/userChrome.css" "$PROFILE_DIR/chrome/userChrome.css"
cp "$FIREFOX_SRC/chrome/extension-icons/"*.svg "$PROFILE_DIR/chrome/extension-icons/"

echo "==> Configuring user.js preferences..."
if [[ -f "$PROFILE_DIR/user.js" ]]; then
  # Append preferences if not already present
  grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$PROFILE_DIR/user.js" || \
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$PROFILE_DIR/user.js"
  grep -q "svg.context-properties.content.enabled" "$PROFILE_DIR/user.js" || \
    echo 'user_pref("svg.context-properties.content.enabled", true);' >> "$PROFILE_DIR/user.js"
else
  cp "$FIREFOX_SRC/user.js" "$PROFILE_DIR/user.js"
fi

echo "==> Installation complete!"
echo "==> Restart Firefox to apply the changes."
