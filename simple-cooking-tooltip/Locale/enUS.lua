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
L.SOURCE_LINE_FMT = "Found: %s (%s)"
L.VENDOR_LINE = "Sold by vendors"
L.RECIPE_LINE_FMT = "%s (skill %d)"

L.OPTIONS_HELP =
  "Hover a cooking ingredient to see where to get it (mobs to farm and zones for your faction, or vendors) and up to five recipes that use it, limited to recipes your faction can learn, easiest to get first."


-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
