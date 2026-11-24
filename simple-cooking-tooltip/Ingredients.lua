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
-- Returns up to `max` (1-5) recipe tables, and the lowest skill among ALL obtainable recipes.
function Ingredients:GetRecipes(itemId, faction, max)
  local ids = type(itemId) == "number" and self:GetIndex()[itemId] or nil
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not ids or not recipes then
    return {}, nil
  end
  local found, lowest = {}, nil
  for i = 1, #ids do
    local recipe = recipes[ids[i]]
    if recipe and Obtainable(recipe, faction) then
      found[#found + 1] = { id = ids[i], recipe = recipe }
      if not lowest or recipe.skill < lowest then
        lowest = recipe.skill
      end
    end
  end
  table.sort(found, Before)
  local limit = ClampMax(max)
  local result = {}
  for i = 1, math.min(limit, #found) do
    result[i] = found[i].recipe
  end
  return result, lowest
end

-- Returns an ordered list of tooltip line strings (empty when untracked or nothing obtainable).
-- `faction` is "Alliance", "Horde" or nil.
function Ingredients:BuildLines(itemId, config, faction)
  local lines = {}
  config = config or {}
  local recipes, lowest = self:GetRecipes(itemId, faction, config.MAX_RECIPES)
  if #recipes == 0 then
    return lines
  end
  local T = function(...)
    return SimpleCookingTooltip:T(...)
  end

  if config.SHOW_SKILL ~= false then
    lines[#lines + 1] = T("SKILL_LINE_FMT", math.max(lowest, 1))
  end
  if config.SHOW_RECIPES ~= false then
    for i = 1, #recipes do
      lines[#lines + 1] = T("RECIPE_LINE_FMT", recipes[i].name, math.max(recipes[i].skill, 1))
    end
  end
  return lines
end
