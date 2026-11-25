-- Pure Lua tests for recipe data, faction filtering and line formatting.
-- Run: lua tests/test_ingredients.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-cooking-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Recipes.lua")
dofile(addonRoot .. "/Data/Sources.lua")
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

local function Player(faction, skill, isKnown)
  return { faction = faction, skill = skill, isKnown = isKnown }
end
local Alliance, Horde = Player("Alliance"), Player("Horde")

-- Ordering: selection is trainer-first, display is sorted by skill.
local list = Ingredients:GetRecipes(WOLF_MEAT, nil, 5)
assert_eq(#list, 2, "wolf meat is used by two recipes")
assert_eq(list[1].recipe.name, "Charred Wolf Meat", "sorted by skill")
assert_eq(list[2].recipe.name, "Spiced Wolf Meat", "sorted by skill (second)")

local spices = Ingredients:GetRecipes(MILD_SPICES, Alliance, 5)
assert_eq(#spices, 5, "capped at five recipes")
local sorted = true
for i = 2, #spices do
  if spices[i - 1].recipe.skill > spices[i].recipe.skill then
    sorted = false
  end
end
assert_eq(sorted, true, "displayed recipes sorted by skill")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, 99), 5, "max clamped to 5")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, 0), 1, "max clamped to 1")
assert_eq(#Ingredients:GetRecipes(MILD_SPICES, nil, nil), 5, "default max is 5")

-- Skill filter: recipes below the player's Cooking skill are hidden.
local mid = Ingredients:GetRecipes(WOLF_MEAT, Player(nil, 48), 5)
assert_eq(#mid, 1, "recipe below current skill hidden")
assert_eq(mid[1].recipe.name, "Spiced Wolf Meat", "recipe at/above current skill kept")
assert_eq(#Ingredients:GetRecipes(WOLF_MEAT, Player(nil, 50), 5), 1, "recipe equal to skill kept")
assert_eq(#Ingredients:GetRecipes(WOLF_MEAT, Player(nil, 300), 5), 0, "all outgrown")
assert_eq(#Ingredients:GetRecipes(WOLF_MEAT, Player(nil, nil), 5), 2, "no Cooking skill: nothing hidden")

-- Faction filtering.
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, Alliance, 5), 1, "Alliance recipe shown to Alliance")
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, Horde, 5), 0, "Alliance recipe hidden from Horde")
assert_eq(#Ingredients:GetRecipes(SCORPID_STINGER, Horde, 5), 1, "Horde recipe shown to Horde")
assert_eq(#Ingredients:GetRecipes(SCORPID_STINGER, Alliance, 5), 0, "Horde recipe hidden from Alliance")
assert_eq(#Ingredients:GetRecipes(CRAG_BOAR_RIB, nil, 5), 1, "no faction: nothing filtered")

-- Sources: faction-filtered, capped, vendor flag.
assert_eq(#Ingredients:GetSources(WOLF_MEAT, nil, 3), 3, "no faction: all three wolf meat sources")
local alliance = Ingredients:GetSources(WOLF_MEAT, Alliance, 3)
assert_eq(#alliance, 1, "Alliance only sees the Elwynn source")
assert_eq(alliance[1][1], "Prowler", "Alliance source is Prowler")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, Horde, 3), 2, "Horde sees the two Horde-zone sources")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, nil, 1), 1, "MAX_SOURCES = 1")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, nil, 99), 3, "MAX_SOURCES clamped to 3")
assert_eq(#Ingredients:GetSources(SCORPID_STINGER, Alliance, 3), 0, "Durotar sources hidden from Alliance")
local _, vendor = Ingredients:GetSources(MILD_SPICES, Horde, 3)
assert_eq(vendor, true, "Mild Spices sold by vendors")

-- Lines: one "Found:" line and one "Recipes:" line.
local lines = Ingredients:BuildLines(WOLF_MEAT, config, Alliance)
assert_eq(#lines, 2, "Found line + Recipes line")
assert_eq(lines[1], "Found: Prowler (Elwynn Forest)", "Alliance Found line")
assert_eq(lines[2], "Recipes: Charred Wolf Meat (45), Spiced Wolf Meat (50)", "Recipes line, uncoloured without known info")
assert_eq(
  Ingredients:BuildLines(WOLF_MEAT, config, Horde)[1],
  "Found: Mottled Worg (Silverpine Forest), Cursed Darkhound (Tirisfal Glades)",
  "Horde Found line lists sources comma separated"
)
assert_eq(Ingredients:BuildLines(MILD_SPICES, config, Horde)[1], "Found: sold by vendors", "vendor Found line")

-- Colours: green = known, red = not known.
local knowsSpiced = Player("Alliance", nil, function(id) return id == 2539 end)
local coloured = Ingredients:BuildLines(WOLF_MEAT, config, knowsSpiced)
assert_eq(
  coloured[2],
  "Recipes: |cffff4040Charred Wolf Meat (45)|r, |cff33ff33Spiced Wolf Meat (50)|r",
  "known recipe green, unknown red"
)
local hiddenKnown = Ingredients:BuildLines(WOLF_MEAT, config, Player("Alliance", 48, function(id) return id == 2539 end))
assert_eq(hiddenKnown[2], "Recipes: |cff33ff33Spiced Wolf Meat (50)|r", "recipe below skill not listed")

assert_eq(#Ingredients:BuildLines(MILD_SPICES, { MAX_RECIPES = 2 }, Horde), 2, "MAX_RECIPES = 2 keeps both lines")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_SOURCES = false }, nil), 1, "SHOW_SOURCES = false hides Found line")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_RECIPES = false }, nil), 1, "SHOW_RECIPES = false hides Recipes line")
assert_eq(#Ingredients:BuildLines(CRAG_BOAR_RIB, config, Horde), 0, "nothing for this faction yields no lines")
assert_eq(#Ingredients:BuildLines(6948, config, Alliance), 0, "untracked yields no lines")
if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
