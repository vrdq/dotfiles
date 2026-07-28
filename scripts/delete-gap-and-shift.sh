#!/usr/bin/env python3
import subprocess
import json

def run(cmd):
    return subprocess.check_output(cmd, shell=True).decode()

def hypr_eval(lua_code):
    cmd = f"hyprctl eval '{lua_code}'"
    subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

try:
    monitors = json.loads(run("hyprctl monitors -j"))
    if not monitors:
        exit(0)

    curr_ws = monitors[0]["activeWorkspace"]["id"]

    # Target previous workspace
    prev_ws = max(1, curr_ws - 1)

    # 1. Switch user focus to previous workspace (e.g. Workspace 2)
    hypr_eval(f'hl.dispatch(hl.dsp.focus({{ workspace = "{prev_ws}" }}))')

    # 2. Shift all windows on workspaces > curr_ws down by 1 (e.g. Workspace 4 becomes 3)
    clients = json.loads(run("hyprctl clients -j"))
    for c in clients:
        ws_id = c["workspace"]["id"]
        if ws_id > curr_ws:
            new_ws = ws_id - 1
            addr = c["address"]
            hypr_eval(f'hl.dispatch(hl.dsp.window.move({{ workspace = "{new_ws}", window = "address:{addr}", follow = false }}))')

except Exception as e:
    pass
