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

---@param is_blocking boolean? # Default: `false`
---@return number
function ModUtils.get_opacity_setting(is_blocking)
    if is_blocking then
        return mod:get(SettingNames.BlockOpacity)
    end
    return mod:get(SettingNames.Opacity)
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

return ModUtils