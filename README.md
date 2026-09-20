# dotfiles

Personal desktop configuration for Hyprland and DankMaterialShell on Arch Linux, configured for low input latency and a dark monochrome Oxocarbon theme.

Includes an automated installer that backs up existing configuration files before symlinking, with a rollback script to restore earlier settings.

## System Components

- Hyprland: configured via Lua (`hyprland.lua`) with direct scanout for games, dwindle tiling, and dynamic monitor detection to avoid black screens on external displays.
- DankMaterialShell: dark Oxocarbon theme with status bar, clipboard history, and media controls.
- Kitty: terminal with green cursor trail, 0.85 background opacity, and tab bar.
- Fish and Bash: Fish for interactive shell use with custom prompt; Bash configured with `ble.sh` for syntax highlighting and autosuggestions.
- Neovim: LazyVim configuration synchronized with DMS theme tokens.
- Crosshair overlay: native Wayland layer-shell daemon in C (`src/crosshair`) with Qt settings dialog (`crosshair-gui`).
- Brave Origin: dark monochrome browser theme and JetBrains Mono webpage extension with native icon font preservation.
- Helper scripts: screenshot utility to clipboard, GPU offload wrapper (`game-run`), and power profile toggle.

## Installation

Run the installer via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/vrdq/dotfiles/main/install.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/vrdq/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer runs through these steps:
1. Checks for required packages (`hyprland`, `dms-shell-hyprland`, `kitty`, `fish`, `fastfetch`, fonts) and offers to install missing dependencies via pacman.
2. Backs up existing configuration files to `~/.dotfiles-backup/`.
3. Creates symlinks into `~/.config/` and compiles the crosshair overlay daemon.
4. Pre-selects Hyprland in your display manager (greetd/SDDM).

Installer options:
- `./install.sh`: interactive menu (Full Install, Fast Update, Doctor, Gaming, Rollback).
- `./install.sh -u`: fast update mode (re-templates configs and reloads desktop without package checks).
- `./install.sh -d`: run health checks to verify desktop packages and tools.
- `./install.sh -g`: apply low-latency kernel sysctl parameters.
- `./install.sh --revert`: restore configuration from the most recent backup.
- `./install.sh -n`: dry-run mode to preview changes.

## Dots CLI Tool

The repo installs `dots` to `~/.local/bin/dots` for maintenance:

```bash
dots status             # Check commit, display refresh rates, and theme status
dots update             # Pull latest commits, re-template, and reload desktop
dots doctor             # Health check verifying binaries, portals, and fonts
dots optimize           # Apply low-latency gaming sysctl settings
dots reload             # Reload Hyprland and restart DMS shell
dots backup             # Create snapshot of ~/.config to ~/.dotfiles-backup/
```

## Gaming Optimizations

Hyprland is configured with direct scanout and immediate page-flipping for full-screen games to bypass compositor latency:

```ini
windowrulev2 = immediate, class:^(minecraft|lunarclient|prismlauncher|steam_app_.*|cs2)$
```

The `game-run` wrapper launches titles under `gamemoderun`, sets performance CPU profiles, disables V-Sync (`vblank_mode=0`, `__GL_SYNC_TO_VBLANK=0`), and handles PRIME offloading on dual-GPU hardware:

```bash
game-run lunarclient
game-run prismlauncher
game-run steam
```

## Backups and Rollback

The installer creates timestamped backups in `~/.dotfiles-backup/backup-<timestamp>/` before modifying any files. Each backup includes a `rollback.sh` script. Run `./uninstall.sh` at any time to remove symlinks and restore your original files.

## Keybinds

| Key | Action |
| --- | --- |
| `Super + Q` | Terminal (Kitty) |
| `Super` / `Super + Space` | DMS Spotlight launcher |
| `Super + C` | Clipboard history |
| `Super + E` | File manager (Dolphin) |
| `Super + N` | Neovim |
| `Super + S` | Spoff music player |
| `Super + Shift + X` | Toggle screen crosshair |
| `Ctrl + Q` | Toggle power profile (Balanced / Performance) |
| `Super + Tab` | Show desktop |
| `Super + A` | Unminimize last window |
| `Print` | Area screenshot to clipboard |
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
│   ├── fastfetch/          # Terminal system info
│   ├── gtk-3.0/ & 4.0/     # Dark GTK styling
│   └── qt5ct/ & qt6ct/     # Qt theme overrides
├── home/                   # .bashrc, .blerc, .inputrc
├── scripts/                # Helper tools installed to ~/.local/bin
├── src/crosshair/          # Crosshair overlay C source and Makefile
├── themes/                 # Brave Origin theme and JetBrains Mono web extension
├── wallpapers/             # Wallpaper assets
├── install.sh              # Installer with automated backup
└── uninstall.sh            # Rollback script
```

## Requirements

Base packages:
- `hyprland` (compiled with Lua support)
- `dms` (DankMaterialShell)
- `kitty`
- `fish` or `bash`

Optional utilities:
- `fastfetch`, `btop`, `cava`, `eza`
- `grim`, `slurp`, `wl-clipboard` (for screenshots)
- `power-profiles-daemon` (for power switching)
- `gtk-layer-shell`, `gtk3` (to build crosshair overlay)

## Shell and Session Tests

Run `bash tests/check-shells.sh` to check shell syntax, noninteractive setup, PATH idempotence, and Fish bindings.

Fish prompt functions live in `functions/fish_prompt.fish`. Noninteractive shells skip terminal styling and avoid duplicate PATH entries. The session launcher checks PCI attributes directly instead of running `lspci` and `grep` pipelines, while retaining the NVIDIA readiness wait and explicit `AQ_DRM_DEVICES` overrides.
