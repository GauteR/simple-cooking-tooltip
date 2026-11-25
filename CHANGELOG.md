# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Tooltips show source lines worded by how you get it (`Dropped by:`, `Fished:`, `Gathered:`, `Looted from:`, `Sold by vendors`) and a `Keep for:` line naming the nearest Cooking recipe that still needs the ingredient and is still orange or yellow for you (none when every recipe using it has turned green).
- Faction filtering: recipes and source zones only the other faction can use are hidden.
- Recipe data for all 132 Forever Cooking recipes (`Data/Recipes.lua`) and ingredient sources (`Data/Sources.lua`), with generator `scripts/gen-recipes.py`.

### Changed
- Config: `SHOW_KEEP_FOR` added; `SHOW_SKILL` removed.

### Removed
- The "Cooking skill needed for recipes" line (redundant with the recipe list) and `Data/Ingredients.lua` (split into `Recipes.lua` and `Sources.lua`).

### Fixed
- Cooking skill is read through the modern profession API (`GetProfessions`, `C_TradeSkillUI`) before the old skill list, so recipes you have outgrown are hidden. `/sct` prints the detected faction and skill.
- `scripts/publish-local.*` ran tests that do not exist in this repository.

## [0.1.0] - 2026-11-24

### Changed

- Add Simple Cooking Tooltip addon
