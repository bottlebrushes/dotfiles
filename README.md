# Dotfiles

Personal dotfiles and system configurations for macOS.

---

## Components

- **macOS Window Management**: Tiling window manager ([yabai](https://github.com/koekeishiya/yabai)), hotkey daemon ([skhd](https://github.com/koekeishiya/skhd)), and menu bar widgets ([Barik](https://github.com/barik-app/barik)).
- **Firefox Monochrome Theme**: Uniform monochrome extension icon setup for Firefox using crisp, adaptive [Simple Icons](https://simpleicons.org/) vectors and `userChrome.css`.

---

## Directory Structure

```text
.
├── install.sh                  # Modular installer & symlink manager
├── README.md
├── yabai/
│   └── yabairc                 # Yabai BSP tiling rules, padding, & Barik signals
├── skhd/
│   └── skhdrc                  # Global hotkeys (directional navigation, resize, warp)
├── barik/
│   └── barik-config.toml       # Barik menu bar status bar widgets & styling
└── firefox/
    ├── chrome/
    │   ├── userChrome.css      # Core toolbar & panel CSS overrides
    │   └── extension-icons/    # Theme-adaptive SVG icon assets
    │       ├── bitwarden.svg
    │       ├── darkreader.svg
    │       └── ublock.svg
    └── user.js                 # Required Firefox configuration flags
```

---

## Window Management (Yabai + SKHD + Barik)

Configured for a **bsp** (binary space partitioning) layout with directional focus navigation, space pinning, and live event signals to Barik.

### Directional Keybindings Cheat Sheet

All directional shortcuts use the inverted-T layout (`J` = Left, `K` = Down, `I` = Up, `L` = Right):

| Action | Shortcut | Command |
|---|---|---|
| **Focus window (West)** | `⌥ Option + J` | `yabai -m window --focus west` |
| **Focus window (South)** | `⌥ Option + K` | `yabai -m window --focus south` |
| **Focus window (North)** | `⌥ Option + I` | `yabai -m window --focus north` |
| **Focus window (East)** | `⌥ Option + L` | `yabai -m window --focus east` |
| **Swap window** | `⇧ Shift + ⌥ Option + [J / K / I / L]` | `yabai -m window --swap [dir]` |
| **Warp / Move window** | `⇧ Shift + ⌘ Cmd + ⌥ Option + [J / K / I / L]` | `yabai -m window --warp [dir]` |
| **Resize window** | `⌃ Ctrl + ⌥ Option + [J / K / I / L]` | `yabai -m window --resize ...` |
| **Balance window sizes** | `⇧ Shift + ⌥ Option + 0` | `yabai -m space --balance` |
| **Toggle float & center** | `⌥ Option + T` | `yabai -m window --toggle float; ...` |
| **Toggle fullscreen zoom** | `⌥ Option + F` | `yabai -m window --toggle zoom-fullscreen` |
| **Toggle split orientation** | `⌥ Option + E` | `yabai -m window --toggle split` |
| **Rotate tree 90°** | `⌥ Option + R` | `yabai -m space --rotate 90` |

### Space Assignments & App Rules

- **Space 2**: Slack
- **Space 3**: Spark Desktop
- **Space 4**: Notion Calendar
- **Space 5**: TIDAL
- **Always float**: Messages, System Settings, Calculator, Activity Monitor, Disk Utility, Keychain Access, App Store, FaceTime, Claude, etc.

### Barik Integration

Event signals in `yabairc` communicate space and window focus transitions directly to Barik via UNIX domain socket `/tmp/barik-yabai.sock`.

---

## Firefox Monochrome Extension Icons

A clean, uniform monochrome icon setup for Firefox that replaces extension toolbar icons with adaptive vectors.

- **Theme-Adaptive**: `@media (prefers-color-scheme: dark)` renders `#cfcfd8` in dark mode and `#2b2a33` in light mode.
- **Zero Overhead**: Pure CSS (`userChrome.css`) and local vector assets — no remote requests or background scripts.

---

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/bottlebrushes/dotfiles.git
cd dotfiles

# Install both Window Management symlinks and Firefox theme
./install.sh

# Or install selectively:
./install.sh wm        # Links ~/.yabairc, ~/.skhdrc, ~/.barik-config.toml
./install.sh firefox   # Configures Firefox profile (backs up previous setup)
```
