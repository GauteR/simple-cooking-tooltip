#!/usr/bin/env python3
"""Crawl Wowhead Classic spell pages for Cooking recipes: who teaches each recipe.

Reads  data-src/wowhead-classic-cooking.html  (saved list page, see docs/DATA.md)
Writes data-src/classic-sources.json
Polite: >= 2.5 s between requests, stops on the first 403/429. Resumable.
"""
import json, re, sys, time, urllib.request, urllib.error, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "data-src"
OUT = SRC / "classic-sources.json"
DELAY = 2.5
UA = "Mozilla/5.0"  # Wowhead serves an empty 200 body to unknown agents


def load_spells():
    txt = (SRC / "wowhead-classic-cooking.html").read_text(encoding="utf8")
    txt = txt.split("var listviewspells = ")[1].split("];")[0] + "]"
    txt = re.sub(r',(quality|popularity):(-?\d+)', r',"\1":\2', txt)
    return [e for e in json.loads(txt) if "reagents" in e]


def listview(html, lv_id):
    i = html.find("id: '%s'" % lv_id)
    if i < 0:
        return []
    j = html.find("data: [", i)
    if j < 0:
        return []
    try:
        data, _ = json.JSONDecoder().raw_decode(html[j + 6:])
    except ValueError:
        return []
    return data


def main():
    done = json.loads(OUT.read_text()) if OUT.exists() else {}
    for e in load_spells():
        sid = str(e["id"])
        if sid in done:
            continue
        req = urllib.request.Request("https://www.wowhead.com/classic/spell=%s" % sid, headers={"User-Agent": UA})
        try:
            html = urllib.request.urlopen(req, timeout=30).read().decode("utf8")
        except urllib.error.HTTPError as err:
            print("HTTP %s on %s - stopping" % (err.code, sid), file=sys.stderr)
            break
        if "taught-by" not in html and "Listview" not in html:
            print("Empty/unexpected body on %s - stopping" % sid, file=sys.stderr)
            break
        npcs = [{"id": n["id"], "name": n["name"], "react": n.get("react")} for n in listview(html, "taught-by-npc")]
        items = [{"id": n["id"], "name": n.get("name"), "side": n.get("side")} for n in listview(html, "taught-by-item")]
        quests = [{"id": n["id"], "name": n.get("name"), "side": n.get("side")} for n in listview(html, "taught-by-quest")]
        done[sid] = {"name": e["name"], "npcs": npcs, "items": items, "quests": quests}
        OUT.write_text(json.dumps(done, indent=1))
        print(sid, e["name"], len(npcs), len(items), len(quests), flush=True)
        time.sleep(DELAY)


if __name__ == "__main__":
    main()
