-- Ingredient lookup and tooltip line formatting (pure Lua, no client API).
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_AREAS = 3

function Ingredients:ParseItemId(link)
  if type(link) ~= "string" then
    return nil
  end
  local id = link:match("item:(%d+)")
  if not id then
    return nil
  end
  return tonumber(id)
end

function Ingredients:GetEntry(itemId)
  if type(itemId) ~= "number" then
    return nil
  end
  local data = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.INGREDIENTS
  return data and data[itemId] or nil
end

function Ingredients:IsTracked(itemId)
  return self:GetEntry(itemId) ~= nil
end

local function ClampAreas(value)
  value = tonumber(value) or DEFAULT_MAX_AREAS
  if value < 1 then
    return 1
  elseif value > 3 then
    return 3
  end
  return math.floor(value)
end

-- Returns the first `maxAreas` (1-3) areas for an entry.
function Ingredients:GetAreas(entry, maxAreas)
  local areas = {}
  if not entry or not entry.zones then
    return areas
  end
  local limit = ClampAreas(maxAreas)
  for i = 1, math.min(limit, #entry.zones) do
    areas[#areas + 1] = entry.zones[i]
  end
  return areas
end

-- Returns an ordered list of tooltip line strings for an item id (empty when untracked).
function Ingredients:BuildLines(itemId, config)
  local lines = {}
  local entry = self:GetEntry(itemId)
  if not entry then
    return lines
  end
  config = config or {}
  local T = function(...)
    return SimpleCookingTooltip:T(...)
  end

  if config.SHOW_SKILL ~= false and entry.skill then
    lines[#lines + 1] = T("SKILL_LINE_FMT", entry.skill)
  end
  if config.SHOW_AREAS ~= false then
    local areas = self:GetAreas(entry, config.MAX_AREAS)
    if #areas > 0 then
      local text = table.concat(areas, ", ")
      if entry.vendor then
        lines[#lines + 1] = T("VENDOR_AND_AREAS_FMT", text)
      else
        lines[#lines + 1] = T("AREAS_LINE_FMT", text)
      end
    elseif entry.vendor then
      lines[#lines + 1] = T("VENDOR_LINE")
    end
  end
  return lines
end
