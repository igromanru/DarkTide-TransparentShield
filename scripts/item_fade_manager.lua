
local mod = get_mod("TransparentShield")
local ModUtils = mod:io_dofile("TransparentShield/scripts/mod_utils") ---@type ModUtils

---@class FadeInfo
---@field fade_extension FadeExtension
---@field alpha number
---@field alpha_while_blocking number
local FadeInfo = {}

---@type { [Unit]: FadeInfo }
local units_cache = {}

---@class ItemFadeManager
local ItemFadeManager = {}

---@param unit Unit # Unit that will be added if it doesn't exist yet
---@param player HumanPlayer? # Default: `nil`
---@return boolean was_added
function ItemFadeManager.try_add(unit, player)
    if not unit then return false end

    local is_local_player = not player and player == ModUtils.get_local_player()
    if not ModUtils.is_for_all_players() and not is_local_player then return false end

    local fade_system = ModUtils.get_fade_system()
    if not fade_system then return false end

    local unit_fade_extension = fade_system._unit_to_extension_map[unit]
    if not unit_fade_extension then
        local world = Managers.world:world("level_world")
        if world then
            unit_fade_extension = fade_system:on_add_extension(world, unit)
        end
    end
    if not unit_fade_extension then return false end

    -- local fade_info = units_cache[unit]
    units_cache[unit] = {
        fade_extension = unit_fade_extension,
        alpha = ModUtils.is_opacity(not is_local_player),
        alpha_while_blocking =  ModUtils.is_block_opacity(not is_local_player),
    }
    -- if fade_info then 
    -- end

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

function ItemFadeManager.set_fade(unit)
    if not unit then return false end

    return true
end

return ItemFadeManager