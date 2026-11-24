-- Cooking ingredient sources and lowest recipe skill (generated; see docs/DATA.md).
-- [itemId] = { skill = lowest Cooking skill at which a recipe using it is learned,
--              zones = up to three main areas (most drops first),
--              vendor = true when also sold by vendors }
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}

SimpleCookingTooltip.Data.INGREDIENTS = {
  [769] = { skill = 1, zones = { "Westfall", "Durotar", "Elwynn Forest" } }, -- Chunk of Boar Meat
  [2672] = { skill = 1, zones = { "Elwynn Forest", "Tirisfal Glades", "Mulgore" } }, -- Stringy Wolf Meat
  [2678] = { skill = 1, zones = {  }, vendor = true }, -- Mild Spices
  [6291] = { skill = 1, zones = { "Elwynn Forest", "Mulgore", "Stormwind City" } }, -- Raw Brilliant Smallfish
  [6303] = { skill = 1, zones = { "Durotar", "Elwynn Forest", "Darkshore" } }, -- Raw Slitherskin Mackerel
  [6889] = { skill = 1, zones = { "Westfall", "Redridge Mountains", "Darkshore" } }, -- Small Egg
  [12223] = { skill = 1, zones = { "Tirisfal Glades", "Shadowfang Keep" } }, -- Meaty Bat Wing
  [17194] = { skill = 1, zones = {  }, vendor = true }, -- Holiday Spices
  [5465] = { skill = 10, zones = { "Loch Modan", "Teldrassil", "Silverpine Forest" } }, -- Small Spider Leg
  [5466] = { skill = 20, zones = { "Durotar" } }, -- Scorpid Stinger
  [2886] = { skill = 25, zones = { "Dun Morogh" } }, -- Crag Boar Rib
  [2894] = { skill = 25, zones = {  }, vendor = true }, -- Rhapsody Malt
  [4470] = { skill = 25, zones = {  }, vendor = true }, -- Simple Wood
  [1179] = { skill = 35, zones = {  }, vendor = true }, -- Ice Cold Milk
  [5467] = { skill = 35, zones = { "The Barrens", "Mulgore" } }, -- Kodo Meat
  [17196] = { skill = 35, zones = {  }, vendor = true }, -- Holiday Spirits
  [3173] = { skill = 40, zones = { "Darkshore", "Loch Modan", "Silverpine Forest" } }, -- Bear Meat
  [159] = { skill = 50, zones = {  }, vendor = true }, -- Refreshing Spring Water
  [723] = { skill = 50, zones = { "Westfall", "Redridge Mountains" } }, -- Goretusk Liver
  [2673] = { skill = 50, zones = { "Westfall" } }, -- Coyote Meat
  [4536] = { skill = 50, zones = {  }, vendor = true }, -- Shiny Red Apple
  [5468] = { skill = 50, zones = { "Darkshore", "Silverpine Forest", "The Barrens" } }, -- Soft Frenzy Flesh
  [5469] = { skill = 50, zones = { "The Barrens", "Darkshore" } }, -- Strider Meat
  [5503] = { skill = 50, zones = { "Westfall", "Darkshore" } }, -- Clam Meat
  [6289] = { skill = 50, zones = { "Stormwind City", "Orgrimmar", "The Barrens" } }, -- Raw Longjaw Mud Snapper
  [6317] = { skill = 50, zones = { "Loch Modan" } }, -- Raw Loch Frenzy
  [6361] = { skill = 50, zones = { "Wetlands", "Darkshore", "The Barrens" } }, -- Raw Rainbow Fin Albacore
  [2452] = { skill = 60, zones = { "The Barrens", "Silverpine Forest", "Dire Maul" } }, -- Swiftthistle
  [3172] = { skill = 60, zones = { "Westfall", "Loch Modan", "Redridge Mountains" } }, -- Boar Intestines
  [3174] = { skill = 60, zones = { "Duskwood", "Stonetalon Mountains", "Wetlands" } }, -- Spider Ichor
  [729] = { skill = 75, zones = { "Westfall", "Thousand Needles" } }, -- Stringy Vulture Meat
  [730] = { skill = 75, zones = { "Wetlands", "Westfall", "Redridge Mountains" } }, -- Murloc Eye
  [731] = { skill = 75, zones = { "Westfall" } }, -- Goretusk Snout
  [2674] = { skill = 75, zones = { "Darkshore", "Westfall", "Ashenvale" } }, -- Crawler Meat
  [2677] = { skill = 80, zones = { "Westfall", "Loch Modan", "Redridge Mountains" } }, -- Boar Ribs
  [2924] = { skill = 80, zones = { "Loch Modan", "Wailing Caverns" } }, -- Crocolisk Meat
  [21071] = { skill = 80, zones = { "Hillsbrad Foothills", "Loch Modan", "Ashenvale" } }, -- Raw Sagefish
  [2675] = { skill = 85, zones = { "Darkshore", "Westfall", "Ashenvale" } }, -- Crawler Claw
  [6522] = { skill = 85, zones = { "The Barrens" } }, -- Deviate Fish
  [1468] = { skill = 90, zones = { "Wetlands", "Redridge Mountains", "Ashenvale" } }, -- Murloc Fin
  [2692] = { skill = 90, zones = {  }, vendor = true }, -- Hot Spices
  [5051] = { skill = 90, zones = { "The Barrens" } }, -- Dig Rat
  [1015] = { skill = 100, zones = { "Duskwood", "Shadowfang Keep", "Ashenvale" } }, -- Lean Wolf Flank
  [1080] = { skill = 100, zones = { "Redridge Mountains" } }, -- Tough Condor Meat
  [1081] = { skill = 100, zones = { "Duskwood", "Stonetalon Mountains", "Wetlands" } }, -- Crisp Spider Meat
  [2665] = { skill = 100, zones = {  }, vendor = true }, -- Stormwind Seasoning Herbs
  [5470] = { skill = 100, zones = { "The Barrens" } }, -- Thunder Lizard Tail
  [6308] = { skill = 100, zones = { "Ashenvale", "Hillsbrad Foothills", "Stonetalon Mountains" } }, -- Raw Bristle Whisker Catfish
  [2251] = { skill = 110, zones = { "Duskwood", "Wetlands", "Hillsbrad Foothills" } }, -- Gooey Spider Leg
  [3730] = { skill = 110, zones = { "Hillsbrad Foothills", "Alterac Mountains", "Ashenvale" } }, -- Big Bear Meat
  [5471] = { skill = 110, zones = { "Stonetalon Mountains", "Ashenvale", "Azshara" } }, -- Stag Meat
  [3667] = { skill = 120, zones = { "Swamp of Sorrows", "Stranglethorn Vale", "Wetlands" } }, -- Tender Crocolisk Meat
  [3731] = { skill = 125, zones = { "Hillsbrad Foothills", "Alterac Mountains" } }, -- Lion Meat
  [5504] = { skill = 125, zones = { "Blackfathom Deeps" } }, -- Tangy Clam Meat
  [3685] = { skill = 130, zones = { "Arathi Highlands", "Wetlands", "Stranglethorn Vale" } }, -- Raptor Egg
  [3713] = { skill = 150, zones = {  }, vendor = true }, -- Soothing Spices
  [2596] = { skill = 175, zones = {  }, vendor = true }, -- Skin of Dwarven Stout
  [3404] = { skill = 175, zones = { "Blasted Lands", "Badlands", "Tanaris" } }, -- Buzzard Wing
  [3712] = { skill = 175, zones = { "Thousand Needles", "The Hinterlands", "Tanaris" } }, -- Turtle Meat
  [3821] = { skill = 175, zones = { "Feralas", "Dustwallow Marsh", "Stranglethorn Vale" } }, -- Goldthorn
  [4655] = { skill = 175, zones = { "Stranglethorn Vale" } }, -- Giant Clam Meat
  [6362] = { skill = 175, zones = { "Stranglethorn Vale", "Dustwallow Marsh", "Desolace" } }, -- Raw Rockscale Cod
  [8365] = { skill = 175, zones = { "Dustwallow Marsh", "Feralas", "Moonglade" } }, -- Raw Mithril Head Trout
  [12037] = { skill = 175, zones = { "Blasted Lands", "Tanaris", "Thousand Needles" } }, -- Mystery Meat
  [12184] = { skill = 175, zones = { "Stranglethorn Vale", "Arathi Highlands", "Un'Goro Crater" } }, -- Raptor Flesh
  [12202] = { skill = 175, zones = { "Stranglethorn Vale", "Winterspring", "Badlands" } }, -- Tiger Meat
  [12203] = { skill = 175, zones = { "Blackrock Depths", "The Hinterlands", "Badlands" } }, -- Red Wolf Meat
  [21153] = { skill = 175, zones = { "Stranglethorn Vale", "Alterac Mountains" } }, -- Raw Greater Sagefish
  [4402] = { skill = 200, zones = { "Badlands", "Dustwallow Marsh", "Swamp of Sorrows" } }, -- Small Flame Sac
  [12204] = { skill = 200, zones = { "Desolace" } }, -- Heavy Kodo Meat
  [12205] = { skill = 200, zones = { "Blackrock Spire", "Searing Gorge", "Dustwallow Marsh" } }, -- White Spider Meat
  [4603] = { skill = 225, zones = { "Azshara", "Tanaris", "Feralas" } }, -- Raw Spotted Yellowtail
  [7974] = { skill = 225, zones = { "Azshara", "Feralas" } }, -- Zesty Clam Meat
  [12206] = { skill = 225, zones = { "Swamp of Sorrows" } }, -- Tender Crab Meat
  [12207] = { skill = 225, zones = { "Winterspring", "Blasted Lands", "The Hinterlands" } }, -- Giant Egg
  [12208] = { skill = 225, zones = { "Blackrock Depths", "The Hinterlands", "Eastern Plaguelands" } }, -- Tender Wolf Meat
  [13754] = { skill = 225, zones = { "Azshara", "Tanaris", "Feralas" } }, -- Raw Glossy Mightfish
  [13758] = { skill = 225, zones = { "Feralas", "Moonglade", "Western Plaguelands" } }, -- Raw Redgill
  [13755] = { skill = 240, zones = { "Azshara", "Tanaris" } }, -- Winter Squid
  [13756] = { skill = 240, zones = { "Azshara", "Tanaris", "The Hinterlands" } }, -- Raw Summer Bass
  [13759] = { skill = 250, zones = { "Feralas", "Moonglade", "Western Plaguelands" } }, -- Raw Nightfin Snapper
  [13760] = { skill = 250, zones = { "Feralas", "Western Plaguelands", "Moonglade" } }, -- Raw Sunscale Salmon
  [239016] = { skill = 260, zones = { "Eastern Plaguelands" } }, -- Holy Salts
  [13888] = { skill = 275, zones = { "Azshara" } }, -- Darkclaw Lobster
  [13889] = { skill = 275, zones = { "Winterspring", "Alterac Valley", "Eastern Plaguelands" } }, -- Raw Whitescale Salmon
  [13893] = { skill = 275, zones = { "Azshara" } }, -- Large Raw Mightfish
  [18255] = { skill = 275, zones = { "Dire Maul", "Alterac Valley" } }, -- Runn Tum Tuber
  [20424] = { skill = 285, zones = { "Silithus" } }, -- Sandworm Meat
  [239017] = { skill = 290, zones = {  } }, -- Exquisite Spices
  [8150] = { skill = 300, zones = { "Badlands", "Maraudon", "Silithus" } }, -- Deeprock Salt
  [9061] = { skill = 300, zones = { "Maraudon", "Ashenvale" } }, -- Goblin Rocket Fuel
  [21024] = { skill = 300, zones = {  } }, -- Chimaerok Tenderloin
  [227813] = { skill = 325, zones = {  }, vendor = true }, -- Drinkable Stratholme Holy Water
}
