# ~/.bashrc - Bash configuration

# Keep PATH available to login scripts without duplicating entries in nested shells.
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [[ -d "$HOME/.spicetify" && ":$PATH:" != *":$HOME/.spicetify:"* ]]; then
    export PATH="$PATH:$HOME/.spicetify"
fi

# Aliases, line editing, history and prompts are only for interactive terminals.
[[ $- == *i* ]] || return 0

# ── ble.sh (fish-like syntax highlighting + autosuggestions) ─────────────────
# Guarded so bash loads cleanly even if ble.sh is not installed
if [[ $- == *i* && -f /usr/share/blesh/ble.sh ]]; then
    source /usr/share/blesh/ble.sh --noattach
fi

# ── Colors & Aliases ──────────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first --long --all --header --classify'
    alias la='eza --icons --group-directories-first --all --classify'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
fi
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
command -v fastfetch >/dev/null 2>&1 && alias ff='fastfetch'

# ── Prompt ────────────────────────────────────────────────────────────────────
# green user, cyan host, blue path, green $
PS1='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\] \[\e[1;32m\]\$\[\e[0m\] '

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# ── Misc ──────────────────────────────────────────────────────────────────────
shopt -s checkwinsize   # update LINES/COLUMNS after each command
shopt -s globstar       # enable ** glob

# ── ble.sh attach + disable syntax highlighting ───────────────────────────────
if [[ ${BLE_VERSION-} ]]; then
    ble-attach
    # Set all syntax faces to plain terminal default color after attach
    for __f in syntax_default syntax_command syntax_quoted syntax_quotation \
               syntax_expr syntax_error syntax_varname syntax_delimiter \
               syntax_param_expansion syntax_history_expansion \
               syntax_function_name syntax_comment syntax_glob \
               syntax_brace syntax_tilde syntax_document syntax_document_begin \
               command_builtin_dot command_builtin command_alias \
               command_function command_file command_keyword \
               command_jobs command_directory; do
        ble-color-defface "$__f" fg=default
    done
    unset __f
fi

. "$HOME/.cargo/env"

# SLSsteam: Add wrapper to PATH
export PATH="$HOME/.local/share/SLSsteam/path:$PATH"
