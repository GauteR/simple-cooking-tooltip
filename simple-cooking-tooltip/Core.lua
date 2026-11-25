-- Addon bootstrap: slash command and tooltip/options init.
SimpleCookingTooltip = SimpleCookingTooltip or {}

local function Print(message)
  if DEFAULT_CHAT_FRAME then
    local prefix = (SimpleCookingTooltip.L and SimpleCookingTooltip.L.CHAT_PREFIX) or "Simple Cooking Tooltip: "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
  end
end

function SimpleCookingTooltip:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

-- "Alliance", "Horde", or nil (neutral/unknown: recipes are not filtered by faction).
function SimpleCookingTooltip:GetPlayerFaction()
  if not UnitFactionGroup then
    return nil
  end
  local faction = UnitFactionGroup("player")
  if faction == "Alliance" or faction == "Horde" then
    return faction
  end
  return nil
end

-- { faction, skill } for Ingredients:BuildLines.
function SimpleCookingTooltip:GetPlayerInfo()
  return {
    faction = self:GetPlayerFaction(),
    skill = SimpleCookingTooltip.Player and SimpleCookingTooltip.Player:GetCookingSkill() or nil,
  }
end

function SimpleCookingTooltip:PrintStatus()
  if self:IsEnabled() then
    Print(self:T("CHAT_STATUS_ON"))
    -- What the tooltips will filter by; "not detected" means recipes are not hidden by skill.
    local info = self:GetPlayerInfo()
    Print(self:T("CHAT_DETECTED_FMT", info.faction or self:T("CHAT_NOT_DETECTED"), info.skill or self:T("CHAT_NOT_DETECTED")))
  else
    Print(self:T("CHAT_STATUS_OFF"))
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
  if event ~= "PLAYER_LOGIN" then
    return
  end
  if not SimpleCookingTooltip:IsEnabled() then
    Print(SimpleCookingTooltip:T("CHAT_DISABLED"))
    return
  end

  SLASH_SIMPLECOOKINGTOOLTIP1 = (SimpleCookingTooltip.Config and SimpleCookingTooltip.Config.SLASH_COMMAND) or "/sct"
  SlashCmdList["SIMPLECOOKINGTOOLTIP"] = function()
    SimpleCookingTooltip:PrintStatus()
  end

  if SimpleCookingTooltip.Tooltip and SimpleCookingTooltip.Tooltip.Initialize then
    SimpleCookingTooltip.Tooltip:Initialize()
  end

  if SimpleCookingTooltip.Options and SimpleCookingTooltip.Options.Initialize then
    SimpleCookingTooltip.Options:Initialize()
  end
end)
