-- #######################################################################################
-- HYPRLAND LUA CONFIG (migrated from hyprland.conf)
-- #######################################################################################

-- Refer to the wiki for more information.
-- https://wiki.hypr.land/configuring/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- Modules live in ~/.config/hypr/modules/ and are loaded with require("modules.<name>").
-- Order matches the old `source =` order.

require("modules.monitors")
require("modules.programs")
require("modules.autostart")
require("modules.env")
require("modules.permission")
require("modules.decoration")
require("modules.animation")
require("modules.windowrules")
require("modules.layout")
require("modules.misc")
require("modules.input")
require("modules.keybinding")
