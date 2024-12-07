--[[
    Author: Igromanru
    Date: 30.11.2024
    Mod Name: Transparent Shield
    Version: 1.3.0
]]
local mod = get_mod("TransparentShield")
local SettingNames = mod:io_dofile("TransparentShield/scripts/setting_names") ---@type SettingNames
local ModUtils = mod:io_dofile("TransparentShield/scripts/mod_utils") ---@type ModUtils

local cooldown = 0.0 ---@type number
local last_weapon_unit = nil ---@type Unit?

-- ---@class WeaponInfo
-- ---@field unit Unit
-- ---@field alpha number
-- ---@field alpha_blocking number
-- local WeaponInfo = {}

-- ---@type { [string]: WeaponInfo }
-- local weapons_cache = {}

---@param weapon_unit Unit?
---@param fade_strength number?
local function set_weapon_fade(weapon_unit, fade_strength)
    weapon_unit = weapon_unit or last_weapon_unit
    if not weapon_unit or not Unit.alive(weapon_unit) then return end

    local fade_system = ModUtils.get_fade_system()
    if fade_system then
        fade_strength = fade_strength or get_fade_strength()
        if fade_system._unit_to_extension_map[weapon_unit] then
            fade_system:set_min_fade(weapon_unit, fade_strength)
        else
            local world = Managers.world:world("level_world")
            if world then
                if pcall(fade_system.on_add_extension, fade_system, world, weapon_unit) then
                    pcall(fade_system.set_min_fade, fade_system, weapon_unit, fade_strength)
                end
            end
        end
    end
end

---@param weapon_unit Unit?
---@param fade_system FadeSystem?
local function remove_weapon_fade(weapon_unit, fade_system)
    if not weapon_unit or not Unit.alive(weapon_unit) then return end
    fade_system = fade_system or ModUtils.get_fade_system()

    if fade_system and fade_system._unit_to_extension_map[weapon_unit] then
        fade_system:on_remove_extension(weapon_unit)
    end
end

local function reset()
    remove_weapon_fade(last_weapon_unit)
    last_weapon_unit = nil
end

---@param setting_id string
function mod.on_setting_changed(setting_id)
    if (setting_id == SettingNames.EnableMod or setting_id == SettingNames.EnableForAllWeapons) and not mod:get(setting_id) then
        reset()
    end
end

---@param dt number # delta time
function mod.update(dt)
    if cooldown > 0 then
        cooldown = cooldown - dt
    else
        cooldown = 0.25
        if ModUtils.is_mod_enabled() and last_weapon_unit then
            if not Unit.alive(last_weapon_unit) then
                last_weapon_unit = nil
            end
            local local_player_unit = ModUtils.get_local_player_unit()
            if local_player_unit and last_weapon_unit then
                local unit_data_system_ext = ScriptUnit.has_extension(local_player_unit, "unit_data_system")
                if unit_data_system_ext then
                    local block_component = unit_data_system_ext:read_component("block")
                    local fade_value = ModUtils.get_fade_strength(block_component and block_component.is_blocking)
                    set_weapon_fade(last_weapon_unit, fade_value)
                end
            end
        end
    end
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, t, skip_wield_action)
    if not ModUtils.is_mod_enabled() or not self._weapons or self._player ~= ModUtils.get_local_player() then return end

    local weapon = self._weapons[slot_name]
    if weapon and weapon.weapon_template then
        if ModUtils.is_for_all_weapons() then
            if slot_name == "slot_primary" or slot_name == "slot_secondary" then 
                last_weapon_unit = weapon.weapon_unit
            end
        elseif slot_name == "slot_primary" then 
            local weapon_name = weapon.weapon_template.name
            if weapon_name and string.find(string.lower(weapon_name), "slabshield") then
                last_weapon_unit = weapon.weapon_unit
            end
        end
    end
end)