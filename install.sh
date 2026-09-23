#!/usr/bin/env bash
#
# Dotfiles installer for macOS Window Management (Yabai, SKHD, Barik) and Firefox Theme
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREFOX_SRC="$SCRIPT_DIR/firefox"

link_config() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "    $dst is already correctly linked."
    return 0
  fi

  if [[ -e "$dst" ]]; then
    local backup="${dst}.bak_$(date +%Y%m%d_%H%M%S)"
    echo "    Backing up existing $dst to $backup"
    mv "$dst" "$backup"
  fi

  echo "    Linking $src -> $dst"
  ln -sf "$src" "$dst"
}

install_wm() {
  echo "==> Installing Window Management configs (Yabai, SKHD, Barik)..."
  link_config "$SCRIPT_DIR/yabai/yabairc" "$HOME/.yabairc"
  link_config "$SCRIPT_DIR/skhd/skhdrc" "$HOME/.skhdrc"
  link_config "$SCRIPT_DIR/barik/barik-config.toml" "$HOME/.barik-config.toml"
  chmod +x "$SCRIPT_DIR/yabai/yabairc"
  echo "==> Window management configs linked successfully."
  echo "    To reload configs:"
  echo "      yabai --restart-service"
  echo "      skhd --restart-service"
}

install_firefox() {
  local profile_dir="${1:-}"
  echo "==> Firefox Monochrome Theme Installer"

  # 1. Detect OS and Firefox profiles path
  if [[ "$OSTYPE" == "darwin"* ]]; then
    BASE_DIR="$HOME/Library/Application Support/Firefox/Profiles"
  elif [[ "$OSTYPE" == "linux"* ]]; then
    BASE_DIR="$HOME/.mozilla/firefox"
  else
    echo "Unsupported OS: $OSTYPE. Please specify profile directory manually as first argument."
    return 1
  fi

  if [[ -z "$profile_dir" ]]; then
    if [[ ! -d "$BASE_DIR" ]]; then
      echo "Error: Firefox profiles directory not found at $BASE_DIR"
      return 1
    fi

    # Find default / default-release profile
    profile_dir=$(find "$BASE_DIR" -maxdepth 1 -type d \( -name "*.default-release" -o -name "*.default" \) | head -n 1)

    if [[ -z "$profile_dir" || ! -d "$profile_dir" ]]; then
      echo "Error: Could not automatically find default Firefox profile in $BASE_DIR"
      echo "Usage: $0 firefox /path/to/firefox/profile"
      return 1
    fi
  fi

  echo "==> Target Profile: $profile_dir"

  # 2. Backup existing configuration if present
  local backup_dir="$profile_dir/chrome_backup_$(date +%Y%m%d_%H%M%S)"
  if [[ -d "$profile_dir/chrome" || -f "$profile_dir/user.js" ]]; then
    echo "==> Backing up existing configuration to: $backup_dir"
    mkdir -p "$backup_dir"
    [[ -d "$profile_dir/chrome" ]] && cp -r "$profile_dir/chrome" "$backup_dir/"
    [[ -f "$profile_dir/user.js" ]] && cp "$profile_dir/user.js" "$backup_dir/"
  fi

  # 3. Install chrome directory and user.js
  echo "==> Installing chrome/ stylesheets and extension-icons..."
  mkdir -p "$profile_dir/chrome/extension-icons"
  cp "$FIREFOX_SRC/chrome/userChrome.css" "$profile_dir/chrome/userChrome.css"
  cp "$FIREFOX_SRC/chrome/extension-icons/"*.svg "$profile_dir/chrome/extension-icons/"

  echo "==> Configuring user.js preferences..."
  if [[ -f "$profile_dir/user.js" ]]; then
    # Append preferences if not already present
    grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$profile_dir/user.js" || \
      echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$profile_dir/user.js"
    grep -q "svg.context-properties.content.enabled" "$profile_dir/user.js" || \
      echo 'user_pref("svg.context-properties.content.enabled", true);' >> "$profile_dir/user.js"
  else
    cp "$FIREFOX_SRC/user.js" "$profile_dir/user.js"
  fi

  echo "==> Firefox installation complete! Restart Firefox to apply changes."
}

case "${1:-all}" in
  wm)
    install_wm
    ;;
  firefox)
    shift || true
    install_firefox "${1:-}"
    ;;
  all)
    install_wm
    echo ""
    install_firefox ""
    ;;
  *)
    if [[ -d "${1:-}" ]]; then
      # Backward compatibility: argument is profile dir
      install_firefox "$1"
    else
      echo "Usage: $0 [all|wm|firefox] [firefox_profile_dir]"
      exit 1
    fi
    ;;
esac
