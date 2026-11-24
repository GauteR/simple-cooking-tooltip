# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Tooltips list up to five Cooking recipes that use the ingredient, with the skill to learn each.
- Faction filtering: recipes only the other faction can learn are hidden. Order: trainer recipes, then recipe items, then lowest skill.
- Recipe data for all 132 Forever Cooking recipes (`Data/Recipes.lua`), with generator `scripts/gen-recipes.py`.

### Changed
- Skill line is now the lowest skill among the recipes your faction can learn.
- Config: `SHOW_SOURCES` and `MAX_SOURCES` replaced by `SHOW_RECIPES` and `MAX_RECIPES` (default 5).

### Removed
- The `Found:` mob/area lines and the "Sold by vendors" line, and `Data/Ingredients.lua`.

### Fixed
- `scripts/publish-local.*` ran tests that do not exist in this repository.

## [0.1.0] - 2026-11-24

### Changed

- Add Simple Cooking Tooltip addon
