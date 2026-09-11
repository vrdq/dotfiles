function fish_prompt
    # Palette sampled from the reference: black glass, terminal green,
    # warm white text, and a quiet gray cursor/status color.
    set -l last_status $status
    set -l green (set_color 66FF77)
    set -l white (set_color F2F0EA)
    set -l dim (set_color 8C8C8C)
    set -l red (set_color FF6B78)
    set -l cursor (set_color --background D7D7D7; set_color 161616)
    set -l prompt_char '$'
    set -l reset (set_color normal)

    echo "$green━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"

    set -l branch ''
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set branch " "(git branch --show-current 2>/dev/null)
    end

    echo -n "$green$USER$reset@$white"(prompt_pwd)" $green$prompt_char $reset"

    if test $last_status -ne 0
        echo -n "$red✕ $last_status$reset "
    end
    echo -n "$cursor▐$reset "
end
