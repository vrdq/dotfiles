# 🌌 vrdq's Dotfiles

> Minimalist, high-performance, dark-monochrome Hyprland & DankMaterialShell desktop suite with zero-brick hardware independence.

![Hyprland](https://img.shields.io/badge/Compositor-Hyprland-00a3e0?style=flat-square&logo=arch-linux)
![Shell](https://img.shields.io/badge/Shell-Fish%20%7C%20Bash-43b581?style=flat-square)
![Terminal](https://img.shields.io/badge/Terminal-Kitty-e95420?style=flat-square)
![DMS](https://img.shields.io/badge/UI-DankMaterialShell-8a2be2?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

---

## ✨ Features & Ecosystem

- **Window Management**: [Hyprland](https://hyprland.org) configured with butter-smooth animations, crisp font rendering, dwindle tiling, and zero-latency game direct scanout.
- **Desktop Environment**: [DankMaterialShell (DMS)](https://github.com/AvengeMedia/DankMaterialShell) with custom Oxocarbon dark styling, interactive control center, unified clipboard manager, and media player integration.
- **Terminal & Shell**:
  - **Kitty** with glowing neon green cursor trail, subtle opacity (`0.85`), Powerline tab bars, and quick clipboard shortcuts.
  - **Fish & Bash** with `fastfetch` startup banner, icon-aware `eza` listings, and `ble.sh` autosuggestions.
- **Editor**: Fully configured **Neovim (LazyVim)** with live DankMaterial theme sync (`dms.lua`).
- **Gaming & Crosshair**: Custom lightweight Wayland layer-shell crosshair overlay utility (`crosshair` & `crosshair-gui`) with real-time HUD toggle (`Super + Shift + X`).
- **Theming & Consistency**: System-wide dark palette unified across GTK 3, GTK 4, Qt5, Qt6, Dolphin, btop, and cava.

---

## 🛡️ Anti-Brick Safety Architecture

These dotfiles are engineered to **never brick or crash** another user's machine:

1. **Universal Display Fallback**:
   - Includes automatic preferred-resolution detection (`monitor=,preferred,auto,1`).
   - Prevents black screens or crashes on setups with different monitors (DisplayPort, single monitor, ultrawide, or virtual machines).
2. **GPU & Driver Autodetection**:
   - `start-hyprland-clean` dynamically checks for NVIDIA vs. AMD/Intel hardware.
   - Non-NVIDIA systems will **never** have incompatible proprietary driver flags forced upon them.
3. **Zero Hardcoded Usernames**:
   - All configurations, Lua bindings, desktop entries, and scripts dynamically resolve `$HOME` and `$PATH`.
4. **Deterministic Backup & One-Click Rollback**:
   - The installer backs up existing configuration files to `~/.dotfiles-backup/backup-YYYYMMDD_HHMMSS/`.
   - Generates a dedicated `rollback.sh` inside each backup folder. Run `./uninstall.sh` at any time to immediately restore your system to its exact prior state.
5. **Non-Destructive Shell Protection**:
   - Plugins like `ble.sh`, `eza`, and `spoff` include presence guards and graceful fallbacks so interactive shells never hang or throw command-not-found errors.

---

## 🚀 Quick Install

### 1. Clone the repository
```bash
git clone https://github.com/vrdq/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Preview changes (Dry-Run)
```bash
./install.sh --dry-run
```

### 3. Install
```bash
./install.sh
```
*(Or use `./install.sh -y` to run without interactive confirmation)*

### 🔄 Uninstallation & Rollback
To cleanly revert all changes and restore previous configurations:
```bash
./uninstall.sh
```

---

## ⌨️ Keybinds Cheatsheet

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Super</kbd> + <kbd>Q</kbd> | Launch Terminal | Opens Kitty terminal |
| <kbd>Super</kbd> + <kbd>Space</kbd> / <kbd>Super</kbd> | App Launcher | DankMaterialShell Spotlight search |
| <kbd>Super</kbd> + <kbd>C</kbd> | Clipboard Manager | DMS clipboard history toggle |
| <kbd>Super</kbd> + <kbd>E</kbd> | File Manager | Dolphin with DankMatugen theme |
| <kbd>Super</kbd> + <kbd>N</kbd> | Code Editor | Neovim with DMS integration |
| <kbd>Super</kbd> + <kbd>S</kbd> | Music Player | [Spoff](https://github.com/vrdq/spoff) Spotify TUI |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd> | Crosshair Overlay | Toggle gaming reticle / crosshair |
| <kbd>Ctrl</kbd> + <kbd>Q</kbd> | Power Profile | Toggle Balanced / Performance modes |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | Keyboard Cleaning | Temporarily locks keyboard & touchpad for 60s |
| <kbd>Super</kbd> + <kbd>Tab</kbd> | Show Desktop | Minimizes/restores all windows |
| <kbd>Super</kbd> + <kbd>A</kbd> | Unminimize | Restores last minimized window |
| <kbd>Print</kbd> | Screenshot | Interactive area screenshot (copied to clipboard) |
| <kbd>Super</kbd> + <kbd>Z</kbd> | Float Window | Toggle floating mode for active window |
| <kbd>Alt</kbd> + <kbd>F4</kbd> | Close Window | Close current focused window |

---

## 📦 What's Inside

```
dotfiles/
├── .config/
│   ├── btop/              # System monitor themes & layout
│   ├── cava/              # Audio visualizer config & shaders
│   ├── crosshair/         # Gaming crosshair overlay settings
│   ├── DankMaterialShell/ # UI shell settings, plugins & oxocarbon theme
│   ├── dolphinrc          # File manager styling
│   ├── easyeffects/       # Audio enhancement DSP presets
│   ├── fastfetch/         # Fastfetch system info banner
│   ├── fish/              # Interactive Fish shell prompt & bindings
│   ├── gtk-3.0/ & 4.0/    # Modern GTK dark styling
│   ├── hypr/              # Hyprland Lua configuration & keybinds
│   ├── kitty/             # GPU terminal configuration
│   ├── nvim/              # Neovim (LazyVim + DMS colorscheme)
│   └── qt5ct/ & qt6ct/    # Qt theme integration
├── .local/share/
│   ├── applications/      # Crosshair desktop launcher
│   ├── color-schemes/     # Matugen KDE/Qt color palettes
│   └── icons/             # Custom application icons
├── home/                  # Clean .bashrc, .bash_profile, .blerc, .inputrc
├── scripts/               # Helper utilities & launchers
├── src/crosshair/         # Lightweight C source for crosshair overlay
├── wallpapers/            # Bundled minimalist wallpapers
├── install.sh             # Safe idempotent installer
└── uninstall.sh           # One-click rollback utility
```

---

## 📜 License
MIT © [vrdq](https://github.com/vrdq)
