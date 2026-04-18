# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript (statisch getypeerd — altijd type-annotaties gebruiken)
- **Rendering**: Mobile renderer (Forward+) — geoptimaliseerd voor portrait
- **Physics**: Jolt (Godot 4.6 standaard) — minimaal gebruikt, grid is logisch niet fysiek

## Input & Platform

<!-- Written by /setup-engine. Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: Mobile (iOS + Android), Desktop (PC/Mac secundair)
- **Input Methods**: Touch (primair), Keyboard/Mouse (secundair voor desktop)
- **Primary Input**: Touch — tap-selecteer + tap-plaatsen, swipe voor beweging
- **Gamepad Support**: None
- **Touch Support**: Full — éénhandige bediening in portrait verplicht
- **Platform Notes**: Geen horizontale scroll tijdens gevecht. Alle UI zichtbaar in één scherm (portrait 9:19.5). Minimale tap-targets 44×44dp.

## Naming Conventions

- **Classes**: PascalCase (`CombatGrid`, `EmotionObject`, `TurnSystem`)
- **Variables**: snake_case (`aura_radius`, `emotion_type`, `echo_tokens`)
- **Signals**: snake_case werkwoord-voltooid (`emotion_placed`, `resonance_triggered`, `turn_ended`)
- **Files**: snake_case (`combat_grid.gd`, `emotion_object.gd`)
- **Scenes**: PascalCase (`CombatScene.tscn`, `EmotionCard.tscn`)
- **Constants**: SCREAMING_SNAKE_CASE (`GRID_WIDTH`, `COLLAPSE_THRESHOLD`)

## Performance Budgets

- **Target Framerate**: 60 FPS (mobile), 120 FPS (desktop)
- **Frame Budget**: 16.6ms (mobile 60fps)
- **Draw Calls**: <100 per frame (grid + emotie-objecten + UI)
- **Memory Ceiling**: 512 MB (mid-range Android target)

## Testing

- **Framework**: GdUnit4
- **Minimum Coverage**: 80% voor core systemen (CombatGrid, EmotionObject, TurnSystem, ResonanceSystem)
- **Required Tests**: Aura-berekeningen, Resonantie-detectie, deck-mutatieformules, vijand-attractie-scores

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — add as dependencies are approved]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

<!-- Written by /setup-engine when engine is configured. -->
<!-- Read by /code-review, /architecture-decision, /architecture-review, and team skills -->
<!-- to know which specialist to spawn for engine-specific validation. -->

- **Primary**: `godot-specialist`
- **Language/Code Specialist**: `godot-gdscript-specialist`
- **Shader Specialist**: `godot-shader-specialist`
- **UI Specialist**: `godot-gdscript-specialist` (Control nodes / CanvasLayer)
- **Additional Specialists**: geen — GDExtension niet nodig voor dit project
- **Routing Notes**: Grid-logica en emotie-systemen altijd via `godot-gdscript-specialist`. Visuele aura-effecten via `godot-shader-specialist`.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->
<!-- If a row says [TO BE CONFIGURED], fall back to Primary for that file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (primary language) | `godot-gdscript-specialist` |
| Shader / material files | `godot-shader-specialist` |
| UI / screen files | `godot-gdscript-specialist` |
| Scene / prefab / level files | `godot-specialist` |
| Native extension / plugin files | N/A — niet gebruikt |
| General architecture review | `godot-specialist` |
