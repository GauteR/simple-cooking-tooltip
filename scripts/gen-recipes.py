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


def zone_faction(zone):
    for faction, owned in ZONES.items():
        if zone in owned:
            return faction
    return None


# How an ingredient is obtained from a source; mobs ("drop") are the default.
HERBS = {"Briarthorn", "Goldthorn", "Mageroyal"}
OBJECTS = {"Giant Clam", "Warpwood Pod"}


def source_kind(name):
    if name == "Fishing":
        return "fish"
    if name in HERBS:
        return "gather"
    if name in OBJECTS:
        return "object"
    return "drop"


def load_sources():
    """itemId -> { "vendor": bool, "sources": [(name, zone)] } from the old ingredient data."""
    path = SRC / "ingredient-zones.lua"
    result = {}
    if not path.exists():
        return result
    for line in path.read_text(encoding="utf8").splitlines():
        m = re.match(r"\s*\[(\d+)\] = \{ skill = \d+, sources = \{(.*?)\}(, vendor = true)? \},", line)
        if not m:
            continue
        sources = re.findall(r'\{ "([^"]+)", "([^"]+)" \}', m.group(2))
        result[int(m.group(1))] = {"vendor": bool(m.group(3)), "sources": sources}
    return result


def load_containers():
    """itemId -> [(name)] of container items (clams, crates) that hold it, most frequent first.

    From crawl-wowhead-items.py; containers below 10 % of the top one are dropped.
    """
    path = SRC / "item-containers.json"
    result = {}
    if not path.exists():
        return result
    for item_id, rows in json.loads(path.read_text(encoding="utf8")).items():
        rows = sorted((r for r in rows if r.get("name") and r.get("count")), key=lambda r: -r["count"])
        if rows:
            top = rows[0]["count"]
            result[int(item_id)] = [r["name"] for r in rows if r["count"] >= top * 0.1]
    return result


def write_sources(reagent_ids, sources):
    lines = []
    containers = load_containers()
    for item_id in sorted(reagent_ids):
        info = sources.get(item_id) or {"sources": [], "vendor": False}
        held_in = containers.get(item_id, [])
        if not (info["sources"] or info["vendor"] or held_in):
            continue
        # Container items (e.g. clams that hold clam meat) are the main source: listed first.
        parts = ["{ name = %s, kind = \"container\" }" % lua_str(name) for name in held_in]
        for name, zone in info["sources"]:
            fields = ["name = %s" % lua_str(name), "zone = %s" % lua_str(zone)]
            faction = zone_faction(zone)
            if faction:
                fields.append('faction = "%s"' % faction)
            kind = source_kind(name)
            if kind != "drop":
                fields.append('kind = "%s"' % kind)
            parts.append("{ %s }" % ", ".join(fields))
        vendor = ", vendor = true" if info["vendor"] else ""
        lines.append("  [%d] = { sources = { %s }%s }," % (item_id, ", ".join(parts), vendor))
    header = (
        "-- Where to get each cooking ingredient (generated by scripts/gen-recipes.py; see docs/DATA.md).\n"
        "-- [itemId] = { sources = { { name, zone, faction?, kind? }, ... } (most drops first),\n"
        "--              vendor = true when sold by vendors }\n"
        "-- kind: omitted = dropped by a mob; \"fish\" (name is Fishing), \"gather\" (herb), \"object\" (world object),\n"
        "--       \"container\" (an item you open, e.g. a clam; no zone).\n"
        "-- faction is set when the zone belongs to one faction only; such sources are hidden from the other.\n"
        "SimpleCookingTooltip = SimpleCookingTooltip or {}\n"
        "SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}\n\n"
        "SimpleCookingTooltip.Data.SOURCES = {\n"
    )
    (OUT.parent / "Sources.lua").write_text(header + "\n".join(lines) + "\n}\n", encoding="utf8", newline="\n")
    return len(lines)


def load_difficulty():
    """recipe name -> green level, from saved Booty Bay Broker pages (rows carry an aria-label Difficulty)."""
    result = {}
    for path in sorted(SRC.glob("WoW Forever Professions Calculator*.html")):
        html = path.read_text(encoding="utf8")
        for name, green in re.findall(r'abbr="([^"]+)".*?aria-label="Difficulty: Orange \d+, Yellow \d+, Green (\d+), Grey \d+"', html):
            result[name] = int(green)
    return result


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
    difficulty = load_difficulty()
    forever = json.loads((SRC / "bbb-forever-reagents.json").read_text(encoding="utf8"))
    crawl_path = SRC / "classic-sources.json"
    crawl = json.loads(crawl_path.read_text()) if crawl_path.exists() else {}

    ingredient_factions = load_ingredient_factions()
    out, problems, inferred, estimated = [], [], [], []
    for r in sorted(bbb, key=lambda r: (r["skill"], r["name"])):  # sorted by yellow; order is cosmetic
        if r["spell"] in wowhead:
            reagents = [rid for rid, _qty in wowhead[r["spell"]]["reagents"]]
        elif str(r["bbb"]) in forever:
            reagents = [m[0] for m in forever[str(r["bbb"])]["materials"]]
        else:
            problems.append("no reagents: %s (%d)" % (r["name"], r["spell"]))
            continue
        # `skill` = yellow (optimal) level: Booty Bay Broker's skill_required. `green` = level at which the
        # recipe turns green (skill-ups become rare; only orange/yellow count). Classic: Wowhead colors.
        # Forever-only: the saved BBB page where present (difficulty), otherwise an estimate of
        # yellow + 10 (Classic uses +20, the Forever-only recipes seen so far +0..+20, median +7).
        yellow = r["skill"]
        if r["spell"] in wowhead:
            green = wowhead[r["spell"]]["colors"][2]
        elif r["name"] in difficulty:
            green = difficulty[r["name"]]
        else:
            green = yellow + 10
            estimated.append(r["name"])
        r["green"] = green
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
        parts = ["name = %s" % lua_str(r["name"]), "skill = %d" % r["skill"], "green = %d" % r["green"],
                 'learn = "%s"' % learn]
        if faction:
            parts.append('faction = "%s"' % faction)
        parts.append("reagents = { %s }" % ", ".join(str(i) for i in reagents))
        out.append("  [%d] = { %s }," % (r["spell"], ", ".join(parts)))

    header = (
        "-- Cooking recipes and reagents (generated by scripts/gen-recipes.py; see docs/DATA.md).\n"
        "-- [spellId] = { name, skill = optimal (yellow) Cooking level,\n"
        "--   green = level at which it turns green (only orange/yellow count),\n"
        "--   learn = \"trainer\" (trainer or learned with the skill) | \"item\" (taught by a recipe item),\n"
        "--   faction = \"Alliance\" | \"Horde\" (omitted = both), reagents = { itemId, ... } }\n"
        "SimpleCookingTooltip = SimpleCookingTooltip or {}\n"
        "SimpleCookingTooltip.Data = SimpleCookingTooltip.Data or {}\n\n"
        "SimpleCookingTooltip.Data.RECIPES = {\n"
    )
    OUT.write_text(header + "\n".join(out) + "\n}\n", encoding="utf8", newline="\n")
    print("wrote %d recipes to %s" % (len(out), OUT.relative_to(ROOT)))
    reagent_ids = {i for r in bbb for i in (
        [x[0] for x in wowhead[r["spell"]]["reagents"]] if r["spell"] in wowhead
        else [m[0] for m in forever.get(str(r["bbb"]), {}).get("materials", [])])}
    written = write_sources(reagent_ids, load_sources())
    print("wrote sources for %d of %d reagents" % (written, len(reagent_ids)))
    print("green level estimated (yellow + 10): %d" % len(estimated))
    for e in estimated:
        print("  ", e)
    print("faction inferred from ingredient zones: %d" % len(inferred))
    for i in inferred:
        print("  ", i)
    for p in problems:
        print("WARN", p, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
