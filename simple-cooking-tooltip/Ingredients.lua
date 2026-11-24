-- Ingredient lookup and tooltip line formatting (pure Lua, no client API).
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_SOURCES = 3

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

local function ClampSources(value)
  value = tonumber(value) or DEFAULT_MAX_SOURCES
  if value < 1 then
    return 1
  elseif value > 3 then
    return 3
  end
  return math.floor(value)
end

-- Returns the first `maxSources` (1-3) { name, area } pairs for an entry.
function Ingredients:GetSources(entry, maxSources)
  local sources = {}
  if not entry or not entry.sources then
    return sources
  end
  local limit = ClampSources(maxSources)
  for i = 1, math.min(limit, #entry.sources) do
    sources[#sources + 1] = entry.sources[i]
  end
  return sources
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
  if config.SHOW_SOURCES ~= false then
    local sources = self:GetSources(entry, config.MAX_SOURCES)
    for i = 1, #sources do
      local name, area = sources[i][1], sources[i][2]
      if area then
        lines[#lines + 1] = T("SOURCE_LINE_FMT", name, area)
      else
        lines[#lines + 1] = T("SOURCE_NAME_FMT", name)
      end
    end
    if #sources == 0 and entry.vendor then
      lines[#lines + 1] = T("VENDOR_LINE")
    end
  end
  return lines
end
