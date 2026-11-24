-- Pure Lua tests for recipe data, faction filtering and line formatting.
-- Run: lua tests/test_ingredients.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-cooking-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Recipes.lua")
dofile(addonRoot .. "/Ingredients.lua")

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local Ingredients = SimpleCookingTooltip.Ingredients
local recipes = SimpleCookingTooltip.Data.RECIPES
local config = SimpleCookingTooltip.Config

local WOLF_MEAT = 2672 -- Stringy Wolf Meat
local MILD_SPICES = 2678
local CRAG_BOAR_RIB = 2886 -- only Beer Basted Boar Ribs (Alliance recipe item)
local SCORPID_STINGER = 5466 -- only Scorpid Surprise (Horde recipe item)

assert_eq(Ingredients:ParseItemId("|cffffffff|Hitem:2672::::::::|h[Stringy Wolf Meat]|h|r"), 2672, "parse item link")
assert_eq(Ingredients:ParseItemId("nonsense"), nil, "parse invalid link")
assert_eq(Ingredients:IsTracked(WOLF_MEAT), true, "tracked ingredient")
assert_eq(Ingredients:IsTracked(6948), false, "untracked item (Hearthstone)")
assert_eq(Ingredients:IsTracked("2672"), false, "string id rejected")

-- Data integrity.
local count, bad = 0, 0
for id, recipe in pairs(recipes) do
  count = count + 1
  local ok = type(id) == "number"
    and type(recipe.name) == "string"
    and type(recipe.skill) == "number"
    and recipe.skill >= 0
    and (recipe.learn == "trainer" or recipe.learn == "item")
    and (recipe.faction == nil or recipe.faction == "Alliance" or recipe.faction == "Horde")
    and type(recipe.reagents) == "table"
    and #recipe.reagents >= 1
  for _, itemId in ipairs(recipe.reagents or {}) do
    ok = ok and type(itemId) == "number"
  end
  if not ok then
    bad = bad + 1
    print("  bad recipe: " .. tostring(id))
  end
end
assert_eq(bad, 0, "all recipes well-formed")
assert_eq(count, 132, "all 132 Forever cooking recipes present")

-- Lowest skill and ordering.
local list, lowest = Ingredients:GetRecipes(WOLF_MEAT, nil, 5)
assert_eq(#list, 2, "wolf meat is used by two recipes")
assert_eq(lowest, 45, "lowest skill for wolf meat")
assert_eq(list[1].name, "Charred Wolf Meat", "lowest skill first among trainer recipes")

-- Cap at 5, trainer recipes before recipe-item recipes, then skill ascending.
local spices = Ingredients:GetRecipes(MILD_SPICES, "Alliance", 5)
assert_eq(#spices, 5, "capped at five recipes")
local ordered = true
for i = 2, #spices do
  local a, b = spices[i - 1], spices[i]
  if a.learn == "item" and b.learn == "trainer" then
    ordered = false
  end
  if a.learn == b.learn and a.skill > b.skill then
    ordered = false
  end
end
assert_eq(ordered, true, "trainer first, then lowest skill")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, 99), 5, "max clamped to 5")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, 0), 1, "max clamped to 1")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, nil), 5, "default max is 5")

-- Faction filtering.
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, "Alliance", 5), 1, "Alliance recipe shown to Alliance")
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, "Horde", 5), 0, "Alliance recipe hidden from Horde")
assert_eq(#Ingredients:GetRecipes(SCORPID_STINGER, "Horde", 5), 1, "Horde recipe shown to Horde")
assert_eq(#Ingredients:GetRecipes(SCORPID_STINGER, "Alliance", 5), 0, "Horde recipe hidden from Alliance")
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, nil, 5), 1, "no faction: nothing filtered")

-- Lines.
local lines = Ingredients:BuildLines(WOLF_MEAT, config, "Alliance")
assert_eq(#lines, 3, "skill + two recipes for wolf meat")
assert_eq(lines[1], "Cooking skill needed for recipes: 45", "skill line")
assert_eq(lines[2], "Charred Wolf Meat (skill 45)", "first recipe line")
assert_eq(lines[3], "Spiced Wolf Meat (skill 50)", "second recipe line")
assert_eq(#Ingredients:BuildLines(MILD_SPICES, config, "Horde"), 6, "skill + five recipes")
assert_eq(#Ingredients:BuildLines(MILD_SPICES, { MAX_RECIPES = 2 }, "Horde"), 3, "MAX_RECIPES = 2")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_SKILL = false }, nil), 2, "SHOW_SKILL = false hides skill")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_RECIPES = false }, nil), 1, "SHOW_RECIPES = false hides recipes")
assert_eq(#Ingredients:BuildLines(CRAG_BOAR_RIB, config, "Horde"), 0, "nothing obtainable yields no lines")
assert_eq(#Ingredients:BuildLines(6948, config, "Alliance"), 0, "untracked yields no lines")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
