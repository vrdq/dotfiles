#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installer & Desktop Provisioner
# Converts any Arch/CachyOS system (including KDE) into Hyprland + DMS suite.
# Safe, idempotent, non-destructive installer with automatic backup & rollback.
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Bootstrap clone if piped directly from curl/web
if [ ! -d "$REPO_DIR/.config" ]; then
    echo -e "${CYAN}Bootstrapping repository into ~/dotfiles...${NC}"
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}Error: git is required. Install with: sudo pacman -S git${NC}"
        exit 1
    fi
    rm -rf "$HOME/dotfiles"
    git clone https://github.com/vrdq/dotfiles.git "$HOME/dotfiles"
    cd "$HOME/dotfiles"
    if [ -e /dev/tty ]; then
        exec ./install.sh "$@" </dev/tty
    else
        exec ./install.sh "$@"
    fi
fi

BACKUP_BASE="$HOME/.dotfiles-backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/backup-$TIMESTAMP"
MANIFEST="$BACKUP_DIR/manifest.txt"

DRY_RUN=false
ASSUME_YES=false

print_banner() {
    cat << "BANNER"
  __   __ ___  ___   ___   ___     ___   ___  _____ ___ ___ _    ___ ___ 
  \ \ / /| _ \|   \ / _ \ / __|   |   \ / _ \|_   _| __|_ _| |  | __/ __|
   \ V / |   /| |) | (_) |\__ \   | |) | (_) | | | | _| | || |__| _|\__ \
    \_/  |_|_\|___/ \__\_\|___/   |___/ \___/  |_| |_| |___|____|___|___/
BANNER
    echo -e "${CYAN}Hyprland & DankMaterialShell Desktop Setup${NC}"
    echo -e "${BLUE}Source:${NC} $REPO_DIR"
    echo ""
}

show_help() {
    cat << HELP
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes        Non-interactive mode (automatically install packages and proceed)
  -n, --dry-run    Preview all changes without touching any files or links
  -h, --help       Show this help message

Features:
  • Auto-installs Hyprland, DMS, Kitty, Fish, and utilities on Arch/CachyOS
  • Backs up existing configs to ~/.dotfiles-backup/ with one-command rollback
  • Pre-configures display manager so you can reboot directly into Hyprland
  • Universal display auto-detection (no black screens on different monitors)
  • Dynamic GPU detection (safe on Intel, AMD, and NVIDIA)
HELP
}

# Parse command line flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            ASSUME_YES=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

read_user() {
    local prompt="$1"
    local default_val="$2"
    local var_name="$3"
    local response=""

    if [ -t 0 ]; then
        read -rp "$prompt" response || true
    elif [ -e /dev/tty ]; then
        read -rp "$prompt" response </dev/tty || true
    else
        response="$default_val"
    fi
    response="${response:-$default_val}"
    eval "$var_name=\"$response\""
}

# 1. Package Installation for Arch / CachyOS systems (e.g. running from KDE)
install_packages() {
    if [ "$DRY_RUN" = true ]; then return; fi
    if ! command -v pacman >/dev/null 2>&1; then
        echo -e "${YELLOW}Non-pacman distribution detected. Please ensure Hyprland and DMS packages are installed manually.${NC}\n"
        return
    fi

    # Core desktop, shell, theming, build tools, utilities, and rice apps
    local core_pkgs=(
        hyprland
        dms-shell-hyprland
        hyprpaper
        hyprpolkitagent
        xdg-desktop-portal-hyprland
        xdg-desktop-portal
        kitty
        fish
        fastfetch
        btop
        cava
        eza
        wl-clipboard
        wl-clip-persist
        power-profiles-daemon
        qt5ct
        qt6ct
        ttf-jetbrains-mono-nerd
        noto-fonts
        breeze-icons
        breeze-gtk
        gcc
        make
        pkgconf
        gtk3
        gtk-layer-shell
        dolphin
        neovim
        playerctl
        python-pyqt6
        jq
        grim
        slurp
        libnotify
        easyeffects
        librewolf
        prismlauncher
        gwenview
    )

    local extra_apps=(
        vesktop
        bibata-cursor-theme
    )

    local missing=()
    for pkg in "${core_pkgs[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    for pkg in "${extra_apps[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1 && ! pacman -Q "${pkg}-bin" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${BOLD}Missing rice packages detected (${#missing[@]} to install):${NC}"
        echo -e "  ${CYAN}${missing[*]}${NC}\n"

        local do_install="y"
        if [ "$ASSUME_YES" = false ]; then
            read_user "Install missing packages now? [Y/n] " "y" do_install
        fi

        if [[ ! "$do_install" =~ ^[nN] ]]; then
            local pacman_install=()
            local aur_install=()

            for pkg in "${missing[@]}"; do
                if pacman -Si "$pkg" >/dev/null 2>&1; then
                    pacman_install+=("$pkg")
                elif pacman -Si "${pkg}-bin" >/dev/null 2>&1; then
                    pacman_install+=("${pkg}-bin")
                else
                    aur_install+=("$pkg")
                fi
            done

            if [ ${#pacman_install[@]} -gt 0 ]; then
                echo -e "\n${BOLD}Installing packages with sudo pacman...${NC}"
                sudo pacman -S --needed --noconfirm "${pacman_install[@]}"
                echo -e "${GREEN}✓ Official repository packages installed successfully.${NC}\n"
            fi

            if [ ${#aur_install[@]} -gt 0 ]; then
                local aur_helper=""
                if command -v paru >/dev/null 2>&1; then
                    aur_helper="paru"
                elif command -v yay >/dev/null 2>&1; then
                    aur_helper="yay"
                fi

                if [ -n "$aur_helper" ]; then
                    echo -e "${BOLD}Installing AUR packages with $aur_helper...${NC}"
                    "$aur_helper" -S --needed --noconfirm "${aur_install[@]}" || true
                else
                    echo -e "${YELLOW}Note: The following packages are in AUR/custom repos and can be installed via paru/yay:${NC}"
                    echo -e "  ${CYAN}${aur_install[*]}${NC}\n"
                fi
            fi

            # Enable power-profiles-daemon service if installed
            if command -v systemctl >/dev/null 2>&1; then
                sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
            fi
        else
            echo -e "${YELLOW}Skipping package install. Some features will not work until packages are installed.${NC}\n"
        fi
    else
        echo -e "  [${GREEN}✓${NC}] All rice packages are installed.\n"
    fi
}

# Create backup directory & manifest
init_backup() {
    if [ "$DRY_RUN" = true ]; then return; fi
    mkdir -p "$BACKUP_DIR"
    touch "$MANIFEST"

    # Create one-click rollback script
    cat << ROLLBACK_EOF > "$BACKUP_DIR/rollback.sh"
#!/usr/bin/env bash
# Automatic Rollback Script generated on $TIMESTAMP
set -euo pipefail

BACKUP_DIR="\$(cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="\$BACKUP_DIR/manifest.txt"

if [ ! -f "\$MANIFEST" ]; then
    echo "Error: manifest.txt not found in \$BACKUP_DIR"
    exit 1
fi

echo "Restoring backed up files from \$BACKUP_DIR..."

while IFS='|' read -r rel_path orig_type; do
    [ -z "\$rel_path" ] && continue
    target="\$HOME/\$rel_path"
    backed_up="\$BACKUP_DIR/\$rel_path"

    # Remove installed symlink or file
    if [ -e "\$target" ] || [ -L "\$target" ]; then
        rm -rf "\$target"
    fi

    # Restore original file if it existed
    if [ "\$orig_type" != "NONE" ] && { [ -e "\$backed_up" ] || [ -L "\$backed_up" ]; }; then
        mkdir -p "\$(dirname -- "\$target")"
        mv "\$backed_up" "\$target"
        echo "  Restored: \$target"
    fi
done < "\$MANIFEST"

echo "Rollback completed successfully!"
ROLLBACK_EOF
    chmod +x "$BACKUP_DIR/rollback.sh"
}

# Safe backup & symlink / template function
install_file() {
    local source_path="$1"
    local target_path="$2"
    local relative_to_home="${target_path#"$HOME/"}"

    if [ "$DRY_RUN" = true ]; then
        echo -e "  [${CYAN}dry-run${NC}] $source_path -> $target_path"
        return
    fi

    # 1. Check if file requires dynamic home substitution
    if grep -q "__HOME__" "$source_path" 2>/dev/null; then
        local rendered_content
        rendered_content="$(sed "s|__HOME__|$HOME|g" "$source_path")"

        # If target already exists as a non-symlink file and content matches, skip
        if [ -f "$target_path" ] && [ ! -L "$target_path" ]; then
            if cmp -s <(echo "$rendered_content") "$target_path"; then
                return
            fi
        fi

        # Backup existing target if it exists or is a symlink
        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            mkdir -p "$(dirname -- "$BACKUP_DIR/$relative_to_home")"
            mv -- "$target_path" "$BACKUP_DIR/$relative_to_home"
            echo "$relative_to_home|EXISTS" >> "$MANIFEST"
        else
            echo "$relative_to_home|NONE" >> "$MANIFEST"
        fi

        mkdir -p "$(dirname -- "$target_path")"
        echo "$rendered_content" > "$target_path"
        echo -e "  [${GREEN}templated${NC}] $relative_to_home"
        return
    fi

    # 2. DMS runtime auto-generated files (copy initial templates, don't symlink to git)
    if [[ "$relative_to_home" == .config/hypr/dms/* ]]; then
        if [ -L "$target_path" ]; then
            rm -f "$target_path"
        fi
        if [ ! -f "$target_path" ]; then
            mkdir -p "$(dirname -- "$target_path")"
            cp -f "$source_path" "$target_path"
            echo -e "  [${GREEN}copied${NC}] $relative_to_home"
        fi
        return
    fi

    # 3. Standard symlinked files
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # If already pointing to source, skip
        if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
            return
        fi

        mkdir -p "$(dirname -- "$BACKUP_DIR/$relative_to_home")"
        mv -- "$target_path" "$BACKUP_DIR/$relative_to_home"
        echo "$relative_to_home|EXISTS" >> "$MANIFEST"
    else
        echo "$relative_to_home|NONE" >> "$MANIFEST"
    fi

    mkdir -p "$(dirname -- "$target_path")"
    ln -snf -- "$source_path" "$target_path"
    echo -e "  [${GREEN}linked${NC}] $relative_to_home"
}

# Pre-configure SDDM so Hyprland is selected as default session
configure_display_manager() {
    if [ "$DRY_RUN" = true ]; then return; fi

    # Check for SDDM (standard on KDE)
    if [ -d /var/lib/sddm ]; then
        echo -e "${CYAN}Ensuring Hyprland is selected in SDDM...${NC}"
        if [ -f /var/lib/sddm/state.conf ]; then
            sudo sed -i 's|^Session=.*|Session=/usr/share/wayland-sessions/hyprland.desktop|' /var/lib/sddm/state.conf 2>/dev/null || true
        else
            echo -e "[Last]\nSession=/usr/share/wayland-sessions/hyprland.desktop" | sudo tee /var/lib/sddm/state.conf >/dev/null 2>&1 || true
        fi
    fi
}

main() {
    print_banner
    install_packages

    if [ "$ASSUME_YES" = false ] && [ "$DRY_RUN" = false ]; then
        echo -e "${BOLD}Ready to deploy dotfiles:${NC}"
        echo -e "  • Backs up conflicting configs to ${CYAN}$BACKUP_DIR${NC}"
        echo -e "  • Links Hyprland, DMS, Kitty, Fish, and GTK/Qt themes"
        echo -e "  • Builds custom Wayland crosshair overlay"
        local confirm="y"
        read_user "Proceed with dotfiles setup? [Y/n] " "y" confirm
        if [[ "$confirm" =~ ^[nN] ]]; then
            echo -e "${YELLOW}Installation aborted.${NC}"
            exit 0
        fi
        echo ""
    fi

    init_backup
    echo -e "${BOLD}Deploying configuration files...${NC}"

    # 0. Migrate any legacy directory symlinks to real directories
    if [ -d "$REPO_DIR/.config" ]; then
        for dir in "$REPO_DIR/.config"/*; do
            if [ -d "$dir" ]; then
                local bname="$(basename -- "$dir")"
                local target_dir="$HOME/.config/$bname"
                if [ -L "$target_dir" ]; then
                    echo -e "  [${YELLOW}migrating${NC}] Converting legacy directory symlink to real directory: .config/$bname"
                    mkdir -p "$(dirname -- "$BACKUP_DIR/.config/$bname")"
                    mv -- "$target_dir" "$BACKUP_DIR/.config/$bname"
                    echo ".config/$bname|DIR_SYMLINK" >> "$MANIFEST"
                    mkdir -p "$target_dir"
                fi
            fi
        done
    fi

    # 1. Install .config files
    while IFS= read -r -d '' source_file; do
        rel="${source_file#"$REPO_DIR/.config/"}"
        target="$HOME/.config/$rel"
        install_file "$source_file" "$target"
    done < <(find "$REPO_DIR/.config" -type f -print0)

    # 2. Install .local/share files (icons, applications, colorschemes)
    if [ -d "$REPO_DIR/.local/share" ]; then
        while IFS= read -r -d '' source_file; do
            rel="${source_file#"$REPO_DIR/.local/share/"}"
            target="$HOME/.local/share/$rel"
            install_file "$source_file" "$target"
        done < <(find "$REPO_DIR/.local/share" -type f -print0)
    fi

    # 3. Install scripts into ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    # Clean up deprecated scripts from previous rice versions
    if [ -e "$HOME/.local/bin/cleaning-mode" ] || [ -L "$HOME/.local/bin/cleaning-mode" ]; then
        rm -f "$HOME/.local/bin/cleaning-mode"
    fi
    if [ -d "$REPO_DIR/scripts" ]; then
        while IFS= read -r -d '' source_file; do
            sname="$(basename -- "$source_file")"
            [[ "$sname" == .* || "$sname" == *.tmp ]] && continue
            target="$HOME/.local/bin/$sname"
            install_file "$source_file" "$target"
            [ "$DRY_RUN" = false ] && chmod +x "$target"
        done < <(find "$REPO_DIR/scripts" -maxdepth 1 -type f -print0)
    fi

    # 4. Install home files (bashrc, blerc, etc.)
    if [ -d "$REPO_DIR/home" ]; then
        while IFS= read -r -d '' source_file; do
            hname="$(basename -- "$source_file")"
            target="$HOME/$hname"
            install_file "$source_file" "$target"
        done < <(find "$REPO_DIR/home" -maxdepth 1 -type f -print0)
    fi

    # 5. Set up default wallpaper link
    if [ -f "$REPO_DIR/wallpapers/Windows11-Twilight-dank-monochrome.png" ]; then
        mkdir -p "$HOME/.config/hypr"
        install_file "$REPO_DIR/wallpapers/Windows11-Twilight-dank-monochrome.png" "$HOME/.config/hypr/wallpaper.png"
    fi

    # 6. Build crosshair overlay binary
    if [ -d "$REPO_DIR/src/crosshair" ] && [ "$DRY_RUN" = false ]; then
        if command -v gcc >/dev/null 2>&1 && command -v pkg-config >/dev/null 2>&1; then
            if pkg-config --exists gtk+-3.0 gtk-layer-shell-0 2>/dev/null; then
                echo -e "\n${BOLD}Building crosshair overlay binary...${NC}"
                make -C "$REPO_DIR/src/crosshair" install PREFIX="$HOME/.local" >/dev/null 2>&1 || true
                echo -e "  [${GREEN}✓${NC}] Crosshair binary compiled and installed to ~/.local/bin/crosshair"
            fi
        fi
    fi

    # 7. Update desktop application database
    if command -v update-desktop-database >/dev/null 2>&1 && [ "$DRY_RUN" = false ]; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi

    # 8. Configure display manager preselection
    configure_display_manager

    echo ""
    if [ "$DRY_RUN" = false ]; then
        echo -e "${GREEN}${BOLD}✓ Dotfiles installation completed successfully!${NC}"
        echo -e "  Backup saved to: ${CYAN}$BACKUP_DIR${NC}"
        echo -e "  To revert anytime: ${BOLD}./uninstall.sh${NC}\n"

        echo -e "${BOLD}Next steps:${NC}"
        echo -e "  1. Reboot your computer"
        echo -e "  2. On your login screen (SDDM/greetd), ensure ${GREEN}Hyprland${NC} is chosen as the session"
        echo -e "  3. Log in to enjoy the Hyprland + DankMaterialShell setup!\n"

        local do_reboot="n"
        read_user "Would you like to reboot now? [y/N] " "n" do_reboot
        if [[ "$do_reboot" =~ ^[yY]([eE][sS])?$ ]]; then
            echo -e "${GREEN}Rebooting...${NC}"
            systemctl reboot
        fi
    fi
}

main "$@"
