-- Feature flags and shared addon settings for WoW Forever.
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Ingredient hover: recipes that use it (only ones your faction can learn).
  SHOW_RECIPES = true,
  -- Ingredient hover: where to get it (mobs to farm and zone, or vendors), for your faction.
  SHOW_SOURCES = true,
  -- Maximum number of recipes listed (1-5).
  MAX_RECIPES = 5,
  -- Maximum number of sources listed (1-3).
  MAX_SOURCES = 3,
  ADDON_NAME = "Simple Cooking Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/sct",
}
