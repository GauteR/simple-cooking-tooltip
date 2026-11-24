-- Pure Lua tests for ingredient data and line formatting.
-- Run: lua tests/test_ingredients.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-cooking-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Ingredients.lua")
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
local data = SimpleCookingTooltip.Data.INGREDIENTS

assert_eq(Ingredients:ParseItemId("|cffffffff|Hitem:2672::::::::|h[Stringy Wolf Meat]|h|r"), 2672, "parse item link")
assert_eq(Ingredients:ParseItemId("nonsense"), nil, "parse invalid link")
assert_eq(Ingredients:IsTracked(2672), true, "tracked ingredient")
assert_eq(Ingredients:IsTracked(6948), false, "untracked item (Hearthstone)")
assert_eq(Ingredients:GetEntry("2672"), nil, "string id rejected")

-- Data integrity: every entry has a numeric skill >= 1 and at most three sources.
local count, bad = 0, 0
for id, entry in pairs(data) do
  count = count + 1
  local ok = type(id) == "number"
    and type(entry.skill) == "number"
    and entry.skill >= 1
    and type(entry.sources) == "table"
    and #entry.sources <= 3
  if not ok then
    bad = bad + 1
    print("  bad entry: " .. tostring(id))
  end
end
assert_eq(bad, 0, "all entries well-formed (" .. count .. " items)")

-- Lines.
local lines = Ingredients:BuildLines(2672, SimpleCookingTooltip.Config)
assert_eq(#lines, 4, "skill + three sources for wolf meat")
assert_eq(lines[1], "Cooking skill needed for recipes: 1", "skill line")
assert_eq(lines[2], "Found: Prowler (Elwynn Forest)", "first source line")
assert_eq(lines[4], "Found: Cursed Darkhound (Tirisfal Glades)", "third source line")

local vendorLines = Ingredients:BuildLines(2678, SimpleCookingTooltip.Config)
assert_eq(vendorLines[2], "Sold by vendors", "vendor-only line")

local capped = Ingredients:BuildLines(2672, { SHOW_SKILL = true, SHOW_SOURCES = true, MAX_SOURCES = 1 })
assert_eq(#capped, 2, "MAX_SOURCES = 1")
local clamped = Ingredients:BuildLines(2672, { MAX_SOURCES = 99 })
assert_eq(#clamped, 4, "MAX_SOURCES clamped to 3")

local noSkill = Ingredients:BuildLines(2672, { SHOW_SKILL = false })
assert_eq(#noSkill, 3, "SHOW_SKILL = false hides skill, keeps sources")
local noSources = Ingredients:BuildLines(2672, { SHOW_SOURCES = false })
assert_eq(#noSources, 1, "SHOW_SOURCES = false hides sources")
assert_eq(#Ingredients:BuildLines(6948, SimpleCookingTooltip.Config), 0, "untracked yields no lines")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
