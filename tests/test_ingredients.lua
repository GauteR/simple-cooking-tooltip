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

local function Player(faction, skill)
  return { faction = faction, skill = skill }
end
local Alliance, Horde = Player("Alliance"), Player("Horde")

-- Nearest recipe upwards from the player's Cooking skill (skill = level the recipe is learned at).
-- Wolf meat: Charred Wolf Meat (0), Spiced Wolf Meat (10).
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, nil).name, "Charred Wolf Meat", "no player info: lowest-skill recipe")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 1)).name, "Spiced Wolf Meat", "skill 1: Charred (0) is below, nearest is Spiced (10)")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 10)).name, "Spiced Wolf Meat", "recipe equal to skill counts")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 11)), nil, "no future recipes")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, nil)).name, "Charred Wolf Meat", "no Cooking skill: lowest recipe")
assert_eq(Ingredients:GetNearestRecipe(6948, Alliance), nil, "untracked item has no recipe")
assert_eq(Ingredients:GetNearestRecipe("2672", Alliance), nil, "string id rejected")

-- Regression: a skill-124 player is past Murloc Fin Soup (learned at 90, optimal at 130).
local MURLOC_FIN = 1468
assert_eq(recipes[3372].skill, 90, "Murloc Fin Soup is learned at 90, not its yellow level 130")
assert_eq(Ingredients:GetNearestRecipe(MURLOC_FIN, Player("Alliance", 124)), nil, "no Keep for once past the learn level")
assert_eq(#Ingredients:BuildLines(MURLOC_FIN, { SHOW_SOURCES = false }, Player("Alliance", 124)), 0, "no Keep for line at skill 124")

-- Nearest is the lowest skill >= current skill, whatever the number of recipes.
local nearestOk = true
for skill = 1, 320, 7 do
  local best = Ingredients:GetNearestRecipe(MILD_SPICES, Player(nil, skill))
  local expected = nil
  for _, recipe in pairs(recipes) do
    for _, itemId in ipairs(recipe.reagents) do
      if itemId == MILD_SPICES and recipe.skill >= skill and (expected == nil or recipe.skill < expected) then
        expected = recipe.skill
      end
    end
  end
  if (best and best.skill) ~= expected then
    nearestOk = false
    print(string.format("  skill %d: expected %s got %s", skill, tostring(expected), tostring(best and best.skill)))
  end
end
assert_eq(nearestOk, true, "Mild Spices: nearest skill matches brute force for many skill levels")

-- Faction filtering.
assert_eq(Ingredients:GetNearestRecipe(CRAG_BOAR_RIB, Alliance).name, "Beer Basted Boar Ribs", "Alliance recipe shown to Alliance")
assert_eq(Ingredients:GetNearestRecipe(CRAG_BOAR_RIB, Horde), nil, "Alliance recipe hidden from Horde")
assert_eq(Ingredients:GetNearestRecipe(SCORPID_STINGER, Horde).name, "Scorpid Surprise", "Horde recipe shown to Horde")
assert_eq(Ingredients:GetNearestRecipe(SCORPID_STINGER, Alliance), nil, "Horde recipe hidden from Alliance")
assert_eq(Ingredients:GetNearestRecipe(CRAG_BOAR_RIB, nil).name, "Beer Basted Boar Ribs", "no faction: nothing filtered")

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

-- Lines.
local lines = Ingredients:BuildLines(WOLF_MEAT, config, Player("Alliance", 1))
assert_eq(#lines, 2, "Found line + Keep for line")
assert_eq(lines[1], "Found: Prowler (Elwynn Forest)", "Alliance Found line")
assert_eq(lines[2], "Keep for: Spiced Wolf Meat (10)", "Keep for line names the nearest recipe")
assert_eq(
  Ingredients:BuildLines(WOLF_MEAT, config, Horde)[1],
  "Found: Mottled Worg (Silverpine Forest), Cursed Darkhound (Tirisfal Glades)",
  "Horde Found line lists sources comma separated"
)
assert_eq(Ingredients:BuildLines(MILD_SPICES, config, Horde)[1], "Found: sold by vendors", "vendor Found line")
local done = Ingredients:BuildLines(WOLF_MEAT, config, Player("Alliance", 300))
assert_eq(#done, 1, "no future recipes: only the Found line")
assert_eq(done[1], "Found: Prowler (Elwynn Forest)", "Found line remains when recipes are outgrown")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_SOURCES = false }, nil), 1, "SHOW_SOURCES = false hides Found line")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_KEEP_FOR = false }, nil), 1, "SHOW_KEEP_FOR = false hides Keep for line")
assert_eq(#Ingredients:BuildLines(CRAG_BOAR_RIB, config, Horde), 0, "nothing for this faction yields no lines")
assert_eq(#Ingredients:BuildLines(6948, config, Alliance), 0, "untracked yields no lines")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
