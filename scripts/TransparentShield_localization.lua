--[[
    Author: Igromanru
    Date: 30.11.2024
    Mod Name: Transparent Shield
]]
local mod = get_mod("TransparentShield")

local SettingNames = mod:io_dofile("TransparentShield/scripts/setting_names") ---@type SettingNames

return {
  mod_name =
  {
    en = "Transparent Shield",
  },
  mod_description =
  {
    en = "Makes Ogryn shield transparent",
  },
  [SettingNames.EnableMod] = {
    en = "Enable Transparency"
  },
  [SettingNames.Opacity] = {
    en = "Opacity"
  },
  [SettingNames.BlockOpacity] = {
    en = "Opacity while blocking"
  },
  [SettingNames.EnableForAllItems] = {
    en = "Enable for all items"
  },
  [SettingNames.OtherPlayersGroup] = {
    en = "Settings for other players"
  },
  [SettingNames.EnableForOtherPlayers] = {
    en = "Enable for other players"
  },
  [SettingNames.OpacityForOthers] = {
    en = "Opacity for other players"
  },
  [SettingNames.BlockOpacityForOthers] = {
    en = "Opacity while blocking for other players"
  },
}
