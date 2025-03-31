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
    ru = "Прозрачный щит",
  },
  mod_description =
  {
    en = "Makes Ogryn shield transparent",
    ru = "Делает щит огрина прозрачным",
  },
  [SettingNames.EnableMod] = {
    en = "Enable Transparency",
    ru = "Включить прозрачность",
  },
  [SettingNames.Opacity] = {
    en = "Opacity",
    ru = "Прозрачность",
  },
  [SettingNames.BlockOpacity] = {
    en = "Opacity while blocking",
    ru = "Прозрачность при блокировании",
  },
  [SettingNames.EnableForAllItems] = {
    en = "Enable for all items",
    ru = "Включить для всех предметов",
  },
  [SettingNames.OtherPlayersGroup] = {
    en = "Settings for other players",
    ru = "Настройки для других игроков",
  },
  [SettingNames.EnableForOtherPlayers] = {
    en = "Enable for other players",
    ru = "Включить для других игроков",
  },
  [SettingNames.OpacityForOthers] = {
    en = "Opacity for other players",
    ru = "Прозрачность для других игроков",
  },
  [SettingNames.BlockOpacityForOthers] = {
    en = "Opacity while blocking for other players",
    ru = "Прозрачность при блокировании для других игроков",
  },
}
