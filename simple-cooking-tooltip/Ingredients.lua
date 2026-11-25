-- Ingredient -> recipe lookup, faction/skill filtering and tooltip line formatting (pure Lua, no client API).
-- `player` (optional) = { faction = "Alliance"|"Horde"|nil, skill = Cooking rank|nil }
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_SOURCES = 3

-- Tie-break when two recipes need the same skill: easier to get first.
local LEARN_RANK = { trainer = 1, item = 2 }

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

-- Builds { [itemId] = { recipeId, ... } } from Data.RECIPES once (rebuilt when the data table changes).
function Ingredients:GetIndex()
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not recipes then
    return {}
  end
  if self._indexSource ~= recipes then
    local index = {}
    for recipeId, recipe in pairs(recipes) do
      for _, itemId in ipairs(recipe.reagents or {}) do
        local list = index[itemId]
        if not list then
          list = {}
          index[itemId] = list
        end
        list[#list + 1] = recipeId
      end
    end
    self._index = index
    self._indexSource = recipes
  end
  return self._index
end

function Ingredients:IsTracked(itemId)
  return type(itemId) == "number" and self:GetIndex()[itemId] ~= nil
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

-- No faction given (neutral/unknown): do not filter. Recipes without a faction are for everyone.
local function Obtainable(recipe, faction)
  return recipe.faction == nil or faction == nil or recipe.faction == faction
end

-- Lowest skill first; at equal skill the easier-to-get recipe, then name.
local function Nearer(a, b)
  if a.skill ~= b.skill then
    return a.skill < b.skill
  end
  local ra, rb = LEARN_RANK[a.learn] or 99, LEARN_RANK[b.learn] or 99
  if ra ~= rb then
    return ra < rb
  end
  return a.name < b.name
end

-- The recipe using `itemId` that is nearest upwards from the player's Cooking skill (required skill
-- >= current skill) among those the player's faction can learn. Returns the recipe table, or nil
-- when nothing is left ("no future recipes"). Without a known skill the lowest-skill recipe is used.
function Ingredients:GetNearestRecipe(itemId, player)
  local ids = type(itemId) == "number" and self:GetIndex()[itemId] or nil
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not ids or not recipes then
    return nil
  end
  player = player or {}
  local best = nil
  for i = 1, #ids do
    local recipe = recipes[ids[i]]
    if recipe and Obtainable(recipe, player.faction) and (player.skill == nil or recipe.skill >= player.skill) then
      if not best or Nearer(recipe, best) then
        best = recipe
      end
    end
  end
  return best
end

-- Where to get an ingredient: up to `max` (1-3) { name, zone } pairs, skipping zones only the other
-- faction visits. Second return is true when vendors sell it.
function Ingredients:GetSources(itemId, player, max)
  local data = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.SOURCES
  local entry = type(itemId) == "number" and data and data[itemId] or nil
  if not entry then
    return {}, false
  end
  local faction = player and player.faction or nil
  local limit = ClampSources(max)
  local sources = {}
  for i = 1, #entry.sources do
    local source = entry.sources[i]
    local sourceFaction = source[3]
    if sourceFaction == nil or faction == nil or sourceFaction == faction then
      sources[#sources + 1] = source
      if #sources == limit then
        break
      end
    end
  end
  return sources, entry.vendor == true
end

-- Returns tooltip lines (empty when there is nothing to show):
--   "Found: Prowler (Elwynn Forest), sold by vendors"
--   "Keep for: Spiced Wolf Meat (50)"   (nearest recipe upwards; no line when none is left)
function Ingredients:BuildLines(itemId, config, player)
  local lines = {}
  config = config or {}
  player = player or {}
  local T = function(...)
    return SimpleCookingTooltip:T(...)
  end

  if config.SHOW_SOURCES ~= false then
    local sources, vendor = self:GetSources(itemId, player, config.MAX_SOURCES)
    local parts = {}
    for i = 1, #sources do
      parts[#parts + 1] = T("SOURCE_ENTRY_FMT", sources[i][1], sources[i][2])
    end
    if vendor then
      parts[#parts + 1] = T("VENDOR_ENTRY")
    end
    if #parts > 0 then
      lines[#lines + 1] = T("FOUND_LINE_FMT", table.concat(parts, ", "))
    end
  end
  if config.SHOW_KEEP_FOR ~= false then
    local recipe = self:GetNearestRecipe(itemId, player)
    if recipe then
      lines[#lines + 1] = T("KEEP_FOR_LINE_FMT", recipe.name, math.max(recipe.skill, 1))
    end
  end
  return lines
end
