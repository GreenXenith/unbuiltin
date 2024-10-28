-- EVERYTHING MUST GO --

unbuiltin = {
    no_hud = true, -- ALL hud
    no_player = true, -- Player visuals
    no_gravity = true,
    no_movement = true,
    no_forms = true,
    no_world = true,
    no_death = true,
    no_hp = true, -- HP + breath
    no_falling = true, -- Falling nodes
    no_items = true, -- Item entities
    no_privs = true, -- All non-client privs
    unregister_commands = true,
    no_commands = true,
}

local to_unregister = {
    no_death = {
        on_dieplayers = 1,
        on_player_receive_fields = 1,
        on_respawnplayers = 1,
    },
    unregister_commands = {
        chatcommands = -1,
    },
    no_commands = {
        on_chat_messages = 1,
    },
    no_hud = {
        playerevents = 1,
    },
    no_falling = {
        on_punchnodes = 2,
        on_placenodes = 1,
        on_dignodes = 1,
    },
}

-- Non-client privs
local privs = {
    "basic_privs",
    "teleport",
    "bring",
    "settime",
    "server",
    "protection_bypass",
    "ban",
    "kick",
    "give",
    "password",
    "rollback",
}

local v5_10_0 = core.has_feature("abm_without_neighbors")

for setting, registry in pairs(to_unregister) do
    if unbuiltin[setting] then
        for registered, total in pairs(registry) do
            local t = core["registered_" .. registered]
            if total > 0 then
                for _ = 1, total do
                    table.remove(t, 1)
                end
            else
                for i in pairs(t) do t[i] = nil end
            end
        end
    end
end

if unbuiltin.no_privs then
    for _, priv in pairs(privs) do
        core.registered_privileges[priv] = nil
    end
end

if unbuiltin.no_falling then
    core.registered_entities["__builtin:falling_node"] = nil
end

if unbuiltin.no_items then
    core.registered_entities["__builtin:item"] = nil
end

-- Clear the player environment and interface
core.register_on_joinplayer(function(player)
    if unbuiltin.no_hud then
        player:hud_set_flags({
            basic_debug = false,
            chat = false,
            crosshair = false,
            hotbar = false,
            wielditem = false,
            healthbar = false,
            breathbar = false,
        })

        -- Disabling the minimap without the "disabled" warning
        player:set_minimap_modes({{type = "off", label = " "}}, 0)
    end

    if unbuiltin.no_player then
        player:set_properties({
            visual = "sprite",
            textures = {"blank.png"},
            physical = false,
            eye_height = 0,
            zoom_fov = 0,
        })
    end

    if unbuiltin.no_gravity then
        player:set_physics_override({
            gravity = 0,
        })
    end

    if unbuiltin.no_movement then
        player:set_physics_override({
            jump = 0,
            speed = 0,
            sneak = false,
        })
    end

    if unbuiltin.no_forms then
        player:set_inventory_formspec("")
        player:set_formspec_prepend("")
    end

    if unbuiltin.no_hp then
        player:hud_set_flags({
            healthbar = false,
            breathbar = false,
        })

        player:set_armor_groups({
            fall_damage_add_percent = 1300,
        })

        if v5_10_0 then
            -- Keep node_damage because why not
            player:set_flags({
                breathing = false,
                drowning = false,
            })
        end
    end

    if unbuiltin.no_world then
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
    end
end)

core.set_timeofday(0.5)

if unbuiltin.no_hp then
    -- This is dirty but whatever
    core.registered_on_player_events = {}
    core.register_on_player_event = function(callback)
        table.insert(core.registered_on_player_events, callback)
    end

    table.insert(core.registered_on_player_hpchanges.modifiers, 1, function(player, _, reason)
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

    if not v5_10_0 then
        core.register_playerevent(function(player, event)
            if event == "breath_changed" then
                if player:get_breath() ~= core.PLAYER_MAX_BREATH_DEFAULT then
                    player:set_breath(core.PLAYER_MAX_BREATH_DEFAULT)
                end
            end
        end)
    end
end
