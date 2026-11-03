-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
-- exec-once is replaced by the "hyprland.start" event, which fires once per session
-- (not on config reload).

hl.on("hyprland.start", function()
    -- hl.exec_cmd("waybar & hyprpaper & firefox")

    -- hl.exec_cmd("~/.config/waybar/scripts/launch.sh")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")

    -- Clipboard
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data

    hl.exec_cmd("wl-clip-persist --clipboard regular")
end)
