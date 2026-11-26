-- Suggested level ranges of the zones that appear in Data/Sources.lua, used to colour zone names on the
-- tooltip against the player's level. Hand-written from the Classic zone list: not verified in Forever.
-- Zones missing here (the capital cities Stormwind City and Orgrimmar) are left uncoloured.
-- [zoneName] = { minLevel, maxLevel }
SimpleCookingTooltip = SimpleCookingTooltip or {}
SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}

SimpleCookingTooltip.Data.ZONES = {
  ["Elwynn Forest"] = { 1, 10 },
  ["Dun Morogh"] = { 1, 10 },
  ["Teldrassil"] = { 1, 10 },
  ["Durotar"] = { 1, 10 },
  ["Mulgore"] = { 1, 10 },
  ["Tirisfal Glades"] = { 1, 10 },
  ["Westfall"] = { 10, 20 },
  ["Loch Modan"] = { 10, 20 },
  ["Darkshore"] = { 10, 20 },
  ["Silverpine Forest"] = { 10, 20 },
  ["The Barrens"] = { 10, 25 },
  ["Redridge Mountains"] = { 15, 25 },
  ["Stonetalon Mountains"] = { 15, 27 },
  ["Ashenvale"] = { 18, 30 },
  ["Duskwood"] = { 18, 30 },
  ["Wetlands"] = { 20, 30 },
  ["Hillsbrad Foothills"] = { 20, 30 },
  ["Thousand Needles"] = { 25, 35 },
  ["Alterac Mountains"] = { 30, 40 },
  ["Arathi Highlands"] = { 30, 40 },
  ["Desolace"] = { 30, 40 },
  ["Stranglethorn Vale"] = { 30, 45 },
  ["Dustwallow Marsh"] = { 35, 45 },
  ["Badlands"] = { 35, 45 },
  ["Swamp of Sorrows"] = { 35, 45 },
  ["Feralas"] = { 40, 50 },
  ["The Hinterlands"] = { 40, 50 },
  ["Tanaris"] = { 40, 50 },
  ["Searing Gorge"] = { 43, 50 },
  ["Blasted Lands"] = { 45, 55 },
  ["Azshara"] = { 45, 55 },
  ["Western Plaguelands"] = { 51, 58 },
  ["Eastern Plaguelands"] = { 53, 60 },
  ["Winterspring"] = { 53, 60 },
  ["Moonglade"] = { 55, 60 },
  ["Silithus"] = { 55, 60 },
  -- Dungeons and battlegrounds.
  ["Wailing Caverns"] = { 17, 24 },
  ["Shadowfang Keep"] = { 22, 30 },
  ["Blackfathom Deeps"] = { 24, 32 },
  ["Maraudon"] = { 46, 55 },
  ["Blackrock Depths"] = { 52, 60 },
  ["Blackrock Spire"] = { 55, 60 },
  ["Dire Maul"] = { 55, 60 },
  ["Alterac Valley"] = { 51, 60 },
}
