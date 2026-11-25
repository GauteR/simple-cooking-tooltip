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
    and type(recipe.green) == "number"
    and recipe.green >= recipe.skill
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

-- Keep for: recipes that are still orange or yellow (skill < green); green recipes do not count.
-- Nearest upwards by optimal level; when all are already past it, the one that stays useful longest.
-- Wolf meat: Charred Wolf Meat (45, green 65), Spiced Wolf Meat (50, green 70).
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, nil).name, "Charred Wolf Meat", "no player info: lowest-skill recipe")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 1)).name, "Charred Wolf Meat", "skill 1: nearest upwards is Charred (45)")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 45)).name, "Charred Wolf Meat", "recipe equal to skill counts")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 46)).name, "Spiced Wolf Meat", "skill 46: Charred is behind, nearest upwards is Spiced (50)")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 60)).name, "Spiced Wolf Meat", "all past optimal: the one useful longest (green 70)")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 69)).name, "Spiced Wolf Meat", "still yellow/orange at 69")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, 70)), nil, "green at 70: no Keep for")
assert_eq(Ingredients:GetNearestRecipe(WOLF_MEAT, Player(nil, nil)).name, "Charred Wolf Meat", "no Cooking skill: lowest recipe")
assert_eq(Ingredients:GetNearestRecipe(6948, Alliance), nil, "untracked item has no recipe")
assert_eq(Ingredients:GetNearestRecipe("2672", Alliance), nil, "string id rejected")

-- Regression: skill 124, Murloc Fin Soup (optimal 130, green 150) is still needed; Beer Basted Boar Ribs
-- (optimal 60, green 80) is not, however it is reached (hovering its reagent in the recipe pane).
local MURLOC_FIN = 1468
assert_eq(recipes[3372].skill, 130, "Murloc Fin Soup optimal level is 130")
assert_eq(recipes[3372].green, 150, "Murloc Fin Soup green level is 150")
assert_eq(Ingredients:GetNearestRecipe(MURLOC_FIN, Player("Alliance", 124)).name, "Murloc Fin Soup", "needed at skill 124")
assert_eq(Ingredients:GetNearestRecipe(MURLOC_FIN, Player("Alliance", 149)).name, "Murloc Fin Soup", "needed until green")
assert_eq(Ingredients:GetNearestRecipe(MURLOC_FIN, Player("Alliance", 150)), nil, "not needed once green")
assert_eq(Ingredients:GetNearestRecipe(CRAG_BOAR_RIB, Player("Alliance", 124)), nil, "Beer Basted Boar Ribs is green at 124")
-- Regression: Small Spider Leg is only used by Kaldorei Spider Kabob (optimal 50, green 70): nothing to
-- keep it for at skill 124, but with an unreadable skill (nil) the lowest recipe is listed.
local SMALL_SPIDER_LEG = 5465
assert_eq(#Ingredients:BuildLines(SMALL_SPIDER_LEG, { SHOW_SOURCES = false }, Player("Alliance", 124)), 0, "no Keep for line for Small Spider Leg at 124")
assert_eq(
  Ingredients:BuildLines(SMALL_SPIDER_LEG, { SHOW_SOURCES = false }, Player("Alliance", nil))[1],
  "Keep for: Kaldorei Spider Kabob (50)",
  "skill not detected: lowest recipe listed"
)
assert_eq(
  Ingredients:BuildLines(MURLOC_FIN, { SHOW_SOURCES = false }, Player("Alliance", 124))[1],
  "Keep for: Murloc Fin Soup (130)",
  "Keep for line at skill 124"
)

-- Matches a brute-force reading of the rule for many skill levels.
local function BruteForce(itemId, skill)
  local ahead, behind
  for _, recipe in pairs(recipes) do
    for _, reagent in ipairs(recipe.reagents) do
      if reagent == itemId and recipe.green > skill then
        if recipe.skill >= skill then
          if not ahead or recipe.skill < ahead then
            ahead = recipe.skill
          end
        elseif not behind or recipe.green > behind then
          behind = recipe.green
        end
      end
    end
  end
  return ahead, behind
end
local bruteOk = true
for skill = 1, 330, 7 do
  local best = Ingredients:GetNearestRecipe(MILD_SPICES, Player(nil, skill))
  local ahead, behind = BruteForce(MILD_SPICES, skill)
  local ok
  if ahead then
    ok = best ~= nil and best.skill == ahead
  elseif behind then
    ok = best ~= nil and best.green == behind
  else
    ok = best == nil
  end
  if not ok then
    bruteOk = false
    print("  mismatch at skill " .. skill)
  end
end
assert_eq(bruteOk, true, "Mild Spices: selection matches brute force for many skill levels")

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
assert_eq(alliance[1].name, "Prowler", "Alliance source is Prowler")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, Horde, 3), 2, "Horde sees the two Horde-zone sources")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, nil, 1), 1, "MAX_SOURCES = 1")
assert_eq(#Ingredients:GetSources(WOLF_MEAT, nil, 99), 3, "MAX_SOURCES clamped to 3")
assert_eq(#Ingredients:GetSources(SCORPID_STINGER, Alliance, 3), 0, "Durotar sources hidden from Alliance")
local _, vendor = Ingredients:GetSources(MILD_SPICES, Horde, 3)
assert_eq(vendor, true, "Mild Spices sold by vendors")

-- Lines.
local lines = Ingredients:BuildLines(WOLF_MEAT, config, Player("Alliance", 46))
assert_eq(#lines, 2, "source line + Keep for line")
assert_eq(lines[1], "Dropped by: Prowler (Elwynn Forest)", "Alliance sees the dropped-by line")
assert_eq(lines[2], "Keep for: Spiced Wolf Meat (50)", "Keep for line names the nearest recipe")
assert_eq(
  Ingredients:BuildLines(WOLF_MEAT, config, Horde)[1],
  "Dropped by: Mottled Worg (Silverpine Forest), Cursed Darkhound (Tirisfal Glades)",
  "Horde dropped-by line lists sources comma separated"
)
assert_eq(Ingredients:BuildLines(MILD_SPICES, config, Horde)[1], "Sold by vendors", "vendor line")

-- Other kinds: fishing lists zones only (Raw Brilliant Smallfish, item 6291).
local fish = Ingredients:BuildLines(6291, { SHOW_KEEP_FOR = false }, Alliance)
assert_eq(fish[1], "Fished: Elwynn Forest, Stormwind City", "Alliance fishing zones only, Mulgore hidden")
local fishHorde = Ingredients:BuildLines(6291, { SHOW_KEEP_FOR = false }, Horde)
assert_eq(fishHorde[1], "Fished: Mulgore", "Horde fishing zones only")

local done = Ingredients:BuildLines(WOLF_MEAT, config, Player("Alliance", 300))
assert_eq(#done, 1, "no future recipes: only the source line")
assert_eq(done[1], "Dropped by: Prowler (Elwynn Forest)", "source line remains when recipes are outgrown")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_SOURCES = false }, nil), 1, "SHOW_SOURCES = false hides source lines")
assert_eq(#Ingredients:BuildLines(WOLF_MEAT, { SHOW_KEEP_FOR = false }, nil), 1, "SHOW_KEEP_FOR = false hides Keep for line")
assert_eq(#Ingredients:BuildLines(CRAG_BOAR_RIB, config, Horde), 0, "nothing for this faction yields no lines")
assert_eq(#Ingredients:BuildLines(6948, config, Alliance), 0, "untracked yields no lines")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
