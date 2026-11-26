#!/usr/bin/env python3
"""Fetch Wowhead Classic item pages and keep the "contained in item" list (e.g. clams that hold clam meat).

Usage: python -I scripts/crawl-wowhead-items.py 5503 5504 ...
Writes data-src/item-containers.json  { itemId: [ { id, name, count, outof } ] }  (resumable)
Polite: 2.5 s between requests, stops on the first non-200 or empty body.
"""
import json, pathlib, sys, time, urllib.error, urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "data-src" / "item-containers.json"
DELAY = 2.5


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


def main(ids):
    done = json.loads(OUT.read_text()) if OUT.exists() else {}
    for item_id in ids:
        if str(item_id) in done:
            continue
        req = urllib.request.Request("https://www.wowhead.com/classic/item=%s" % item_id, headers={"User-Agent": "Mozilla/5.0"})
        try:
            html = urllib.request.urlopen(req, timeout=30).read().decode("utf8")
        except urllib.error.HTTPError as err:
            print("HTTP %s on %s - stopping" % (err.code, item_id), file=sys.stderr)
            return 1
        if "Listview" not in html:
            print("Empty/unexpected body on %s - stopping" % item_id, file=sys.stderr)
            return 1
        rows = listview(html, "contained-in-item")
        done[str(item_id)] = [
            {"id": r["id"], "name": r.get("name"), "count": r.get("count"), "outof": r.get("outof")} for r in rows
        ]
        OUT.write_text(json.dumps(done, indent=1))
        print(item_id, len(rows), flush=True)
        time.sleep(DELAY)
    return 0


if __name__ == "__main__":
    sys.exit(main([int(a) for a in sys.argv[1:]]))
