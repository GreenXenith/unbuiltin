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

    player:set_armor_groups({
        fall_damage_add_percent = 1300,
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

core.registered_on_player_events = {}
core.register_on_player_event = function(callback)
    table.insert(core.registered_on_player_events, callback)
end

table.insert(core.registered_on_player_hpchanges.modifiers, function(player, _, reason)
    local data
    if reason.type == "fall" then
        data = {pos = player:get_pos(), velocity = player:get_velocity()}
    elseif reason.type == "node_damage" then
        data = {pos = reason.node_pos, node = reason.node}
    else
        return 0
    end

    for _, callback in pairs(core.registered_on_player_events) do
        callback(player, reason.type, data)
    end

    return 0
end)

if not core.has_feature("abm_without_neighbors") then
    core.register_playerevent(function(player, event)
        if event == "breath_changed" then
            if player:get_breath() ~= core.PLAYER_MAX_BREATH_DEFAULT then
                player:set_breath(core.PLAYER_MAX_BREATH_DEFAULT)
            end
        end
    end)
else
    core.register_on_joinplayer(function(player)
        -- Keep node_damage because why not
        player:set_flags({
            breathing = false,
            drowning = false,
        })
    end)
end
