-- English (enUS) UI strings.
SimpleCookingTooltip = SimpleCookingTooltip or {}
local L = {}
SimpleCookingTooltip.L = L

L.ADDON_NAME = "Simple Cooking Tooltip"
L.CHAT_PREFIX = "|cff33ff99Simple Cooking Tooltip|r: "

L.CHAT_DISABLED = "Addon is disabled."
L.CHAT_STATUS_ON = "Tooltips enabled."
L.CHAT_STATUS_OFF = "Addon is disabled in Config."
L.CHAT_NOT_DETECTED = "not detected"
L.CHAT_DETECTED_FMT = "Faction: %s, level: %s, Cooking skill: %s."

L.OPTIONS_VERSION_FMT = "Version %s"
L.DROPPED_LABEL = "Dropped by:"
L.FISHED_LABEL = "Fished:"
L.GATHERED_LABEL = "Gathered:"
L.LOOTED_LABEL = "Looted from:"
L.OPENED_LABEL = "Contained in:"
L.SOURCE_ENTRY_FMT = "%s (%s)"
L.VENDOR_LINE = "Sold by vendors"
L.KEEP_FOR_LABEL = "Keep for:"
L.KEEP_FOR_ENTRY_FMT = "%s (%d)"

L.OPTIONS_HELP =
  "Hover an ingredient to see where to farm it, or what recipes to keep it for."

-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
