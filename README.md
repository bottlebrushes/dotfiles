# Dotfiles — Firefox Monochrome Extension Icons

A clean, uniform monochrome icon setup for Firefox that replaces extension toolbar icons with crisp, adaptive [Simple Icons](https://simpleicons.org/) vectors.

---

## Highlights

- **Simple Icons Official Vectors**: Authentic brand silhouettes for primary extensions (uBlock Origin, Bitwarden, Dark Reader) normalized to unified toolbar silver-grey.
- **Theme-Adaptive**: Embedded `@media (prefers-color-scheme: dark)` styling ensures icons automatically render `#cfcfd8` in dark mode and `#2b2a33` in light mode.
- **Greyscale Fallback**: Extensions without custom SVGs are cleanly desaturated and dimmed with smooth hover-reveal animations.
- **Badge Preservation**: Notification badges (e.g. ad block counts, item counts) remain completely untouched and legible.
- **Zero Overhead**: Pure CSS (`userChrome.css`) and local vector assets — no remote requests, scripts, or bloat.

---

## Directory Structure

```text
.
├── install.sh                  # Automated profile installer with backup
├── README.md
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

## Quick Installation

```bash
git clone https://github.com/bettercoderthanyou/dotfiles.git
cd dotfiles
./install.sh
```

Or specify a custom Firefox profile path:

```bash
./install.sh "/path/to/Firefox/Profiles/xxxx.default-release"
```

Then **quit and restart Firefox**.

---

## Adding Custom Icons

1. Download an SVG from [Simple Icons](https://simpleicons.org/) or any icon library.
2. Add the adaptive theme style block to the `<svg>`:
   ```xml
   <style>
     * { fill: #cfcfd8; }
     @media (prefers-color-scheme: light) {
       * { fill: #2b2a33; }
     }
   </style>
   ```
3. Save to `firefox/chrome/extension-icons/<name>.svg`.
4. Add the extension selector in `firefox/chrome/userChrome.css`:
   ```css
   :is(
     #<extension_id>-browser-action .toolbarbutton-icon,
     [data-extensionid="<extension@id>" i] .toolbarbutton-icon,
     unified-extensions-item[extension-id="<extension@id>" i] .unified-extensions-item-icon
   ) {
     content: url("extension-icons/<name>.svg") !important;
     list-style-image: url("extension-icons/<name>.svg") !important;
   }
   ```
5. Run `./install.sh` and restart Firefox.
