# Simple Cooking Tooltip

Tooltip helper for **World of Warcraft: Forever**.

Hover a cooking ingredient to see up to five recipes that use it, limited to the ones your faction can learn, easiest to get first.

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/sct` |
| Language | English (UI and docs) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Up to five recipes per ingredient, each with the Cooking skill to learn it.
- Faction aware: recipes only the other faction can learn are hidden. Easiest first: trainers, then recipe items, then lowest skill.
- The lowest skill at which you can use the ingredient, in case you need to know whether to save it for later.
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
| `SHOW_RECIPES` | `true` | Show the recipe lines. |
| `SHOW_SKILL` | `true` | Show the `Cooking skill needed for recipes:` line. |
| `MAX_RECIPES` | `5` | Recipes listed (clamped to 1-5). |
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
