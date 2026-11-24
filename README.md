# Simple Cooking Tooltip

Tooltip helper for **World of Warcraft: Forever** that shows where to find a cooking ingredient and which Cooking skill its recipes need.

Hover an ingredient to see up to three main areas, plus the Cooking skill level at which a recipe using it is learned (not the recipe name).

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/sct` |
| Language | English (UI and docs) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Ingredient tooltips: `Cooking recipe skill: N` (lowest skill at which a recipe using the item is learned)
- Up to three main areas (`Found in: ...`), most drops first
- Vendor-sold staples (spices, water, milk) show `Sold by vendors`
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
| `SHOW_AREAS` | `true` | Show the `Found in:` line. |
| `SHOW_SKILL` | `true` | Show the `Cooking recipe skill:` line. |
| `MAX_AREAS` | `3` | Areas listed (clamped to 1-3). |
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
