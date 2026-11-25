-- Pure Lua tests for reading the Cooking skill from different client APIs.
-- Run: lua tests/test_player.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-cooking-tooltip"

dofile(addonRoot .. "/Player.lua")

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local Player = SimpleCookingTooltip.Player

-- Modern API: GetProfessions() -> prof1, prof2, archaeology, fishing, cooking (some nil).
local professions = {
  GetProfessions = function()
    return 11, nil, nil, 14, 15
  end,
  GetProfessionInfo = function(index)
    local data = {
      [11] = { "Blacksmithing", 0, 77 },
      [14] = { "Fishing", 0, 40 },
      [15] = { "Cooking", 0, 124 },
    }
    local row = data[index]
    return row[1], row[2], row[3], 150
  end,
}
assert_eq(Player:GetCookingSkill(professions), 124, "GetProfessions/GetProfessionInfo")

-- Cooking window API only.
local window = {
  C_TradeSkillUI = {
    GetBaseProfessionInfo = function()
      return { professionName = "Cooking", skillLevel = 98 }
    end,
  },
}
assert_eq(Player:GetCookingSkill(window), 98, "C_TradeSkillUI.GetBaseProfessionInfo")
local otherWindow = {
  C_TradeSkillUI = {
    GetBaseProfessionInfo = function()
      return { professionName = "Blacksmithing", skillLevel = 98 }
    end,
  },
}
assert_eq(Player:GetCookingSkill(otherWindow), nil, "another profession window is ignored")

-- Classic skill list.
local lines = {
  { "Professions", true },
  { "Mining", false, 0, 12 },
  { "Cooking", false, 0, 55 },
}
local skillLines = {
  GetNumSkillLines = function()
    return #lines
  end,
  GetSkillLineInfo = function(i)
    local row = lines[i]
    return row[1], row[2], row[3], row[4]
  end,
}
assert_eq(Player:GetCookingSkill(skillLines), 55, "GetSkillLineInfo fallback")

-- Not learned / no API.
local noCooking = {
  GetProfessions = function()
    return 11
  end,
  GetProfessionInfo = function()
    return "Blacksmithing", 0, 77, 150
  end,
}
assert_eq(Player:GetCookingSkill(noCooking), nil, "no Cooking learned")
assert_eq(Player:GetCookingSkill({}), nil, "no usable API")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
