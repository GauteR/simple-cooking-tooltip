# Simple Cooking Tooltip

Tooltip helper for **World of Warcraft: Forever**.

Hover a cooking ingredient to see where to get it (mobs to farm, or vendors) and which recipe to keep it for.

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/sct` |
| Language | English (UI and docs) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Where to get the ingredient, worded by how you get it, up to three sources in total: `Dropped by: Prowler (Elwynn Forest)`, `Fished: Darkshore, Elwynn Forest`, `Gathered: ...`, `Looted from: ...`, `Sold by vendors`. Zone names are coloured by level against your character: red = too high, yellow = on level, green = a little below, gray = far below.
- `Keep for:` a recipe that still needs the ingredient, for example `Keep for: Murloc Fin Soup (130)`. A recipe counts while it is still orange or yellow for you (green recipes rarely give skill-ups, so they do not count); the nearest one upwards from your Cooking skill is named. No line when no recipe needs it any more.
- Faction aware: zones and recipes only the other faction can use are hidden.
- Pure Lua unit tests; no SavedVariables; minimal memory footprint

## Install

1. Copy the `simple-cooking-tooltip` folder into your Forever AddOns directory, for example:

   `World of Warcraft\_forever_\Interface\AddOns\simple-cooking-tooltip`

2. Restart the client, or log out and back in.
3. Enable **Simple Cooking Tooltip** on the character addon list if it is disabled.
4. Type `/sct` in chat for status. It also prints the faction and Cooking skill the addon detected; if the skill says `not detected`, recipes are not hidden by skill.

## Configuration

Edit [`simple-cooking-tooltip/Config.lua`](simple-cooking-tooltip/Config.lua):

| Setting | Default | Meaning |
| --- | --- | --- |
| `ENABLED` | `true` | Master flag. `false` disables slash, tooltips, and Options actions. |
| `SHOW_KEEP_FOR` | `true` | Show the `Keep for:` line. |
| `SHOW_SOURCES` | `true` | Show the source lines (`Dropped by:`, `Fished:`, ...). |
| `MAX_SOURCES` | `3` | Sources listed (clamped to 1-3). |
| `LABEL_COLOR` | `"ffd100"` | Hex colour of the labels (`Dropped by:`, `Keep for:`, ...); the values stay white. |
| `COLOR_ZONES` | `true` | Colour zone names by level against your character. |
| `ZONE_YELLOW_RANGE` | `2` | Zones within this many levels (above or below) are yellow; further above is red. |
| `ZONE_GRAY_BELOW` | `8` | Zones this many levels or more below you are gray; in between is green. |
| `SLASH_COMMAND` | `"/sct"` | Documented slash command. |

After changing config or data files, reload with `/reload`.

## Documentation

| Doc | Contents |
| --- | --- |
| [`docs/DATA.md`](docs/DATA.md) | Where the recipe data comes from and its limits |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Local packager / GitHub Release (`gh`) / CurseForge |
| [`CHANGELOG.md`](CHANGELOG.md) | Keep a Changelog |
| [`docs/CURSEFORGE.md`](docs/CURSEFORGE.md) | User-facing CurseForge description |

## Local Forever install (dev)

```bash
./scripts/publish-local.sh
```

```powershell
.\scripts\publish-local.ps1
```

Then `/reload` in-game.

## Tests

```bash
lua tests/test_ingredients.lua
lua tests/test_player.lua
lua tests/test_tooltip.lua
```

## License

[MIT](LICENSE) © 2026 GauteR
