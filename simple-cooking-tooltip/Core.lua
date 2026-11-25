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

-- Current Cooking skill rank, or nil when the character has not learned Cooking.
function SimpleCookingTooltip:GetCookingSkill()
  if not (GetNumSkillLines and GetSkillLineInfo) then
    return nil
  end
  for i = 1, GetNumSkillLines() do
    local name, isHeader, _, rank = GetSkillLineInfo(i)
    if not isHeader and name == "Cooking" then
      return rank
    end
  end
  return nil
end

-- Recipes seen in the Cooking window this session (not persisted: Forever does not load SavedVariables
-- after a cold start). Filled by ScanCookingWindow; IsSpellKnown covers recipes in the spellbook.
local knownRecipes = {}

function SimpleCookingTooltip:ScanCookingWindow()
  if not (GetTradeSkillLine and GetNumTradeSkills and GetTradeSkillInfo and GetTradeSkillRecipeLink) then
    return
  end
  if GetTradeSkillLine() ~= "Cooking" then
    return
  end
  for i = 1, GetNumTradeSkills() do
    local _, skillType = GetTradeSkillInfo(i)
    if skillType ~= "header" then
      local link = GetTradeSkillRecipeLink(i)
      local id = link and (link:match("enchant:(%d+)") or link:match("spell:(%d+)"))
      if id then
        knownRecipes[tonumber(id)] = true
      end
    end
  end
end

function SimpleCookingTooltip.IsRecipeKnown(spellId)
  if knownRecipes[spellId] then
    return true
  end
  return IsSpellKnown ~= nil and IsSpellKnown(spellId) == true
end

-- { faction, skill, isKnown } for Ingredients:BuildLines.
function SimpleCookingTooltip:GetPlayerInfo()
  return {
    faction = self:GetPlayerFaction(),
    skill = self:GetCookingSkill(),
    isKnown = self.IsRecipeKnown,
  }
end

function SimpleCookingTooltip:PrintStatus()
  if self:IsEnabled() then
    Print(self:T("CHAT_STATUS_ON"))
  else
    Print(self:T("CHAT_STATUS_OFF"))
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
eventFrame:SetScript("OnEvent", function(_, event)
  if event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" then
    SimpleCookingTooltip:ScanCookingWindow()
    return
  end
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
