#!/usr/bin/env python3
"""Generate simple-cooking-tooltip/Data/Recipes.lua from saved source files in data-src/.

Inputs (all git-ignored, see docs/DATA.md):
  bbb-cooking-recipes.psv       Booty Bay Broker (Forever) recipe list: spell id, name, skill, trainer/item
  wowhead-classic-cooking.html  Wowhead Classic list page: reagents for recipes that exist in Classic
  bbb-forever-reagents.json     Booty Bay Broker per-recipe materials for Forever-only recipes
  classic-sources.json          optional, from crawl-wowhead-sources.py: faction of recipe items/quests
  ingredient-zones.lua          optional, old Data/Ingredients.lua (git show): zones where ingredients are found

Run: python -I scripts/gen-recipes.py
"""
import json, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "data-src"
OUT = ROOT / "simple-cooking-tooltip" / "Data" / "Recipes.lua"
SIDE = {1: "Alliance", 2: "Horde"}

# Zones only one faction normally visits. Contested/neutral zones (The Barrens, Duskwood,
# Hillsbrad, Stonetalon, instances, ...) are deliberately left out so they never bind a faction.
ZONES = {
    "Alliance": {"Elwynn Forest", "Dun Morogh", "Westfall", "Loch Modan", "Redridge Mountains", "Darkshore",
                 "Teldrassil", "Stormwind City", "Ironforge", "Darnassus", "Wetlands"},
    "Horde": {"Durotar", "Mulgore", "Tirisfal Glades", "Silverpine Forest", "Orgrimmar", "Thunder Bluff",
              "Undercity"},
}


# Holiday recipes are for everyone whatever their ingredients' zones say.
NEVER_INFER = {21143, 21144}  # Gingerbread Cookie, Egg Nog


def load_ingredient_factions():
    """itemId -> "Alliance"/"Horde" when every known source zone belongs to that faction."""
    path = SRC / "ingredient-zones.lua"
    result = {}
    if not path.exists():
        return result
    for line in path.read_text(encoding="utf8").splitlines():
        m = re.match(r"\s*\[(\d+)\] = \{ skill = \d+, sources = \{(.*?)\}(, vendor = true)? \},", line)
        if not m:
            continue
        zones = {z for _name, z in re.findall(r'\{ "([^"]+)", "([^"]+)" \}', m.group(2))}
        for faction, owned in ZONES.items():
            if zones and zones <= owned:
                result[int(m.group(1))] = faction
    return result


def faction_from_reagents(reagents, ingredient_factions):
    """Recipe is faction-bound when it needs a faction-only ingredient and none for the other faction."""
    found = {ingredient_factions[i] for i in reagents if i in ingredient_factions}
    return found.pop() if len(found) == 1 else None


def load_bbb():
    rows = []
    for line in (SRC / "bbb-cooking-recipes.psv").read_text(encoding="utf8").splitlines():
        if not line or line.startswith("#"):
            continue
        bbb_id, spell, name, skill, result, qty, source, teach = line.split("|")
        rows.append({"bbb": int(bbb_id), "spell": int(spell), "name": name, "skill": int(skill),
                     "source": source, "teach": teach})
    return rows


def load_wowhead():
    txt = (SRC / "wowhead-classic-cooking.html").read_text(encoding="utf8")
    txt = txt.split("var listviewspells = ")[1].split("];")[0] + "]"
    txt = re.sub(r',(quality|popularity):(-?\d+)', r',"\1":\2', txt)
    return {e["id"]: e for e in json.loads(txt) if "reagents" in e}


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    bbb = load_bbb()
    wowhead = load_wowhead()
    forever = json.loads((SRC / "bbb-forever-reagents.json").read_text(encoding="utf8"))
    crawl_path = SRC / "classic-sources.json"
    crawl = json.loads(crawl_path.read_text()) if crawl_path.exists() else {}

    ingredient_factions = load_ingredient_factions()
    out, problems, inferred = [], [], []
    for r in sorted(bbb, key=lambda r: (r["skill"], r["name"])):
        if r["spell"] in wowhead:
            reagents = [rid for rid, _qty in wowhead[r["spell"]]["reagents"]]
        elif str(r["bbb"]) in forever:
            reagents = [m[0] for m in forever[str(r["bbb"])]["materials"]]
        else:
            problems.append("no reagents: %s (%d)" % (r["name"], r["spell"]))
            continue
        faction = None
        info = crawl.get(str(r["spell"]))
        if info:
            sides = {SIDE[x["side"]] for x in info["items"] + info["quests"] if x.get("side") in SIDE}
            if len(sides) == 1:
                faction = sides.pop()
        # Trainer recipes are learnable by both factions, so zones of their ingredients say nothing.
        if faction is None and r["source"] == "D" and r["spell"] not in NEVER_INFER:
            faction = faction_from_reagents(reagents, ingredient_factions)
            if faction:
                inferred.append("%s -> %s" % (r["name"], faction))
        learn = "trainer" if r["source"] == "T" else "item"
        parts = ["name = %s" % lua_str(r["name"]), "skill = %d" % r["skill"], 'learn = "%s"' % learn]
        if faction:
            parts.append('faction = "%s"' % faction)
        parts.append("reagents = { %s }" % ", ".join(str(i) for i in reagents))
        out.append("  [%d] = { %s }," % (r["spell"], ", ".join(parts)))

    header = (
        "-- Cooking recipes and reagents (generated by scripts/gen-recipes.py; see docs/DATA.md).\n"
        "-- [spellId] = { name, skill = Cooking skill to learn it,\n"
        "--   learn = \"trainer\" (trainer or learned with the skill) | \"item\" (taught by a recipe item),\n"
        "--   faction = \"Alliance\" | \"Horde\" (omitted = both), reagents = { itemId, ... } }\n"
        "SimpleCookingTooltip = SimpleCookingTooltip or {}\n"
        "SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}\n\n"
        "SimpleCookingTooltip.Data.RECIPES = {\n"
    )
    OUT.write_text(header + "\n".join(out) + "\n}\n", encoding="utf8", newline="\n")
    print("wrote %d recipes to %s" % (len(out), OUT.relative_to(ROOT)))
    print("faction inferred from ingredient zones: %d" % len(inferred))
    for i in inferred:
        print("  ", i)
    for p in problems:
        print("WARN", p, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
