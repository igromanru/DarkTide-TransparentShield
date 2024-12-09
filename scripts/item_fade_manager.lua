
local mod = get_mod("TransparentShield")
local ModUtils = mod:io_dofile("TransparentShield/scripts/mod_utils") ---@type ModUtils

---@class FadeInfo
---@field player_unit Unit
---@field is_not_local_player boolean
---@field fade_strength number
---@field fade_strength_while_blocking number
local FadeInfo = {}

---@type { [Unit]: FadeInfo }
local units_cache = {}

---@class ItemFadeManager
local ItemFadeManager = {}

---@param unit Unit
---@param fade_info FadeInfo
---@param fade_system FadeSystem
local function update_fade(unit, fade_info, fade_system)
    if not unit or not fade_info then return end

    fade_system = fade_system or ModUtils.get_fade_system()
    if not fade_system then return end

    local is_blocking = ModUtils.is_player_blocking(fade_info.player_unit)
    local fade_strength = ModUtils.get_fade_strength(is_blocking, fade_info.is_not_local_player)

    local should_update = false
    if is_blocking then
        should_update = fade_strength ~= fade_info.fade_strength_while_blocking
        fade_info.fade_strength_while_blocking = fade_strength
    else
        should_update = fade_strength ~= fade_info.fade_strength
        fade_info.fade_strength = fade_strength
    end
    if should_update then
        units_cache[unit] = fade_info
        fade_system:set_min_fade(unit, fade_strength)
    end
end

---@param unit Unit # Unit that will be added if it doesn't exist yet
---@param player HumanPlayer
---@return boolean was_added
function ItemFadeManager.try_add_or_update(unit, player)
    if not unit or not player or not player.player_unit then return false end

    local is_not_local_player = player ~= ModUtils.get_local_player()
    if not ModUtils.is_for_all_players() and is_not_local_player then return false end

    local fade_system = ModUtils.get_fade_system()
    if not fade_system then return false end

    local unit_fade_extension = fade_system._unit_to_extension_map[unit]
    if not unit_fade_extension then
        local world = Managers.world:world("level_world")
        if world then
            unit_fade_extension = fade_system:on_add_extension(world, unit)
        end
    end
    if not unit_fade_extension then 
        units_cache[unit] = nil
        return false
    end

    units_cache[unit] = {
        player_unit = player.player_unit,
        is_not_local_player = is_not_local_player,
        fade_strength = ModUtils.get_fade_strength(false, is_not_local_player),
        fade_strength_while_blocking =  ModUtils.get_fade_strength(true, is_not_local_player),
    }

    return true
end

---@param unit Unit # Unit to remove
function ItemFadeManager.remove(unit)
    if not units_cache[unit] then return end

    local fade_system = ModUtils.get_fade_system()
    if fade_system and fade_system._unit_to_extension_map[unit] then
        fade_system:on_remove_extension(unit)
        units_cache[unit] = nil
    end
end

function ItemFadeManager.remove_all()
    local fade_system = ModUtils.get_fade_system()
    if fade_system then
        for unit, _ in pairs(units_cache) do
            if fade_system._unit_to_extension_map[unit] then
                fade_system:on_remove_extension(unit)
            end
            units_cache[unit] = nil
        end
    end
end


function ItemFadeManager.update_fade_all()
    local fade_system = ModUtils.get_fade_system()
    if fade_system then
        for unit, fade_info in pairs(units_cache) do
            update_fade(unit, fade_info, fade_system)
        end
    end
end

return ItemFadeManager