-- Feature flags and shared addon settings for WoW Forever.
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Ingredient hover: recipes that use it (only ones your faction can learn).
  SHOW_RECIPES = true,
  -- Ingredient hover: lowest Cooking skill at which you can use it in a recipe.
  SHOW_SKILL = true,
  -- Maximum number of recipes listed (1-5).
  MAX_RECIPES = 5,
  ADDON_NAME = "Simple Cooking Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/sct",
}
