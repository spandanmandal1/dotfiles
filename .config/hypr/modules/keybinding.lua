---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/configuring/core/binds/
-- Old bind flags: binde -> { repeating = true }, bindl -> { locked = true },
--                 bindel -> { locked = true, repeating = true }

local programs = require("modules.programs")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + P",              hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + SHIFT + C",      hl.dsp.window.close()) -- killactive
-- Logout (exit Hyprland). hyprshutdown closes apps gracefully first; fallback exits directly.
-- `hyprctl dispatch exit` no longer works with a Lua config; hyprctl dispatch takes Lua now
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + T",              hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",              hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))

-- Layout navigation
hl.bind(mainMod .. " + J",         hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K",         hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + O",         hl.dsp.layout("orientationcycle left top"))

-- Master swap
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"))

-- Toggle Fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Resize master area
hl.bind(mainMod .. " + H", hl.dsp.layout("mfact -0.02"), { repeating = true })
hl.bind(mainMod .. " + L", hl.dsp.layout("mfact +0.02"), { repeating = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Notification
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Clipboard
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd([[sh -c 'cliphist list | rofi -dmenu -display-columns 2 -p "Clipboard" -theme "${XDG_CONFIG_HOME:-$HOME/.config}/rofi/style.rasi" | cliphist decode | wl-copy']]))

-- Screenshots
hl.bind(mainMod .. " + Print",         hl.dsp.exec_cmd("hyprshot -m output")) -- Full screen
hl.bind("Print",                       hl.dsp.exec_cmd("hyprshot -m region")) -- Select region
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window")) -- Active window

-- Hyprsunset
hl.bind(mainMod .. " + F5",         hl.dsp.exec_cmd("pkill hyprsunset; hyprsunset -t 6500"))
hl.bind(mainMod .. " + SHIFT + F5", hl.dsp.exec_cmd("pkill hyprsunset; hyprsunset -t 3000"))
