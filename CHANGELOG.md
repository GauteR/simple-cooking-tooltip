# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Tooltips show a `Found:` line (mobs and zones, or vendors) and a `Keep for:` line with the nearest Cooking recipe upwards from your skill that uses the ingredient (none when no higher recipe is left).
- Faction filtering: recipes and source zones only the other faction can use are hidden.
- Recipe data for all 132 Forever Cooking recipes (`Data/Recipes.lua`) and ingredient sources (`Data/Sources.lua`), with generator `scripts/gen-recipes.py`.

### Changed
- Config: `SHOW_KEEP_FOR` added; `SHOW_SKILL` removed.
- Recipe skill is the level the recipe is learned at (orange), not the optimal (yellow) level.

### Removed
- The "Cooking skill needed for recipes" line (redundant with the recipe list) and `Data/Ingredients.lua` (split into `Recipes.lua` and `Sources.lua`).

### Fixed
- `scripts/publish-local.*` ran tests that do not exist in this repository.

## [0.1.0] - 2026-11-24

### Changed

- Add Simple Cooking Tooltip addon
