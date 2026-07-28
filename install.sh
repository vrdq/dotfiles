#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

while IFS= read -r -d '' source_path; do
    relative_path="${source_path#"$repo_dir/"}"
    target_path="$HOME/$relative_path"
    mkdir -p "$(dirname -- "$target_path")"
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        mkdir -p "$(dirname -- "$backup_dir/$relative_path")"
        mv -- "$target_path" "$backup_dir/$relative_path"
    fi
    ln -s -- "$source_path" "$target_path"
done < <(find "$repo_dir/.config" -type f -print0)

printf 'Installed dotfiles. Existing files were backed up to: %s\n' "$backup_dir"

