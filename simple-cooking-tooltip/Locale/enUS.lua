-- English (enUS) UI strings.
SimpleCookingTooltip = SimpleCookingTooltip or {}
local L = {}
SimpleCookingTooltip.L = L

L.ADDON_NAME = "Simple Cooking Tooltip"
L.CHAT_PREFIX = "|cff33ff99Simple Cooking Tooltip|r: "

L.CHAT_DISABLED = "Addon is disabled."
L.CHAT_STATUS_ON = "Tooltips enabled."
L.CHAT_STATUS_OFF = "Addon is disabled in Config."

L.OPTIONS_VERSION_FMT = "Version %s"
L.FOUND_LINE_FMT = "Found: %s"
L.SOURCE_ENTRY_FMT = "%s (%s)"
L.VENDOR_ENTRY = "sold by vendors"
L.RECIPES_LINE_FMT = "Recipes: %s"
L.RECIPE_ENTRY_FMT = "%s (%d)"

L.OPTIONS_HELP =
  "Hover a cooking ingredient to see where to get it (mobs to farm and zones for your faction, or vendors) and up to five recipes that use it, sorted by skill. Recipes below your Cooking skill are hidden; green recipes you know, red ones you do not."


-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
