-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/configuring/core/animations/

hl.config({
    animations = {
        enabled = true,
    },
})

-- bezier = fast, 0.2, 0.8, 0.2, 1
hl.curve("fast", { type = "bezier", points = { {0.2, 0.8}, {0.2, 1} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "fast" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "fast" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "fast" })
