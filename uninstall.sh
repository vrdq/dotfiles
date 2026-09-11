#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Uninstaller & Restorer
# Reverts all dotfiles changes and restores original configuration from backup
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_BASE="$HOME/.dotfiles-backup"

if [ ! -d "$BACKUP_BASE" ]; then
    echo -e "${RED}Error: No backup directory found at $BACKUP_BASE${NC}"
    echo "Cannot automatically rollback without a backup manifest."
    exit 1
fi

# Find available backups sorted by newest first
mapfile -t backups < <(find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d -name 'backup-*' | sort -r)

if [ ${#backups[@]} -eq 0 ]; then
    echo -e "${RED}No backups found in $BACKUP_BASE${NC}"
    exit 1
fi

latest_backup="${backups[0]}"

echo -e "${BOLD}Dotfiles Rollback & Restore${NC}"
echo -e "Found ${#backups[@]} backup(s). Latest backup:"
echo -e "  ${CYAN}$latest_backup${NC}"
echo ""
read -rp "Restore system from this backup? [y/N] " response

if [[ ! "$response" =~ ^[yY]([eE][sS])?$ ]]; then
    echo -e "${YELLOW}Rollback cancelled.${NC}"
    exit 0
fi

if [ -f "$latest_backup/rollback.sh" ]; then
    bash "$latest_backup/rollback.sh"
else
    echo -e "${RED}Error: rollback.sh not found inside $latest_backup${NC}"
    exit 1
fi
