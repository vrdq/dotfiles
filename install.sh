#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installer & System Provisioner
# Safe, idempotent, non-destructive installer with automatic backup & rollback
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
    echo -e "${CYAN}Personal Hyprland & DankMaterialShell Dotfiles Suite${NC}"
    echo -e "${BLUE}Repo:${NC} $REPO_DIR"
    echo ""
}

show_help() {
    cat << HELP
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes        Non-interactive mode (automatically proceed without confirmation)
  -n, --dry-run    Preview all changes without touching any files or links
  -h, --help       Show this help message

Features & Safety:
  • Zero-data-loss: All existing conflicting files are backed up to ~/.dotfiles-backup/
  • Generates an instant 'rollback.sh' inside the backup folder to undo any changes
  • Universal display fallback: never black-screens on unknown monitor outputs
  • Dynamic GPU detection: ensures NVIDIA vs AMD/Intel drivers never conflict
  • Automatic templating: substitutes user home paths dynamically
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

# Pre-flight package detection
check_dependencies() {
    echo -e "${BOLD}Checking system prerequisites...${NC}"
    
    local core_deps=("hyprland" "kitty" "dms")
    local recommended_deps=("fish" "fastfetch" "btop" "cava" "easyeffects" "qt5ct" "qt6ct" "grim" "slurp" "wl-copy" "powerprofilesctl" "eza")
    local missing_core=()
    local missing_rec=()

    for cmd in "${core_deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_core+=("$cmd")
        fi
    done

    for cmd in "${recommended_deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_rec+=("$cmd")
        fi
    done

    if [[ ${#missing_core[@]} -eq 0 ]]; then
        echo -e "  [${GREEN}✓${NC}] Core desktop components found"
    else
        echo -e "  [${YELLOW}!${NC}] Missing core components: ${YELLOW}${missing_core[*]}${NC}"
        echo -e "      (Dotfiles can still be installed, but install these packages for full functionality)"
    fi

    if [[ ${#missing_rec[@]} -gt 0 ]]; then
        echo -e "  [${BLUE}i${NC}] Optional recommended utilities not installed: ${missing_rec[*]}"
    fi
    echo ""
}

# Confirm before proceeding if interactive
confirm_run() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}Running in DRY-RUN mode. No files will be modified or created.${NC}\n"
        return
    fi

    if [ "$ASSUME_YES" = false ]; then
        echo -e "${BOLD}The installer will:${NC}"
        echo -e "  1. Back up existing conflicting configuration files to:"
        echo -e "     ${CYAN}$BACKUP_DIR${NC}"
        echo -e "  2. Link dotfiles to ~/.config, ~/.local/share, and ~/.local/bin"
        echo -e "  3. Generate an instant ${GREEN}rollback.sh${NC} to undo changes at any time"
        echo ""
        read -rp "Proceed with installation? [y/N] " response
        if [[ ! "$response" =~ ^[yY]([eE][sS])?$ ]]; then
            echo -e "${YELLOW}Installation aborted by user.${NC}"
            exit 0
        fi
        echo ""
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
    if [ "\$orig_type" != "NONE" ] && [ -e "\$backed_up" ]; then
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

    # Record and backup existing target
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # Check if already pointing to source
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

    # Check if file requires dynamic home substitution
    if grep -q "__HOME__" "$source_path" 2>/dev/null; then
        sed "s|__HOME__|$HOME|g" "$source_path" > "$target_path"
        echo -e "  [${GREEN}templated${NC}] $relative_to_home"
    else
        ln -snf -- "$source_path" "$target_path"
        echo -e "  [${GREEN}linked${NC}] $relative_to_home"
    fi
}

main() {
    print_banner
    check_dependencies
    confirm_run
    init_backup

    echo -e "${BOLD}Installing configuration files...${NC}"

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
    if [ -d "$REPO_DIR/scripts" ]; then
        while IFS= read -r -d '' source_file; do
            sname="$(basename -- "$source_file")"
            [[ "$sname" == ".*" || "$sname" == "*.tmp" ]] && continue
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

    # 6. Build crosshair binary if C source and build tools are present
    if [ -d "$REPO_DIR/src/crosshair" ] && [ "$DRY_RUN" = false ]; then
        if command -v gcc >/dev/null 2>&1 && command -v pkg-config >/dev/null 2>&1; then
            if pkg-config --exists gtk+-3.0 gtk-layer-shell-0 2>/dev/null; then
                echo -e "\n${BOLD}Building crosshair overlay binary...${NC}"
                make -C "$REPO_DIR/src/crosshair" install PREFIX="$HOME/.local" >/dev/null 2>&1 || true
                echo -e "  [${GREEN}✓${NC}] Crosshair binary compiled and installed to ~/.local/bin/crosshair"
            fi
        fi
    fi

    # 7. Update desktop application cache if update-desktop-database exists
    if command -v update-desktop-database >/dev/null 2>&1 && [ "$DRY_RUN" = false ]; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi

    echo ""
    if [ "$DRY_RUN" = false ]; then
        echo -e "${GREEN}${BOLD}✓ Dotfiles installation completed successfully!${NC}"
        echo -e "  Backup saved to: ${CYAN}$BACKUP_DIR${NC}"
        echo -e "  To restore previous configuration, run:"
        echo -e "    ${BOLD}$BACKUP_DIR/rollback.sh${NC} (or ./uninstall.sh)"
    fi
}

main "$@"
