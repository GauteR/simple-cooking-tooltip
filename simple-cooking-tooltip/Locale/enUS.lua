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
L.OPTIONS_HELP =
  "Hover a cooking ingredient to see up to three main areas where it is found and the Cooking skill at which a recipe using it is learned."

L.SKILL_LINE_FMT = "Cooking recipe skill: %d"
L.AREAS_LINE_FMT = "Found in: %s"
L.VENDOR_LINE = "Sold by vendors"
L.VENDOR_AND_AREAS_FMT = "Found in: %s (also sold by vendors)"

-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
