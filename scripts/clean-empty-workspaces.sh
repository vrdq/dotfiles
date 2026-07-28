#!/usr/bin/env python3
import subprocess
import json

def run(cmd):
    return subprocess.check_output(cmd, shell=True).decode()

def hypr(cmd):
    subprocess.run(f"hyprctl dispatch {cmd}", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

try:
    clients = json.loads(run("hyprctl clients -j"))
    monitors = json.loads(run("hyprctl monitors -j"))

    if not monitors:
        exit(0)

    active_ws = monitors[0]["activeWorkspace"]["id"]

    # Map workspace_id -> list of client addresses
    ws_clients = {}
    for c in clients:
        ws_id = c["workspace"]["id"]
        if ws_id > 0:  # ignore special workspaces
            ws_clients.setdefault(ws_id, []).append(c["address"])

    # Determine target workspace to move focus to (one before active_ws)
    target_ws = max(1, active_ws - 1)

    # 1. Immediately switch focus to the previous workspace
    hypr(f"workspace {target_ws}")

    # 2. Re-index remaining workspaces with windows to 1, 2, 3...
    if ws_clients:
        sorted_active_ws_ids = sorted(ws_clients.keys())
        mapping = {}
        for new_idx, old_id in enumerate(sorted_active_ws_ids, start=1):
            if old_id != new_idx:
                mapping[old_id] = new_idx

        # Move windows for mapped workspaces
        for old_id, new_id in mapping.items():
            for addr in ws_clients[old_id]:
                hypr(f"movetoworkspacesilent {new_id},address:{addr}")

        # If the target_ws was re-indexed, focus its new ID
        final_ws = mapping.get(target_ws, target_ws)
        hypr(f"workspace {final_ws}")

except Exception as e:
    pass
