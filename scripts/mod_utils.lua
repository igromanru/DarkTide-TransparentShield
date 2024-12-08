local mod = get_mod("TransparentShield")
local SettingNames = mod:io_dofile("TransparentShield/scripts/setting_names") ---@type SettingNames

---@class ModUtils
local ModUtils = {}

---@return boolean
function ModUtils.is_mod_enabled()
    return mod:get(SettingNames.EnableMod)
end

---@return boolean
function ModUtils.is_for_all_items()
    return mod:get(SettingNames.EnableForAllItems)
end

---@return boolean
function ModUtils.is_for_all_players()
    return mod:get(SettingNames.EnableForOtherPlayers)
end

---@param other_players boolean? # Default: `false`
---@return number
function ModUtils.is_opacity(other_players)
    other_players = other_players or false
    if other_players then
        return mod:get(SettingNames.OpacityForOthers)
    end
    return mod:get(SettingNames.Opacity)
end

---@param other_players boolean? # Default: `false`
---@return number
function ModUtils.is_block_opacity(other_players)
    other_players = other_players or false
    if other_players then
        return mod:get(SettingNames.BlockOpacityForOthers)
    end
    return mod:get(SettingNames.BlockOpacity)
end

---@param is_blocking boolean? # Default: `false`
---@param other_players boolean? # Default: `false`
---@return number
function ModUtils.get_opacity_setting(is_blocking, other_players)
    other_players = other_players or false
    if is_blocking then
        return ModUtils.is_block_opacity(other_players)
    end
    return ModUtils.is_opacity(other_players)
end

---@param opacity number? # Default value `get_opacity_setting()`. 1.0 = max visibility, 0.0 = invisible
---@return number fade_strength # 0.0 max visibility, 1.0 = invisible
function ModUtils.opacity_to_fade_strength(opacity)
    opacity = opacity or ModUtils.get_opacity_setting()
    if type(opacity) == "number" and opacity >= 0.0 and opacity <= 1.0 then
        return 1.0 - opacity
    end
    return 0.0
end

---@param is_blocking boolean? # Default: false
---@return number fade_strength # 0.0 max visibility, 1.0 = invisible
function ModUtils.get_fade_strength(is_blocking)
    return ModUtils.opacity_to_fade_strength(ModUtils.get_opacity_setting(is_blocking))
end

---@return FadeSystem?
function ModUtils.get_fade_system()
    if not Managers.state or not Managers.state.extension then return nil end
    return Managers.state.extension:system("fade_system")
end

---@return HumanPlayer?
function ModUtils.get_local_player()
    if not Managers.player then return nil end
    return Managers.player:local_player_safe(1)
end

---@return Unit?
function ModUtils.get_local_player_unit()
    local local_player = ModUtils.get_local_player()
    return local_player and local_player.player_unit
end

---@param player_unit Unit? # Default: local player unit
---@return table? read_block_component
function ModUtils.get_block_component(player_unit)
    player_unit = player_unit or ModUtils.get_local_player_unit()
    if player_unit then
        local unit_data_system_ext = ScriptUnit.has_extension(player_unit, "unit_data_system")
        if unit_data_system_ext then
            return unit_data_system_ext:read_component("block")
        end
    end
    return nil
end

---@param player_unit Unit? # Default: local player unit
---@return boolean is_blocking
function ModUtils.is_player_blocking(player_unit)
    local block_component = ModUtils.get_block_component(player_unit)
    return block_component ~= nil and block_component.is_blocking == true
end

return ModUtils