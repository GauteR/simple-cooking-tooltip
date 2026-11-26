-- Pure Lua tests for tooltip append dedupe.
-- Run: lua tests/test_tooltip.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-cooking-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Recipes.lua")
dofile(addonRoot .. "/Data/Sources.lua")
dofile(addonRoot .. "/Data/Zones.lua")
dofile(addonRoot .. "/Ingredients.lua")
dofile(addonRoot .. "/Tooltip.lua")

function SimpleCookingTooltip:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local Tooltip = SimpleCookingTooltip.Tooltip

local function NewMockTooltip()
  local tip = { lines = {} }
  function tip:AddLine(text)
    self.lines[#self.lines + 1] = text
  end
  return tip
end

local tip = NewMockTooltip()
Tooltip:AppendForItem(tip, 2672)
assert_eq(#tip.lines, 3, "blank spacer + dropped-by line + Keep for line")
Tooltip:AppendForItem(tip, 2672)
assert_eq(#tip.lines, 3, "same item not appended twice")
Tooltip:ClearAppendState(tip)
Tooltip:AppendForItem(tip, 2672)
assert_eq(#tip.lines, 6, "appends again after clear")

local other = NewMockTooltip()
Tooltip:AppendForItem(other, 6948)
assert_eq(#other.lines, 0, "untracked item adds nothing")

SimpleCookingTooltip.Config.ENABLED = false
local off = NewMockTooltip()
Tooltip:AppendForItem(off, 2672)
assert_eq(#off.lines, 0, "disabled adds nothing")
SimpleCookingTooltip.Config.ENABLED = true

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
