# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Tooltips show a `Found:` line (mobs and zones, or vendors) and a `Recipes:` line with up to five Cooking recipes that use the ingredient, sorted by skill. Green = known, red = not known; recipes below your Cooking skill are hidden.
- Faction filtering: recipes and source zones only the other faction can use are hidden. Which five are kept: trainer recipes first, then recipe items, then lowest skill.
- Recipe data for all 132 Forever Cooking recipes (`Data/Recipes.lua`) and ingredient sources (`Data/Sources.lua`), with generator `scripts/gen-recipes.py`.

### Changed
- Config: `SHOW_RECIPES` and `MAX_RECIPES` (default 5) added; `SHOW_SKILL` removed.

### Removed
- The "Cooking skill needed for recipes" line (redundant with the recipe list) and `Data/Ingredients.lua` (split into `Recipes.lua` and `Sources.lua`).

### Fixed
- `scripts/publish-local.*` ran tests that do not exist in this repository.

## [0.1.0] - 2026-11-24

### Changed

- Add Simple Cooking Tooltip addon
