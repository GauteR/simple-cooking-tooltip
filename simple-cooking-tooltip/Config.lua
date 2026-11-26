-- Feature flags and shared addon settings for WoW Forever.
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Ingredient hover: "Keep for:" the nearest recipe upwards from your Cooking skill (your faction only).
  SHOW_KEEP_FOR = true,
  -- Ingredient hover: where to get it (mobs to farm and zone, or vendors), for your faction.
  SHOW_SOURCES = true,
  -- Maximum number of sources listed (1-3).
  MAX_SOURCES = 3,
  -- Colour of the labels ("Dropped by:", "Keep for:", ...) as a hex string; the values stay white.
  LABEL_COLOR = "ffd100",
  -- Colour zone names by level against your character: red above, yellow on level, green a little
  -- below, gray far below.
  COLOR_ZONES = true,
  -- A zone within this many levels of yours (above or below) is yellow; more above is red.
  ZONE_YELLOW_RANGE = 2,
  -- Zones this many levels or more below you are gray (between yellow and gray is green).
  ZONE_GRAY_BELOW = 8,
  ADDON_NAME = "Simple Cooking Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/sct",
}
