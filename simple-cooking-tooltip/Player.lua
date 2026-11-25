-- Reads the player's Cooking skill from whichever profession API the client offers.
-- Pure Lua apart from the optional `api` table (defaults to the global environment), so it can be tested.
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Player = SimpleCookingTooltip.Player or {}

local Player = SimpleCookingTooltip.Player

local COOKING = "Cooking" -- English client only (see AGENTS.md)

-- Modern profession API: GetProfessions() returns up to five indexes, GetProfessionInfo(i) returns
-- name, icon, skillLevel, maxSkillLevel, ...
local function FromProfessions(api)
  if not (api.GetProfessions and api.GetProfessionInfo) then
    return nil
  end
  local indexes = { api.GetProfessions() }
  for i = 1, 5 do
    local index = indexes[i]
    if index then
      local name, _, rank = api.GetProfessionInfo(index)
      if name == COOKING and type(rank) == "number" then
        return rank
      end
    end
  end
  return nil
end

-- Only answers while the Cooking window is open.
local function FromTradeSkillWindow(api)
  local ui = api.C_TradeSkillUI
  if not (ui and ui.GetBaseProfessionInfo) then
    return nil
  end
  local info = ui.GetBaseProfessionInfo()
  if info and info.professionName == COOKING and type(info.skillLevel) == "number" then
    return info.skillLevel
  end
  return nil
end

-- Classic skill list; headers can be collapsed, so this is the last resort.
local function FromSkillLines(api)
  if not (api.GetNumSkillLines and api.GetSkillLineInfo) then
    return nil
  end
  for i = 1, api.GetNumSkillLines() do
    local name, isHeader, _, rank = api.GetSkillLineInfo(i)
    if not isHeader and name == COOKING and type(rank) == "number" then
      return rank
    end
  end
  return nil
end

-- Current Cooking skill rank, or nil when it cannot be read (no Cooking, or no usable API).
function Player:GetCookingSkill(api)
  api = api or _G
  return FromProfessions(api) or FromTradeSkillWindow(api) or FromSkillLines(api)
end
