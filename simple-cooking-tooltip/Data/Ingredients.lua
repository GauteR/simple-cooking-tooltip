-- Cooking ingredient sources and lowest recipe skill (generated; see docs/DATA.md).
-- [itemId] = { skill = lowest Cooking skill at which a recipe using it is learned,
--              sources = up to three { mobOrObjectName, areaName } pairs (most drops first),
--              vendor = true when sold by vendors (such items list no sources) }
SimpleCookingTooltip = SimpleCookingTooltip or {}

SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}

SimpleCookingTooltip.Data.INGREDIENTS = {
  [769] = { skill = 1, sources = { { "Young Goretusk", "Westfall" }, { "Great Goretusk", "Redridge Mountains" }, { "Dire Mottled Boar", "Durotar" } } }, -- Chunk of Boar Meat
  [2672] = { skill = 1, sources = { { "Prowler", "Elwynn Forest" }, { "Mottled Worg", "Silverpine Forest" }, { "Cursed Darkhound", "Tirisfal Glades" } } }, -- Stringy Wolf Meat
  [2678] = { skill = 1, sources = {  }, vendor = true }, -- Mild Spices
  [6291] = { skill = 1, sources = { { "Fishing", "Elwynn Forest" }, { "Fishing", "Mulgore" }, { "Fishing", "Stormwind City" } } }, -- Raw Brilliant Smallfish
  [6303] = { skill = 1, sources = { { "Fishing", "Darkshore" }, { "Fishing", "The Barrens" }, { "Fishing", "Durotar" } } }, -- Raw Slitherskin Mackerel
  [6889] = { skill = 1, sources = { { "Dire Condor", "Redridge Mountains" }, { "Fleshripper", "Westfall" }, { "Young Fleshripper", "Westfall" } } }, -- Small Egg
  [12223] = { skill = 1, sources = { { "Greater Duskbat", "Tirisfal Glades" }, { "Vampiric Duskbat", "Tirisfal Glades" }, { "Vile Bat", "Shadowfang Keep" } } }, -- Meaty Bat Wing
  [17194] = { skill = 1, sources = {  }, vendor = true }, -- Holiday Spices
  [5465] = { skill = 10, sources = { { "Forest Lurker", "Loch Modan" }, { "Moss Stalker", "Silverpine Forest" }, { "Webwood Lurker", "Teldrassil" } } }, -- Small Spider Leg
  [5466] = { skill = 20, sources = { { "Clattering Scorpid", "Durotar" }, { "Venomtail Scorpid", "Durotar" }, { "Armored Scorpid", "Orgrimmar" } } }, -- Scorpid Stinger
  [2886] = { skill = 25, sources = { { "Crag Boar", "Dun Morogh" }, { "Elder Crag Boar", "Dun Morogh" }, { "Large Crag Boar", "Dun Morogh" } } }, -- Crag Boar Rib
  [2894] = { skill = 25, sources = {  }, vendor = true }, -- Rhapsody Malt
  [4470] = { skill = 25, sources = {  }, vendor = true }, -- Simple Wood
  [1179] = { skill = 35, sources = {  }, vendor = true }, -- Ice Cold Milk
  [5467] = { skill = 35, sources = { { "Lost Barrens Kodo", "The Barrens" }, { "Lakota'mani", "The Barrens" }, { "Barrens Kodo", "The Barrens" } } }, -- Kodo Meat
  [17196] = { skill = 35, sources = {  }, vendor = true }, -- Holiday Spirits
  [3173] = { skill = 40, sources = { { "Rabid Thistle Bear", "Darkshore" }, { "Elder Black Bear", "Loch Modan" }, { "Thistle Bear", "Darkshore" } } }, -- Bear Meat
  [159] = { skill = 50, sources = {  }, vendor = true }, -- Refreshing Spring Water
  [723] = { skill = 50, sources = { { "Great Goretusk", "Redridge Mountains" }, { "Young Goretusk", "Westfall" }, { "Goretusk", "Westfall" } } }, -- Goretusk Liver
  [2673] = { skill = 50, sources = { { "Coyote", "Westfall" }, { "Coyote Packleader", "Westfall" } } }, -- Coyote Meat
  [4536] = { skill = 50, sources = {  }, vendor = true }, -- Shiny Red Apple
  [5468] = { skill = 50, sources = { { "Coastal Frenzy", "Darkshore" }, { "Muck Frenzy", "The Barrens" }, { "Reef Frenzy", "Silverpine Forest" } } }, -- Soft Frenzy Flesh
  [5469] = { skill = 50, sources = { { "Greater Plainstrider", "The Barrens" }, { "Ornery Plainstrider", "The Barrens" }, { "Fleeting Plainstrider", "The Barrens" } } }, -- Strider Meat
  [5503] = { skill = 50, sources = { { "Brack", "Westfall" }, { "Slark", "Westfall" }, { "Lady Vespira", "Darkshore" } } }, -- Clam Meat
  [6289] = { skill = 50, sources = { { "Fishing", "Stormwind City" }, { "Fishing", "Orgrimmar" }, { "Fishing", "The Barrens" } } }, -- Raw Longjaw Mud Snapper
  [6317] = { skill = 50, sources = { { "Fishing", "Loch Modan" } } }, -- Raw Loch Frenzy
  [6361] = { skill = 50, sources = { { "Fishing", "Wetlands" }, { "Fishing", "Darkshore" }, { "Fishing", "The Barrens" } } }, -- Raw Rainbow Fin Albacore
  [2452] = { skill = 60, sources = { { "Briarthorn", "The Barrens" }, { "Mageroyal", "The Barrens" }, { "Whip Lasher", "Dire Maul" } } }, -- Swiftthistle
  [3172] = { skill = 60, sources = { { "Great Goretusk", "Redridge Mountains" }, { "Young Goretusk", "Westfall" }, { "Goretusk", "Westfall" } } }, -- Boar Intestines
  [3174] = { skill = 60, sources = { { "Black Widow Hatchling", "Duskwood" }, { "Leech Stalker", "Wetlands" }, { "Deepmoss Venomspitter", "Stonetalon Mountains" } } }, -- Spider Ichor
  [729] = { skill = 75, sources = { { "Salt Flats Scavenger", "Thousand Needles" }, { "Fleshripper", "Westfall" }, { "Young Fleshripper", "Westfall" } } }, -- Stringy Vulture Meat
  [730] = { skill = 75, sources = { { "Bluegill Raider", "Wetlands" }, { "Bluegill Murloc", "Wetlands" }, { "Murloc Flesheater", "Redridge Mountains" } } }, -- Murloc Eye
  [731] = { skill = 75, sources = { { "Young Goretusk", "Westfall" }, { "Goretusk", "Westfall" } } }, -- Goretusk Snout
  [2674] = { skill = 75, sources = { { "Pygmy Tide Crawler", "Darkshore" }, { "Reef Crawler", "Darkshore" }, { "Encrusted Tide Crawler", "Darkshore" } } }, -- Crawler Meat
  [2677] = { skill = 80, sources = { { "Great Goretusk", "Redridge Mountains" }, { "Young Goretusk", "Westfall" }, { "Goretusk", "Westfall" } } }, -- Boar Ribs
  [2924] = { skill = 80, sources = { { "Loch Crocolisk", "Loch Modan" }, { "Deviate Crocolisk", "Wailing Caverns" } } }, -- Crocolisk Meat
  [21071] = { skill = 80, sources = { { "Fishing", "Hillsbrad Foothills" }, { "Fishing", "Loch Modan" }, { "Fishing", "Ashenvale" } } }, -- Raw Sagefish
  [2675] = { skill = 85, sources = { { "Pygmy Tide Crawler", "Darkshore" }, { "Reef Crawler", "Darkshore" }, { "Encrusted Tide Crawler", "Darkshore" } } }, -- Crawler Claw
  [6522] = { skill = 85, sources = { { "Fishing", "The Barrens" } } }, -- Deviate Fish
  [1468] = { skill = 90, sources = { { "Bluegill Raider", "Wetlands" }, { "Bluegill Murloc", "Wetlands" }, { "Murloc Flesheater", "Redridge Mountains" } } }, -- Murloc Fin
  [2692] = { skill = 90, sources = {  }, vendor = true }, -- Hot Spices
  [5051] = { skill = 90, sources = { { "Dig Rat", "The Barrens" } } }, -- Dig Rat
  [1015] = { skill = 100, sources = { { "Starving Dire Wolf", "Duskwood" }, { "Rabid Dire Wolf", "Duskwood" }, { "Slavering Worg", "Shadowfang Keep" } } }, -- Lean Wolf Flank
  [1080] = { skill = 100, sources = { { "Dire Condor", "Redridge Mountains" } } }, -- Tough Condor Meat
  [1081] = { skill = 100, sources = { { "Black Widow Hatchling", "Duskwood" }, { "Leech Stalker", "Wetlands" }, { "Deepmoss Venomspitter", "Stonetalon Mountains" } } }, -- Crisp Spider Meat
  [2665] = { skill = 100, sources = {  }, vendor = true }, -- Stormwind Seasoning Herbs
  [5470] = { skill = 100, sources = { { "Thunderhead", "The Barrens" }, { "Stormhide", "The Barrens" }, { "Stormsnout", "The Barrens" } } }, -- Thunder Lizard Tail
  [6308] = { skill = 100, sources = { { "Fishing", "Ashenvale" }, { "Fishing", "Stonetalon Mountains" }, { "Fishing", "Stormwind City" } } }, -- Raw Bristle Whisker Catfish
  [2251] = { skill = 110, sources = { { "Black Widow Hatchling", "Duskwood" }, { "Leech Stalker", "Wetlands" }, { "Pygmy Venom Web Spider", "Duskwood" } } }, -- Gooey Spider Leg
  [3730] = { skill = 110, sources = { { "Vicious Gray Bear", "Hillsbrad Foothills" }, { "Gray Bear", "Hillsbrad Foothills" }, { "Elder Gray Bear", "Hillsbrad Foothills" } } }, -- Big Bear Meat
  [5471] = { skill = 110, sources = { { "Antlered Courser", "Stonetalon Mountains" }, { "Mosshoof Courser", "Azshara" }, { "Elder Shadowhorn Stag", "Ashenvale" } } }, -- Stag Meat
  [3667] = { skill = 120, sources = { { "Snapjaw Crocolisk", "Stranglethorn Vale" }, { "Sawtooth Snapper", "Swamp of Sorrows" }, { "Sawtooth Crocolisk", "Swamp of Sorrows" } } }, -- Tender Crocolisk Meat
  [3731] = { skill = 125, sources = { { "Starving Mountain Lion", "Hillsbrad Foothills" }, { "Mountain Lion", "Hillsbrad Foothills" }, { "Hulking Mountain Lion", "Alterac Mountains" } } }, -- Lion Meat
  [5504] = { skill = 125, sources = { { "Blackfathom Myrmidon", "Blackfathom Deeps" }, { "Aku'mai Snapjaw", "Blackfathom Deeps" }, { "Blindlight Muckdweller", "Blackfathom Deeps" } } }, -- Tangy Clam Meat
  [3685] = { skill = 130, sources = { { "Highland Strider", "Arathi Highlands" }, { "Lashtail Raptor", "Stranglethorn Vale" }, { "Highland Fleshstalker", "Arathi Highlands" } } }, -- Raptor Egg
  [3713] = { skill = 150, sources = {  }, vendor = true }, -- Soothing Spices
  [2596] = { skill = 175, sources = {  }, vendor = true }, -- Skin of Dwarven Stout
  [3404] = { skill = 175, sources = { { "Black Slayer", "Blasted Lands" }, { "Giant Buzzard", "Badlands" }, { "Fire Roc", "Tanaris" } } }, -- Buzzard Wing
  [3712] = { skill = 175, sources = { { "Saltwater Snapjaw", "The Hinterlands" }, { "Snapjaw", "Hillsbrad Foothills" }, { "Sparkleshell Snapper", "Thousand Needles" } } }, -- Turtle Meat
  [3821] = { skill = 175, sources = { { "Goldthorn", "Feralas" }, { "Whip Lasher", "Dire Maul" } } }, -- Goldthorn
  [4655] = { skill = 175, sources = { { "Giant Clam", "Stranglethorn Vale" } } }, -- Giant Clam Meat
  [6362] = { skill = 175, sources = { { "Fishing", "Stranglethorn Vale" }, { "Fishing", "Dustwallow Marsh" }, { "Fishing", "Tanaris" } } }, -- Raw Rockscale Cod
  [8365] = { skill = 175, sources = { { "Fishing", "Dustwallow Marsh" }, { "Fishing", "Feralas" }, { "Fishing", "Moonglade" } } }, -- Raw Mithril Head Trout
  [12037] = { skill = 175, sources = { { "Black Slayer", "Blasted Lands" }, { "Scorpok Stinger", "Blasted Lands" }, { "Starving Snickerfang", "Blasted Lands" } } }, -- Mystery Meat
  [12184] = { skill = 175, sources = { { "Jungle Stalker", "Stranglethorn Vale" }, { "Lashtail Raptor", "Stranglethorn Vale" }, { "Highland Strider", "Arathi Highlands" } } }, -- Raptor Flesh
  [12202] = { skill = 175, sources = { { "Young Stranglethorn Tiger", "Stranglethorn Vale" }, { "Stranglethorn Tigress", "Stranglethorn Vale" }, { "Stranglethorn Tiger", "Stranglethorn Vale" } } }, -- Tiger Meat
  [12203] = { skill = 175, sources = { { "Bloodhound", "Blackrock Depths" }, { "Elder Crag Coyote", "Badlands" }, { "Plaguehound Runt", "Eastern Plaguelands" } } }, -- Red Wolf Meat
  [21153] = { skill = 175, sources = { { "Fishing", "Stranglethorn Vale" }, { "Fishing", "Alterac Mountains" } } }, -- Raw Greater Sagefish
  [4402] = { skill = 200, sources = { { "Scalding Whelp", "Badlands" }, { "Searing Hatchling", "Dustwallow Marsh" }, { "Sprite Darter", "Feralas" } } }, -- Small Flame Sac
  [12204] = { skill = 200, sources = { { "Aged Kodo", "Desolace" }, { "Dying Kodo", "Desolace" }, { "Ancient Kodo", "Desolace" } } }, -- Heavy Kodo Meat
  [12205] = { skill = 200, sources = { { "Spire Spiderling", "Blackrock Spire" }, { "Greater Lava Spider", "Searing Gorge" }, { "Glassweb Spider", "Searing Gorge" } } }, -- White Spider Meat
  [4603] = { skill = 225, sources = { { "Fishing", "Azshara" }, { "Fishing", "Tanaris" }, { "Fishing", "Feralas" } } }, -- Raw Spotted Yellowtail
  [7974] = { skill = 225, sources = { { "Fishing", "Azshara" }, { "Fishing", "Feralas" } } }, -- Zesty Clam Meat
  [12206] = { skill = 225, sources = { { "Monstrous Crawler", "Swamp of Sorrows" }, { "Silt Crawler", "Swamp of Sorrows" } } }, -- Tender Crab Meat
  [12207] = { skill = 225, sources = { { "Black Slayer", "Blasted Lands" }, { "Moontouched Owlbeast", "Winterspring" }, { "Berserk Owlbeast", "Winterspring" } } }, -- Giant Egg
  [12208] = { skill = 225, sources = { { "Bloodhound", "Blackrock Depths" }, { "Plaguehound Runt", "Eastern Plaguelands" }, { "Starving Snickerfang", "Blasted Lands" } } }, -- Tender Wolf Meat
  [13754] = { skill = 225, sources = { { "Fishing", "Azshara" }, { "Fishing", "Tanaris" }, { "Fishing", "Feralas" } } }, -- Raw Glossy Mightfish
  [13758] = { skill = 225, sources = { { "Fishing", "Feralas" }, { "Fishing", "Moonglade" }, { "Fishing", "Western Plaguelands" } } }, -- Raw Redgill
  [13755] = { skill = 240, sources = { { "Fishing", "Azshara" }, { "Fishing", "Tanaris" } } }, -- Winter Squid
  [13756] = { skill = 240, sources = { { "Fishing", "Azshara" }, { "Fishing", "Tanaris" }, { "Fishing", "The Hinterlands" } } }, -- Raw Summer Bass
  [13759] = { skill = 250, sources = { { "Fishing", "Feralas" }, { "Fishing", "Moonglade" }, { "Fishing", "Western Plaguelands" } } }, -- Raw Nightfin Snapper
  [13760] = { skill = 250, sources = { { "Fishing", "Feralas" }, { "Fishing", "Western Plaguelands" }, { "Fishing", "Moonglade" } } }, -- Raw Sunscale Salmon
  [239016] = { skill = 260, sources = { { "Scarlet Footman", "Eastern Plaguelands" }, { "Scarlet Archer", "Eastern Plaguelands" }, { "Scarlet Priest", "Eastern Plaguelands" } } }, -- Holy Salts
  [13888] = { skill = 275, sources = { { "Fishing", "Azshara" } } }, -- Darkclaw Lobster
  [13889] = { skill = 275, sources = { { "Fishing", "Winterspring" }, { "Fishing", "Alterac Valley" }, { "Fishing", "Eastern Plaguelands" } } }, -- Raw Whitescale Salmon
  [13893] = { skill = 275, sources = { { "Fishing", "Azshara" } } }, -- Large Raw Mightfish
  [18255] = { skill = 275, sources = { { "Warpwood Pod", "Alterac Valley" }, { "Pusillin", "Dire Maul" } } }, -- Runn Tum Tuber
  [20424] = { skill = 285, sources = { { "Dredge Striker", "Silithus" }, { "Dredge Crusher", "Silithus" } } }, -- Sandworm Meat
  [239017] = { skill = 290, sources = {  } }, -- Exquisite Spices
  [8150] = { skill = 300, sources = { { "Rock Elemental", "Badlands" }, { "Lesser Rock Elemental", "Badlands" }, { "Theradrim Shardling", "Maraudon" } } }, -- Deeprock Salt
  [9061] = { skill = 300, sources = { { "Tinkerer Gizlock", "Maraudon" } } }, -- Goblin Rocket Fuel
  [21024] = { skill = 300, sources = {  } }, -- Chimaerok Tenderloin
  [227813] = { skill = 325, sources = {  }, vendor = true }, -- Drinkable Stratholme Holy Water
}
