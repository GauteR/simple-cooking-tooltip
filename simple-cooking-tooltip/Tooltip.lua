-- Append ingredient area / skill lines to item tooltips.
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Tooltip = SimpleCookingTooltip.Tooltip or {}

local Tooltip = SimpleCookingTooltip.Tooltip

-- Classic / comparison tooltips beyond GameTooltip + ItemRef.
local CLASSIC_TOOLTIP_NAMES = {
  "GameTooltip",
  "ItemRefTooltip",
  "ShoppingTooltip1",
  "ShoppingTooltip2",
  "EmbeddedItemTooltip",
}

local APPENDED_FLAG = "_SimpleCookingTooltipAppended"

-- Resolve item id from a tooltip frame (Retail-style data or classic GetItem).
local function ResolveItemId(tooltip, data)
  if data and data.id then
    return data.id
  end
  if tooltip and tooltip.GetItem then
    local _, link = tooltip:GetItem()
    if link and SimpleCookingTooltip.Ingredients then
      return SimpleCookingTooltip.Ingredients:ParseItemId(link)
    end
  end
  return nil
end

function Tooltip:ClearAppendState(tooltip)
  if tooltip then
    tooltip[APPENDED_FLAG] = nil
  end
end

function Tooltip:AppendForItem(tooltip, itemId)
  if not SimpleCookingTooltip:IsEnabled() then
    return
  end
  if not itemId or not tooltip or not tooltip.AddLine then
    return
  end
  -- Skip re-entry for the same item this show (other tooltip addons refreshing).
  if tooltip[APPENDED_FLAG] == itemId then
    return
  end
  local Ingredients = SimpleCookingTooltip.Ingredients
  if not Ingredients then
    return
  end
  local faction = SimpleCookingTooltip.GetPlayerFaction and SimpleCookingTooltip:GetPlayerFaction() or nil
  local lines = Ingredients:BuildLines(itemId, SimpleCookingTooltip.Config, faction)
  if #lines == 0 then
    return
  end

  tooltip:AddLine(" ")
  for i = 1, #lines do
    -- Gold text; wrap long recipe names.
    tooltip:AddLine(lines[i], 1, 0.82, 0.2, true)
  end
  tooltip[APPENDED_FLAG] = itemId
end

local function OnItemTooltip(tooltip, data)
  local itemId = ResolveItemId(tooltip, data)
  if itemId then
    Tooltip:AppendForItem(tooltip, itemId)
  end
end

local function HookClassicTooltip(frame)
  if not frame or frame._SimpleCookingTooltipHooked then
    return
  end
  local ok = pcall(function()
    frame:HookScript("OnTooltipSetItem", function(self)
      OnItemTooltip(self, nil)
    end)
  end)
  if ok then
    frame._SimpleCookingTooltipHooked = true
  end
end

-- Allow a fresh append after the tooltip is cleared or hidden.
local function HookTooltipLifecycle(frame)
  if not frame or frame._SimpleCookingTooltipClearHooked then
    return
  end
  local function clear()
    Tooltip:ClearAppendState(frame)
  end
  local clearedOk = pcall(function()
    frame:HookScript("OnTooltipCleared", clear)
  end)
  local hideOk = pcall(function()
    frame:HookScript("OnHide", clear)
  end)
  if clearedOk or hideOk then
    frame._SimpleCookingTooltipClearHooked = true
  end
end

function Tooltip:Initialize()
  if self.initialized then
    return
  end

  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
  else
    for i = 1, #CLASSIC_TOOLTIP_NAMES do
      local frame = _G[CLASSIC_TOOLTIP_NAMES[i]]
      if frame then
        HookClassicTooltip(frame)
      end
    end
  end

  for i = 1, #CLASSIC_TOOLTIP_NAMES do
    local frame = _G[CLASSIC_TOOLTIP_NAMES[i]]
    if frame then
      HookTooltipLifecycle(frame)
    end
  end

  self.initialized = true
end
