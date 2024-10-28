-- EVERYTHING MUST GO --

-- Reset some registered tables
for _, registered in ipairs({
    "abms",
    "lbms",
    "entities",

    "playerevents",
    "privileges",

    "aliases",

    "on_chat_messages",
    "on_newplayers",
    "on_dieplayers",
    "on_respawnplayers",
    "on_prejoinplayers",
    "on_joinplayers",
    "on_leaveplayers",
    "on_player_receive_fields",

    "chatcommands",
    "on_chatcommands",
    "on_punchnodes",
    "on_placenodes",
    "on_dignodes",
}) do
    local t = core["registered_" .. registered]
    for i in ipairs(t) do t[i] = nil end
end

-- Clear the player environment and interface
core.register_on_joinplayer(function(player)
    player:hud_set_flags({
        basic_debug = false,
        chat = false,
        crosshair = false,
        hotbar = false,
        wielditem = false,
    })

    -- Disabling the minimap without the "disabled" warning
    player:set_minimap_modes({{type = "off", label = " "}}, 0)

    player:set_properties({
        visual = "sprite",
        textures = {"blank.png"},
        physical = false,
        eye_height = 0,
        zoom_fov = 0,
    })

    player:set_inventory_formspec("")
    player:set_formspec_prepend("")

    player:set_physics_override({
        gravity = 0,
        jump = 0,
        speed = 0,
        sneak = false,
    })

    player:set_sky({
        type = "plain",
        base_color = "#888",
        clouds = false,
    })

    player:set_sun({
        visible = false,
        sunrise_visible = false,
    })

    player:set_moon({
        visible = false,
    })

    player:set_stars({
        visible = false,
    })

    player:set_pos(vector.zero())
end)

core.set_timeofday(0.5)
