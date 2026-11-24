# Simple Cooking Tooltip

Tooltip helper for **World of Warcraft: Forever**.

Hover an ingredient to see where to farm it and which skill level the ingredient's recipes are used, in case you want to save it for that.

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/sct` |
| Language | English (UI and docs) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Up to three main mob types, and their areas, per ingredient, most drops first.
- The skill required to use an ingredient for any recipe, in case you need to know whether to save it for later.
- Vendor-sold ingredients marked as such.
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
| `SHOW_SOURCES` | `true` | Show the `Found:` lines (mob type and area). |
| `SHOW_SKILL` | `true` | Show the `Cooking skill needed for recipes:` line. |
| `MAX_SOURCES` | `3` | Sources listed (clamped to 1-3). |
| `SLASH_COMMAND` | `"/sct"` | Documented slash command. |

After changing config or data files, reload with `/reload`.

## Documentation

| Doc | Contents |
| --- | --- |
| [`docs/DATA.md`](docs/DATA.md) | Where the ingredient data comes from and its limits |
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
