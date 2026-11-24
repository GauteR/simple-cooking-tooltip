# Ingredient data

[`Data/Ingredients.lua`](../simple-cooking-tooltip/Data/Ingredients.lua) maps item id to:

- `skill`: lowest Cooking skill at which any recipe using the item is learned (`learnedat`; 0 is stored as 1).
- `zones`: up to three areas, ordered by observed drop/catch count. Areas below 10 % of the top area are dropped.
- `vendor`: item is also sold by vendors; such items list no areas.

## Provenance

Generated once (2026-11-24) from Wowhead Classic pages, not hand-written:

- Cooking recipes and reagents: the Cooking spell list (`learnedat`, `reagents`) - 93 recipes, 93 distinct reagents.
- Areas: each item's "Dropped by", "Pick-pocketed from", "Fished in" and object-contents lists, summed per zone.

Wowhead's data is community-sourced Classic data; Forever-specific items (ids >= 227813) and zones may be incomplete.

## Known gaps

- Items with no area and no vendor (Exquisite Spices, Chimaerok Tenderloin) show only the skill line.
- Zones Wowhead listed under ids `15475` and `16236` were not named and are skipped.
- Drop counts are relative community samples, not drop rates. Verify in-game and correct the file by hand if needed; record findings in the parent `MEMORIES.md`.
- No regeneration script is committed yet; the generator was a throwaway.
