#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
bash -n "$repo/home/.bashrc" "$repo/scripts/start-hyprland-clean"
fish --no-config -n "$repo/.config/fish/config.fish" "$repo/.config/fish/functions/fish_prompt.fish"

bash --noprofile --norc -c '
    set -e
    source "$1/home/.bashrc"
    before=$PATH
    source "$1/home/.bashrc"
    [[ "$PATH" == "$before" ]]
    ! alias ls >/dev/null 2>&1
    [[ -z ${PS1-} ]]
' bash "$repo"
echo 'PASS: Bash PATH is idempotent and noninteractive setup is minimal'

fish --no-config -c '
    set baseline (functions ls | string collect)
    source "$argv[1]/.config/fish/config.fish"
    test "$baseline" = "$(functions ls | string collect)"; or exit 1
    test "$EDITOR" = nvim; or exit 1
    contains -- "$HOME/.local/bin" $PATH; or exit 1
' "$repo"
echo 'PASS: Fish scripts retain environment without redefining ls'

# Check the configured bindings and autoloaded prompt without opening a terminal.
fish --no-config -i -c '
    set -p fish_function_path "$argv[1]/.config/fish/functions"
    source "$argv[1]/.config/fish/config.fish"
    fish_user_key_bindings
    string match -q "*history-search-backward*" (bind up); or exit 1
    string match -q "*accept-autosuggestion*" (bind tab); or exit 1
    string match -q "* \$ *" (fish_prompt | string collect); or exit 1
' "$repo"
echo 'PASS: Fish prompt autoload and existing keybindings'

# Run against real read-only PCI/DRM metadata but replace the final compositor.
# An existing GPU selection must survive; arguments must not be split.
output=$(PATH="$repo/tests/fixtures:$PATH" AQ_DRM_DEVICES=/dev/test-override \
    bash "$repo/scripts/start-hyprland-clean" 'argument with spaces' --test)
[[ "$output" == *'GPU=/dev/test-override'* ]]
[[ "$output" == *'ARG=argument with spaces'* ]]
[[ "$output" == *'ARG=--test'* ]]
echo 'PASS: Session launcher preserves GPU override and arguments (mock compositor)'
