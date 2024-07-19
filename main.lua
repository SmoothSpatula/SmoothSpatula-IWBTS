-- SurvivorSetup
-- SmoothSpatula
log.info("Successfully loaded ".._ENV["!guid"]..".")
survivor_setup = require("./survivor_setup")
require("./utils")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local survivors = ... or {}

local is_init = false

-- Section Setup/Stats == --

function setup_survivor(namespace, identifier, name, description, end_quote,
                        loadout_sprite, portrait_sprite, portraitsmall_sprite, palette_sprite, 
                        walk_sprite, idle_sprite, death_sprite, jump_sprite, jump_peak_sprite, jumpfall_sprite, climb_sprite,
                        colour, cape_array)
    
    survivor_id = gm.survivor_create(namespace, identifier)
    survivor = survivor_setup.Survivor(survivor_id)

    -- Configure Properties
    survivor.token_name = name
    survivor.token_name_upper = string.upper(name)
    survivor.token_description = description
    survivor.token_end_quote = end_quote

    survivor.sprite_loadout = loadout_sprite
    survivor.sprite_title = walk_sprite
    survivor.sprite_idle = idle_sprite
    survivor.sprite_portrait = portrait_sprite
    survivor.sprite_portrait_small = portraitsmall_sprite
    survivor.sprite_palette = palette_sprite
    survivor.sprite_portrait_palette = palette_sprite
    survivor.sprite_loadout_palette = palette_sprite
    survivor.sprite_credits = walk_sprite

    survivor.primary_color = gm.make_colour_rgb(colour.r, colour.g, colour.b) -- for stats screen

    local vanilla_survivor = survivor_setup.Survivor(0)
    survivor.on_init = vanilla_survivor.on_init
    survivor.on_step = vanilla_survivor.on_step
    survivor.on_remove = vanilla_survivor.on_remove

    survivor.cape_offset = gm.array_create(4, nil)

    local cape_offset = gm.variable_global_get("class_survivor")[survivor_id+1][34]
    gm.array_set(cape_offset, 0, cape_array[1])
    gm.array_set(cape_offset, 1, cape_array[2])
    gm.array_set(cape_offset, 2, cape_array[3])
    gm.array_set(cape_offset, 3, -1.0)

    survivors[survivor_id] = {
        ["identifier"] = identifier, 
        ["idle_sprite"] = idle_sprite, 
        ["walk_sprite"] = walk_sprite, 
        ["death_sprite"] = death_sprite,
        ["jump_sprite"] = jump_sprite,
        ["jumpfall_sprite"] = jumpfall_sprite,
        ["jumppeak_sprite"] = jump_peak_sprite,
        ["climb_sprite"] = climb_sprite
    }

    return survivor, survivor_id
end

function setup_stats(survivor_id, armor, attack_speed, movement_speed, critical_chance, damage, hp_regen, maxhp, maxbarrier, maxshield, maxhp_cap, jump_force)
    survivors[survivor_id]["armor"] = armor
    survivors[survivor_id]["attack_speed"] = attack_speed
    survivors[survivor_id]["movement_speed"] = movement_speed
    survivors[survivor_id]["critical_chance"] = critical_chance
    survivors[survivor_id]["damage"] = damage
    survivors[survivor_id]["hp_regen"] =  hp_regen
    survivors[survivor_id]["maxhp"] =  maxhp
    survivors[survivor_id]["maxbarrier"] = maxbarrier
    survivors[survivor_id]["maxshield"] = maxshield
    survivors[survivor_id]["maxhp_cap"] = maxhp_cap
    survivors[survivor_id]["pVmax"] = jump_force
end

function setup_level_stats(survivor_id, armor_level, attack_speed_level, critical_chance_level, damage_level, hp_regen_level, maxhp_level)
    survivors[survivor_id]["armor_level"] = armor_level
    survivors[survivor_id]["attack_speed_level"] = attack_speed_level
    survivors[survivor_id]["critical_chance_level"] = critical_chance_level
    survivors[survivor_id]["damage_level"] = damage_level
    survivors[survivor_id]["hp_regen_level"] =  hp_regen_level
    survivors[survivor_id]["maxhp_level"] = maxhp_level
end

-- == Section Skill == --

function setup_skill(skill_ref, name, description, 
                    sprite, sprite_subimage,animation, 
                    cooldown, damage, is_primary, skill_id)
    skill_ref.token_name = name
    skill_ref.token_description = description
    skill_ref.sprite = sprite
    skill_ref.subimage = sprite_subimage
    skill_ref.animation = animation
    skill_ref.cooldown = cooldown
    skill_ref.damage = damage
    skill_ref.is_primary = is_primary
    skill_ref.required_stock = is_primary and 0 or 1 -- primary skill dont need stock
    skill_ref.use_delay = 0
    skill_ref.require_key_press = not is_primary
    skill_ref.does_change_activity_state = true

    local skills = gm.variable_global_get("class_skill")

    -- skill_ref.on_can_activate = skills[skill_id][25]
    -- skill_ref.on_activate = skills[skill_id][26]

    skill_ref.on_can_activate = skills[skill_id][25]
    skill_ref.on_activate = skills[skill_id][26]

    return skill_ref
end

function setup_empty_skill(skill_ref)
    skill_ref.token_name = "Locked"
    skill_ref.token_description = ""
    skill_ref.sprite = gm.constants.sRobomandoSkills
    skill_ref.subimage = 3
    skill_ref.animation = nil
    skill_ref.cooldown = 0
    skill_ref.damage = 0
    skill_ref.is_primary = false
    skill_ref.required_stock = 10000
    skill_ref.max_stock = 0
    skill_ref.use_delay = 0
    skill_ref.require_key_press = 0
    skill_ref.does_change_activity_state = false

    local skills = gm.variable_global_get("class_skill")

    skill_ref.on_can_activate = skills[1][25]
    skill_ref.on_activate = skills[1][26]



    return skill_ref
end

-- == Section Initialize == --

function add_callback(survivor_id, callback, init_func)
    survivors[survivor_id][callback] = init_func
end

function survivor_init(self)
    local survs = gm.variable_global_get("class_survivor")

    if not survs or not survivors[self.class] then return end
    print("achieved survivor_init")
    self.sprite_idle        = survivors[self.class].idle_sprite
    self.sprite_walk        = survivors[self.class].walk_sprite
    self.sprite_jump        = survivors[self.class].jump_sprite
    self.sprite_jump_peak   = survivors[self.class].jumppeak_sprite or survivors[self.class].jump_sprite
    self.sprite_fall        = survivors[self.class].jumpfall_sprite or survivors[self.class].jump_sprite
    self.sprite_climb       = survivors[self.class].climb_sprite or survivors[self.class].idle_sprite
    self.sprite_death       = survivors[self.class].death_sprite
    self.sprite_decoy       = survivors[self.class].death_sprite


    if survivors[self.class].movement_speed ~= nil then self.pHmax = survivors[self.class].movement_speed end
    if survivors[self.class].movement_speed ~= nil then self.pHmax_base = survivors[self.class].movement_speed end
    if survivors[self.class].movement_speed ~= nil then self.pHmax_raw = survivors[self.class].movement_speed end

    local stats = {"armor", "attack_speed", "critical_chance", "damage", "hp_regen", "maxhp", "maxbarrier", "maxshield", "maxhp_cap"}
    local level_stats = {"survivor_id", "armor_level", "attack_speed_level", "critical_chance_level", "damage_level", "hp_regen_level", "maxhp_level", "pVmax"}
    for _,stat in ipairs(stats) do
        if survivors[self.class][stat] ~= nil then 
            self[stat.."_base"] = survivors[self.class][stat]
            self[stat] = survivors[self.class][stat]
        end
    end

    for _,stat in ipairs(level_stats) do
        if survivors[self.class][stat] ~= nil then 
            self[stat] = survivors[self.class][stat]
        end
    end
end

-- == Section Include == --

local function include_survivor(identifier)
    require("./" .. identifier, survivors[survivor_id], identifier)
end

-- ========== Callbacks ==========

-- Init callbacks
local callback_names = gm.variable_global_get("callback_names")
callbacks = {}

for i = 1, #callback_names do
    callbacks[callback_names[i]] = i - 1
end

gm.post_script_hook(gm.constants.stage_load_room, function(self, other, result, args)
    if not is_init then 
        is_init = true
        include_survivor("IWBTS")
    end
end)

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    if not survivors[self.class] then return end

    local callback = callback_names[args[1].value + 1] 

    if args[1].value == callbacks["onPlayerInit"] then
        survivor_init(self)
    end
    if survivors[self.class][callback] then
        survivors[self.class][callback] (self, other, result, args)
    end
end)


-- section possible additions : call_later

-- local myMethod = gm.method(self.id, gm.constants.function_dummy)
-- local _handle = gm.call_later(20, 1, myMethod, false)