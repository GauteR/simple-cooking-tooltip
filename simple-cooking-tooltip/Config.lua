-- Feature flags and shared addon settings for WoW Forever.
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Ingredient hover: up to three main mob types (or fishing) and their areas.
  SHOW_SOURCES = true,
  -- Ingredient hover: Cooking skill required to use it for any recipe.
  SHOW_SKILL = true,
  -- Maximum number of sources listed (1-3).
  MAX_SOURCES = 3,
  ADDON_NAME = "Simple Cooking Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/sct",
}
