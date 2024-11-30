--[[
    Author: Igromanru
    Date: 30.11.2024
    Mod Name: Transparent Shield
    Version: 1.0.1
]]
local mod = get_mod("TransparentShield")
local SettingNames = mod:io_dofile("TransparentShield/scripts/setting_names")

local last_weapon_unit = nil

local function get_fade_system()
    if not Managers.state or not Managers.state.extension then return nil end
    return Managers.state.extension:system("fade_system")
end

local function get_fade_value()
    local opacity = mod:get(SettingNames.Opacity)
    if type(opacity) == "number" and opacity >= 0.0 and opacity <= 1.0 then
        return 1.0 - opacity
    end
    return 0.0
end

local function remove_weapon_fade(weapon_unit, fade_system)
    if not weapon_unit or not Unit.alive(weapon_unit) then return end
    fade_system = fade_system or get_fade_system()

    if fade_system and fade_system._unit_to_extension_map[weapon_unit] then
        pcall(fade_system.on_remove_extension, fade_system, weapon_unit)
    end
end

local function set_weapon_fade(weapon_unit)
    weapon_unit = weapon_unit or last_weapon_unit
    if not weapon_unit or not Unit.alive(weapon_unit) then return end

    local fade_system = get_fade_system()
    if fade_system then
        if fade_system._unit_to_extension_map[weapon_unit] then
            pcall(fade_system.set_min_fade, fade_system, weapon_unit, get_fade_value())
        else
            local world = Managers.world:world("level_world")
            if world then
                if pcall(fade_system.on_add_extension, fade_system, world, weapon_unit) then
                    pcall(fade_system.set_min_fade, fade_system, weapon_unit, get_fade_value())
                end
            end
        end
    end
end

local function get_local_player()
    if not Managers.player then return nil end
	return Managers.player:local_player(1)
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, t, skip_wield_action)
    if not mod:get(SettingNames.EnableMod) or not self._weapons or slot_name ~= "slot_primary" or self._player ~= get_local_player() then return end

    local weapon = self._weapons[slot_name]
    if weapon and weapon.weapon_template then
        local weapon_name = weapon.weapon_template.name
        if weapon_name and string.find(string.lower(weapon_name), "slabshield") then
            last_weapon_unit = weapon.weapon_unit
            set_weapon_fade(weapon.weapon_unit)
        end
    end
end)

mod.on_setting_changed = function (setting_id)
    if mod:get(SettingNames.EnableMod) then
        set_weapon_fade(last_weapon_unit)
    elseif setting_id == SettingNames.EnableMod then
        remove_weapon_fade(last_weapon_unit)
    end
end