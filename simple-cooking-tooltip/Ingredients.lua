-- Ingredient -> recipe lookup, faction/skill filtering and tooltip line formatting (pure Lua, no client API).
-- `player` (optional) = { faction = "Alliance"|"Horde"|nil, skill = Cooking rank|nil, level = character level|nil }
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Ingredients = SimpleCookingTooltip.Ingredients or {}

local Ingredients = SimpleCookingTooltip.Ingredients

local DEFAULT_MAX_SOURCES = 3

-- Labels ("Dropped by:", "Keep for:", ...) get their own colour; the values after them are plain white
-- (zone names keep their level colours). `LABEL_COLOR` in Config.lua is a hex string like "ffd100".
local DEFAULT_LABEL_COLOR = "ffd100"

local function Label(text, config)
  local color = config and config.LABEL_COLOR or DEFAULT_LABEL_COLOR
  return "|cff" .. color .. text .. "|r"
end

-- Zone name colours, like mob difficulty: red = too high, yellow = on level, green = a little below,
-- gray = far below.
local ZONE_COLORS = {
  red = "|cffff3030",
  yellow = "|cffffff00",
  green = "|cff1eff00",
  gray = "|cff9d9d9d",
}

-- Locale key of the label for each kind of source.
local SOURCE_LINE_KEYS = {
  drop = "DROPPED_LABEL",
  fish = "FISHED_LABEL",
  gather = "GATHERED_LABEL",
  object = "LOOTED_LABEL",
}

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

-- Among recipes already past their optimal level, the one that stays orange/yellow the longest.
local function LastsLonger(a, b)
  if a.green ~= b.green then
    return a.green > b.green
  end
  return Nearer(a, b)
end

-- A recipe counts while it is still orange or yellow for the player (skill < green). Green recipes
-- rarely give skill-ups, so they do not count.
local function StillUseful(recipe, skill)
  return skill == nil or recipe.green > skill
end

-- The recipe to keep `itemId` for: among recipes the player's faction can learn that can still give
-- orange or yellow (now or later), the nearest upwards (lowest optimal level >= current Cooking skill).
-- When every such recipe is already past its optimal level, the one that stays useful the longest.
-- Returns the recipe table, or nil when the ingredient is not needed any more.
function Ingredients:GetNearestRecipe(itemId, player)
  local ids = type(itemId) == "number" and self:GetIndex()[itemId] or nil
  local recipes = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.RECIPES
  if not ids or not recipes then
    return nil
  end
  player = player or {}
  local skill = player.skill
  local ahead, behind = nil, nil
  for i = 1, #ids do
    local recipe = recipes[ids[i]]
    if recipe and Obtainable(recipe, player.faction) and StillUseful(recipe, skill) then
      if skill == nil or recipe.skill >= skill then
        if not ahead or Nearer(recipe, ahead) then
          ahead = recipe
        end
      elseif not behind or LastsLonger(recipe, behind) then
        behind = recipe
      end
    end
  end
  return ahead or behind
end

-- Where to get an ingredient: up to `max` (1-3) { name, zone, kind? } tables, skipping zones only the other
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
    local sourceFaction = source.faction
    if sourceFaction == nil or faction == nil or sourceFaction == faction then
      sources[#sources + 1] = source
      if #sources == limit then
        break
      end
    end
  end
  return sources, entry.vendor == true
end

-- Difficulty of a zone for a character of `level`: "red", "yellow", "green" or "gray"; nil when the zone
-- has no known level range or the level is unknown. The zone level used is the one in its range nearest
-- to the player, so a zone whose range contains the player's level is yellow.
--   more than YELLOW_RANGE above the player -> red
--   within YELLOW_RANGE (default 2) above or below -> yellow
--   below that, up to ZONE_GRAY_BELOW (default 8) levels below -> green, further below -> gray
function Ingredients:GetZoneDifficulty(zone, level, config)
  local zones = SimpleCookingTooltip.Data and SimpleCookingTooltip.Data.ZONES
  local range = zones and zones[zone] or nil
  if not range or type(level) ~= "number" then
    return nil
  end
  config = config or {}
  local band = tonumber(config.ZONE_YELLOW_RANGE) or 2
  local gray = tonumber(config.ZONE_GRAY_BELOW) or 8
  local nearest = math.min(math.max(level, range[1]), range[2])
  local diff = nearest - level
  if diff > band then
    return "red"
  elseif diff >= -band then
    return "yellow"
  elseif diff > -gray then
    return "green"
  end
  return "gray"
end

-- The zone name, coloured by difficulty when COLOR_ZONES is on and the zone level is known.
function Ingredients:ColorZone(zone, level, config)
  if config and config.COLOR_ZONES == false then
    return zone
  end
  local difficulty = self:GetZoneDifficulty(zone, level, config)
  if not difficulty then
    return zone
  end
  return ZONE_COLORS[difficulty] .. zone .. "|r"
end

-- Returns tooltip lines (empty when there is nothing to show):
--   "Dropped by: Prowler (Elwynn Forest)"  /  "Fished: Darkshore"  /  "Sold by vendors"  (one line per kind;
--   the label is coloured, the values are plain)
--   "Keep for: Spiced Wolf Meat (50)"   (nearest useful recipe upwards; no line when none is left)
function Ingredients:BuildLines(itemId, config, player)
  local lines = {}
  config = config or {}
  player = player or {}
  local T = function(...)
    return SimpleCookingTooltip:T(...)
  end

  if config.SHOW_SOURCES ~= false then
    local sources, vendor = self:GetSources(itemId, player, config.MAX_SOURCES)
    -- One line per kind (dropped / fished / gathered / looted), in the order the data lists them.
    local order, groups = {}, {}
    for i = 1, #sources do
      local kind = sources[i].kind or "drop"
      if not groups[kind] then
        groups[kind] = {}
        order[#order + 1] = kind
      end
      local zone = self:ColorZone(sources[i].zone, player.level, config)
      local entry = kind == "fish" and zone or T("SOURCE_ENTRY_FMT", sources[i].name, zone)
      groups[kind][#groups[kind] + 1] = entry
    end
    for i = 1, #order do
      lines[#lines + 1] = Label(T(SOURCE_LINE_KEYS[order[i]]), config) .. " " .. table.concat(groups[order[i]], ", ")
    end
    if vendor then
      lines[#lines + 1] = Label(T("VENDOR_LINE"), config)
    end
  end
  if config.SHOW_KEEP_FOR ~= false then
    local recipe = self:GetNearestRecipe(itemId, player)
    if recipe then
      lines[#lines + 1] = Label(T("KEEP_FOR_LABEL"), config) .. " " .. T("KEEP_FOR_ENTRY_FMT", recipe.name, math.max(recipe.skill, 1))
    end
  end
  return lines
end
