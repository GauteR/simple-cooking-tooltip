-- Ingredient -> recipe lookup, faction filtering and tooltip line formatting (pure Lua, no client API).
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_RECIPES = 5
local MAX_RECIPES_LIMIT = 5

-- Lower rank = easier to get. Unknown learn types sort last.
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

local function ClampMax(value)
  value = tonumber(value) or DEFAULT_MAX_RECIPES
  if value < 1 then
    return 1
  elseif value > MAX_RECIPES_LIMIT then
    return MAX_RECIPES_LIMIT
  end
  return math.floor(value)
end

local function Obtainable(recipe, faction)
  -- No faction given (neutral/unknown): do not filter. Recipes without a faction are for everyone.
  return recipe.faction == nil or faction == nil or recipe.faction == faction
end

local function Before(a, b)
  local ra, rb = LEARN_RANK[a.recipe.learn] or 99, LEARN_RANK[b.recipe.learn] or 99
  if ra ~= rb then
    return ra < rb
  end
  if a.recipe.skill ~= b.recipe.skill then
    return a.recipe.skill < b.recipe.skill
  end
  return a.recipe.name < b.recipe.name
end

-- Recipes using `itemId` that `faction` ("Alliance"/"Horde"/nil) can learn, easiest first.
-- Returns up to `max` (1-5) recipe tables.
function Ingredients:GetRecipes(itemId, faction, max)
  local ids = type(itemId) == "number" and self:GetIndex()[itemId] or nil
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not ids or not recipes then
    return {}
  end
  local found = {}
  for i = 1, #ids do
    local recipe = recipes[ids[i]]
    if recipe and Obtainable(recipe, faction) then
      found[#found + 1] = { id = ids[i], recipe = recipe }
    end
  end
  table.sort(found, Before)
  local limit = ClampMax(max)
  local result = {}
  for i = 1, math.min(limit, #found) do
    result[i] = found[i].recipe
  end
  return result
end

local DEFAULT_MAX_SOURCES = 3

local function ClampSources(value)
  value = tonumber(value) or DEFAULT_MAX_SOURCES
  if value < 1 then
    return 1
  elseif value > 3 then
    return 3
  end
  return math.floor(value)
end

-- Where to get an ingredient: up to `max` (1-3) { name, zone } pairs, skipping zones only the other
-- faction visits. Second return is true when vendors sell it.
function Ingredients:GetSources(itemId, faction, max)
  local data = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.SOURCES
  local entry = type(itemId) == "number" and data and data[itemId] or nil
  if not entry then
    return {}, false
  end
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

-- Returns an ordered list of tooltip line strings (empty when there is nothing to show).
-- `faction` is "Alliance", "Horde" or nil. Order: where to find it, then the recipes.
function Ingredients:BuildLines(itemId, config, faction)
  local lines = {}
  config = config or {}
  local T = function(...)
    return SimpleCookingTooltip:T(...)
  end

  if config.SHOW_SOURCES ~= false then
    local sources, vendor = self:GetSources(itemId, faction, config.MAX_SOURCES)
    for i = 1, #sources do
      lines[#lines + 1] = T("SOURCE_LINE_FMT", sources[i][1], sources[i][2])
    end
    if vendor then
      lines[#lines + 1] = T("VENDOR_LINE")
    end
  end
  if config.SHOW_RECIPES ~= false then
    local recipes = self:GetRecipes(itemId, faction, config.MAX_RECIPES)
    for i = 1, #recipes do
      lines[#lines + 1] = T("RECIPE_LINE_FMT", recipes[i].name, math.max(recipes[i].skill, 1))
    end
  end
  return lines
end
