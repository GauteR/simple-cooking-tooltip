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

- `Found:` one line with where to get the ingredient: up to three mobs to farm with their zones, and/or vendors.
- `Keep for:` a recipe that still needs the ingredient, for example `Keep for: Murloc Fin Soup (130)`. Any recipe that can still give you a skill-up counts (until it turns grey); the nearest one upwards from your Cooking skill is named. No line when no recipe needs it any more.
- Faction aware: zones and recipes only the other faction can use are hidden.
- Pure Lua unit tests; no SavedVariables; minimal memory footprint

## Install

1. Copy the `simple-cooking-tooltip` folder into your Forever AddOns directory, for example:

   `World of Warcraft\_forever_\Interface\AddOns\simple-cooking-tooltip`

2. Restart the client, or log out and back in.
3. Enable **Simple Cooking Tooltip** on the character addon list if it is disabled.
4. Type `/sct` in chat for status.

## Configuration

Edit [`simple-cooking-tooltip/Config.lua`](simple-cooking-tooltip/Config.lua):

| Setting | Default | Meaning |
| --- | --- | --- |
| `ENABLED` | `true` | Master flag. `false` disables slash, tooltips, and Options actions. |
| `SHOW_KEEP_FOR` | `true` | Show the `Keep for:` line. |
| `SHOW_SOURCES` | `true` | Show the `Found:` line. |
| `MAX_SOURCES` | `3` | Sources listed (clamped to 1-3). |
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
lua tests/test_tooltip.lua
```

## License

[MIT](LICENSE) © 2026 GauteR
