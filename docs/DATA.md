# Ingredient data

[`Data/Ingredients.lua`](../simple-cooking-tooltip/Data/Ingredients.lua) maps item id to:

- `skill`: lowest Cooking skill at which any recipe using the item is learned (`learnedat`; 0 is stored as 1). This is the earliest point the item can be used, not a list of all recipe levels.
- `sources`: up to three `{ name, area }` pairs, ordered by observed drop/catch count. `name` is the mob (or object) name, or `Fishing`; `area` is the zone where that source was seen most. Sources below 10 % of the top source are dropped.
- `vendor`: item is sold by vendors; such items list no sources.

## Provenance

Generated once (2026-11-24) from Wowhead Classic pages, not hand-written:

- Cooking recipes and reagents: the Cooking spell list (`learnedat`, `reagents`) - 93 recipes, 93 distinct reagents.
- Sources: each item's "Dropped by", "Pick-pocketed from", "Fished in" and object-contents lists. Same-name mobs are summed; fishing is listed per zone.

Wowhead's data is community-sourced Classic data; Forever-specific items (ids >= 227813) and zones may be incomplete.

## Known gaps

- Items with no source and no vendor (Exquisite Spices, Chimaerok Tenderloin) show only the skill line.
- Zones Wowhead listed under ids `15475` and `16236` were not named; a mob seen only there lists the name without an area.
- Drop counts are relative community samples, not drop rates. Verify in-game and correct the file by hand if needed; record findings in the parent `MEMORIES.md`.
- No regeneration script is committed yet; the generator was a throwaway.
