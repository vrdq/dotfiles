# dotfiles

Personal desktop configuration for Hyprland and DankMaterialShell, tuned for low latency and a dark oxocarbon look.

Includes an installer that backs up existing configurations before linking, along with a rollback script to undo changes.

## Overview

- **Compositor**: Hyprland configured via Lua (`hyprland.lua`) with direct scanout for games, dwindle tiling, and dynamic monitor detection so foreign display outputs don't produce black screens.
- **Desktop Shell**: DankMaterialShell with Oxocarbon dark palette, custom status bar, clipboard history, and media controls.
- **Terminal**: Kitty with a green cursor trail, subtle background opacity (0.85), and Powerline tabs.
- **Shells**: Fish with custom prompt and `eza` aliases; Bash configured with `ble.sh` autosuggestions.
- **Editor**: Neovim with LazyVim and automatic DMS theme synchronization (`colors/dms.lua`).
- **Crosshair Overlay**: Custom C + GTK layer-shell crosshair (`src/crosshair`) and Qt configuration panel (`crosshair-gui`).
- **Scripts**: Screenshot capture to clipboard, GPU detection launcher, and power profile toggle.

## Installation

Open a terminal (like Konsole in KDE) and run:

```bash
git clone https://github.com/vrdq/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

Or run directly via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/vrdq/dotfiles/main/install.sh | bash
```

The installer will:
1. Detect and offer to install all missing packages (`hyprland`, `dms-shell-hyprland`, `kitty`, `fish`, `fastfetch`, fonts, and utilities) via `pacman`.
2. Back up conflicting configuration files to `~/.dotfiles-backup/`.
3. Deploy the dotfiles, compile the crosshair overlay, and link wallpapers.
4. Pre-select Hyprland in your display manager (SDDM/greetd).
5. Prompt you to reboot straight into your new desktop.

Options:
- `./install.sh --dry-run`: Preview changes without touching files.
- `./install.sh -y`: Automated non-interactive installation.

### Safety & Backups

The installer will not overwrite existing configurations blindly:
- Conflicting files are backed up to `~/.dotfiles-backup/backup-<timestamp>/`.
- A `rollback.sh` script is generated inside each backup directory.
- Run `./uninstall.sh` at any time to restore your original files and remove dotfiles symlinks.
- Display configuration includes fallback rules so unknown monitor identifiers still get an active display.
- NVIDIA environment flags are only set if an NVIDIA GPU is physically present on the system.

## Keybinds

| Key | Action |
| --- | --- |
| `Super + Q` | Terminal (Kitty) |
| `Super` / `Super + Space` | DMS Spotlight launcher |
| `Super + C` | Clipboard history |
| `Super + E` | File manager (Dolphin) |
| `Super + N` | Neovim |
| `Super + S` | Spoff (Spotify TUI) |
| `Super + Shift + X` | Toggle screen crosshair |
| `Ctrl + Q` | Toggle power profile (Balanced / Performance) |
| `Super + Tab` | Show / restore desktop |
| `Super + A` | Unminimize last window |
| `Print` | Interactive area screenshot to clipboard |
| `Super + Z` | Toggle floating window |
| `Alt + F4` | Close active window |

## Repository Structure

```
├── .config/
│   ├── DankMaterialShell/  # DMS settings and Oxocarbon theme
│   ├── hypr/               # Hyprland Lua configuration & keybinds
│   ├── kitty/              # Kitty terminal config & themes
│   ├── fish/               # Fish shell config, prompt & completions
│   ├── nvim/               # Neovim LazyVim setup with DMS theme
│   ├── crosshair/          # Crosshair overlay config
│   ├── btop/               # Resource monitor theme
│   ├── cava/               # Audio visualizer config
│   ├── easyeffects/        # Audio effect presets
│   ├── fastfetch/          # Terminal system info
│   ├── gtk-3.0/ & 4.0/     # Dark GTK styling
│   └── qt5ct/ & qt6ct/     # Qt theme overrides
├── home/                   # .bashrc, .blerc, .inputrc
├── scripts/                # Helper tools installed to ~/.local/bin
├── src/crosshair/          # Crosshair overlay C source and Makefile
├── wallpapers/             # Wallpaper assets
├── install.sh              # Idempotent installer with auto-backup
└── uninstall.sh            # Rollback script
```

## Requirements

Targeted at Arch Linux running Hyprland. Core tools:
- `hyprland` (with Lua support)
- `dms` (DankMaterialShell)
- `kitty`
- `fish` (or `bash`)

Optional tools used by keybinds and helper scripts:
- `fastfetch`, `btop`, `cava`, `eza`
- `grim`, `slurp`, `wl-clipboard` (screenshots)
- `power-profiles-daemon` (power switching)
- `gtk-layer-shell`, `gtk3` (to build the crosshair overlay)

Missing optional packages are skipped gracefully without breaking your desktop session.
