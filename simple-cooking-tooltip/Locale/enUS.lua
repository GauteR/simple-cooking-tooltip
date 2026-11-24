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
L.SKILL_LINE_FMT = "Cooking skill needed for recipes: %d"
L.SOURCE_LINE_FMT = "Found: %s (%s)"
L.SOURCE_NAME_FMT = "Found: %s"
L.VENDOR_LINE = "Sold by vendors"

L.OPTIONS_HELP =
  "Hover a cooking ingredient to see where to farm it (up to three main mob types and their areas) and the Cooking skill required to use it for any recipe, in case you want to save it for later. Vendor-sold ingredients are marked as such."


-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
