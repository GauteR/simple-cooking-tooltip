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
L.SOURCE_ENTRY_FMT = "%s (%s)"
L.VENDOR_LINE = "Sold by vendors"
L.KEEP_FOR_LABEL = "Keep for:"
L.KEEP_FOR_ENTRY_FMT = "%s (%d)"

L.OPTIONS_HELP =
  "Hover a cooking ingredient to see where to get it (mobs to farm and zones for your faction, or vendors) and which recipe to keep it for: the nearest one that is still orange or yellow for you (green recipes rarely give skill-ups) and that your faction can learn. Nothing is shown when no recipe needs it any more."


-- Resolve a locale key; optional format args.
function SimpleCookingTooltip:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
