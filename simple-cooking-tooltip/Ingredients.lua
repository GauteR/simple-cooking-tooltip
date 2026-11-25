-- Ingredient -> recipe lookup, faction/skill filtering and tooltip line formatting (pure Lua, no client API).
-- `player` (optional) = { faction = "Alliance"|"Horde"|nil, skill = Cooking rank|nil,
--                         isKnown = function(spellId) -> boolean|nil }
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_RECIPES = 5
local MAX_RECIPES_LIMIT = 5
local DEFAULT_MAX_SOURCES = 3

-- Lower rank = easier to get. Unknown learn types sort last.
local LEARN_RANK = { trainer = 1, item = 2 }

local COLOR_KNOWN = "|cff33ff33"
local COLOR_UNKNOWN = "|cffff4040"
local COLOR_END = "|r"

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

local function ClampRecipes(value)
  value = tonumber(value) or DEFAULT_MAX_RECIPES
  if value < 1 then
    return 1
  elseif value > MAX_RECIPES_LIMIT then
    return MAX_RECIPES_LIMIT
  end
  return math.floor(value)
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

-- Easiest to get first: trainer, then recipe item, then lowest skill, then name.
local function ByEase(a, b)
  local ra, rb = LEARN_RANK[a.recipe.learn] or 99, LEARN_RANK[b.recipe.learn] or 99
  if ra ~= rb then
    return ra < rb
  end
  if a.recipe.skill ~= b.recipe.skill then
    return a.recipe.skill < b.recipe.skill
  end
  return a.recipe.name < b.recipe.name
end

local function BySkill(a, b)
  if a.recipe.skill ~= b.recipe.skill then
    return a.recipe.skill < b.recipe.skill
  end
  return a.recipe.name < b.recipe.name
end

-- Recipes using `itemId` that the player's faction can learn and that are not already outgrown
-- (required skill >= current Cooking skill). The `max` (1-5) easiest to get are kept, then
-- returned sorted by skill as { id = spellId, recipe = recipe } entries.
function Ingredients:GetRecipes(itemId, player, max)
  local ids = type(itemId) == "number" and self:GetIndex()[itemId] or nil
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not ids or not recipes then
    return {}
  end
  player = player or {}
  local found = {}
  for i = 1, #ids do
    local recipe = recipes[ids[i]]
    if recipe and Obtainable(recipe, player.faction) and (player.skill == nil or recipe.skill >= player.skill) then
      found[#found + 1] = { id = ids[i], recipe = recipe }
    end
  end
  table.sort(found, ByEase)
  local limit = ClampRecipes(max)
  local kept = {}
  for i = 1, math.min(limit, #found) do
    kept[i] = found[i]
  end
  table.sort(kept, BySkill)
  return kept
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

local function Colorize(text, known)
  if known == true then
    return COLOR_KNOWN .. text .. COLOR_END
  elseif known == false then
    return COLOR_UNKNOWN .. text .. COLOR_END
  end
  return text
end

-- Returns tooltip lines (empty when there is nothing to show):
--   "Found: Prowler (Elwynn Forest), sold by vendors"
--   "Recipes: Spiced Wolf Meat (50), ..."  (sorted by skill; green = known, red = not known)
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
  if config.SHOW_RECIPES ~= false then
    local recipes = self:GetRecipes(itemId, player, config.MAX_RECIPES)
    local parts = {}
    for i = 1, #recipes do
      local text = T("RECIPE_ENTRY_FMT", recipes[i].recipe.name, math.max(recipes[i].recipe.skill, 1))
      local known = nil
      if player.isKnown then
        known = player.isKnown(recipes[i].id) and true or false
      end
      parts[#parts + 1] = Colorize(text, known)
    end
    if #parts > 0 then
      lines[#lines + 1] = T("RECIPES_LINE_FMT", table.concat(parts, ", "))
    end
  end
  return lines
end
