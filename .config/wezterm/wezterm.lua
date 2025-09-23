-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
-- shortcut to save typing below
local act = wezterm.action

config.color_scheme = "Catppuccin Mocha"
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.font = wezterm.font("MonaspiceAr Nerd Font Mono")
config.font_size = 15

config.keys = {
  { key = 'F1', mods = 'ALT', action = act.ActivatePaneByIndex(0) },
  { key = 'F2', mods = 'ALT', action = act.ActivatePaneByIndex(1) },
  { key = 'F3', mods = 'ALT', action = act.ActivatePaneByIndex(2) },
  { key = 'F4', mods = 'ALT', action = act.ActivatePaneByIndex(3) },
  { key = 'F5', mods = 'ALT', action = act.ActivatePaneByIndex(4) },
  { key = 'F6', mods = 'ALT', action = act.ActivatePaneByIndex(5) },
  { key = 'F7', mods = 'ALT', action = act.ActivatePaneByIndex(6) },
  { key = 'F8', mods = 'ALT', action = act.ActivatePaneByIndex(7) },
  { key = 'F9', mods = 'ALT', action = act.ActivatePaneByIndex(8) },
  { key = 'F10', mods = 'ALT', action = act.ActivatePaneByIndex(9) },

  -- Compare this with the older syntax shown in the section below
  { key = '{', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'CTRL', action = act.ActivateTabRelative(1) },
}
config.debug_key_events = true

return config