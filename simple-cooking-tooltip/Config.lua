-- Feature flags and shared addon settings for WoW Forever.
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Ingredient hover: "Found in" line with the main areas.
  SHOW_AREAS = true,
  -- Ingredient hover: lowest Cooking skill at which a recipe using it is learned.
  SHOW_SKILL = true,
  -- Maximum number of areas listed (1-3).
  MAX_AREAS = 3,
  ADDON_NAME = "Simple Cooking Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/sct",
}
