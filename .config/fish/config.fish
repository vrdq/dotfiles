set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx GIT_EDITOR nvim

# Ensure user local bin is on PATH
fish_add_path -g $HOME/.local/bin

# Keep runtime paths available to scripts, but skip terminal-only setup below.
if test -d "$HOME/.bun"
    set --export BUN_INSTALL "$HOME/.bun"
    fish_add_path -g $BUN_INSTALL/bin
end

status is-interactive; or return

# Icon-aware directory listings with fallback to standard ls
if type -q eza
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first --long --all --header --classify'
    alias la='eza --icons --group-directories-first --all --classify'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
end

if type -q fastfetch
    alias ff='fastfetch'
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting ""
    set -g fish_key_bindings fish_user_key_bindings

    # Bindings and prompt are autoloaded from functions/, with one definition each.

    function fish_title
    end
end

fish_add_path /home/vrdq/.spicetify
