function fish_prompt
    # Match the existing compact prompt; no directory or Git subprocesses needed.
    set_color green
    echo -n $USER
    set_color normal
    echo -n '@'
    set_color cyan
    echo -n (prompt_hostname)
    set_color green
    echo -n ' $ '
    set_color normal
end
