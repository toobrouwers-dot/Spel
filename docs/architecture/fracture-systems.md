# FRACTURE — Systeem Architectuur

**Versie:** 0.1  
**Datum:** 2026-04-18  
**Engine:** Godot 4.6 / GDScript  
**GDD Referentie:** `design/gdd/fracture-core.md`

---

## Overzicht

FRACTURE bestaat uit 8 core systemen. Ze communiceren via Godot signals — geen directe referenties tussen systemen waar vermijdbaar.

```
┌─────────────────────────────────────────────────┐
│                  TurnSystem                     │  ← Orkestrator
└──┬──────────┬──────────┬──────────┬─────────────┘
   │          │          │          │
   ▼          ▼          ▼          ▼
CombatGrid  HandMgr  EnemyAI   DeckMutation
   │
   ├── EmotionObject (per instantie)
   ├── ResonanceSystem
   └── AuraCalculator
```

---

## Systemen

### 1. CombatGrid
**Pad:** `src/core/grid/combat_grid.gd`  
**Verantwoordelijkheid:** Beheert de 5×9 cel-matrix, posities van entiteiten en Emotie-objecten, en delegeert aura-herberekening.

**Signals:**
- `emotion_placed(obj: EmotionObject, cell: GridCell)`
- `emotion_collapsed(obj: EmotionObject, power: float)`
- `aura_recalculated()`
- `resonance_triggered(group: Array[EmotionObject])`

**Kernmethoden:**
```gdscript
func place_emotion(type: EmotionObject.Type, cell: GridCell) -> void
func get_cells_in_radius(origin: GridCell, radius: int) -> Array[GridCell]
func get_entity_at(cell: GridCell) -> CombatEntity
func tick_all_objects() -> void  # aangeroepen door TurnSystem
```

**Regels:**
- Één Emotie-object per cel maximum
- Entiteiten en Emotie-objecten delen een cel — geen conflict
- Aura's worden altijd volledig herberekend na elke plaatsing of beweging (niet incrementeel)

---

### 2. EmotionObject
**Pad:** `src/core/emotions/emotion_object.gd`  
**Verantwoordelijkheid:** Levenscyclus van één geplaatste emotie (Actief → Vervaagd → Collapse).

**States:**
```
ACTIVE (beurt 0-1)  →  FADED (beurt 2-3)  →  COLLAPSE (beurt 4)  →  GONE
```

**Data:**
```gdscript
var type: EmotionType
var cell: GridCell
var age: int = 0
var aura_radius: int          # afgeleid van type + mutatie-niveau
var echo_tokens: int = 0      # toegevoegd door Hoop-kaart
var mutation_level: int = 0   # 0/1/2, bepaalt effectsterkte
```

**Regels:**
- `tick()` wordt één keer per beurt aangeroepen door `CombatGrid.tick_all_objects()`
- Bij Collapse: `collapse_power = base × (1 + echo_tokens)`, daarna zelf uit grid verwijderen
- Paniek-object heeft geen Fade/Collapse — verwijderd alleen via externe trigger

---

### 3. EmotionLibrary
**Pad:** `src/core/emotions/emotion_library.gd`  
**Verantwoordelijkheid:** Statische definitie van alle aura-effecten, Collapse-effecten en mutatie-drempels per emotie-type.

**Structuur:**
```gdscript
# Puur statische data — geen state, geen signals
static func get_aura_effect(type: EmotionType, level: int, target: CombatEntity) -> AuraEffect
static func get_collapse_power(type: EmotionType, level: int) -> float
static func get_aura_radius(type: EmotionType, level: int) -> int
```

**Regels:**
- Geen game-state in deze klasse — alleen lookup-tabellen
- Alle balanceerbare waarden komen uit `assets/data/emotion_config.tres` (Resource)
- `EmotionLibrary` laadt de config bij `_ready()`, daarna alleen lees-acties

---

### 4. AuraCalculator
**Pad:** `src/core/grid/aura_calculator.gd`  
**Verantwoordelijkheid:** Berekent per cel welke aura's actief zijn en wat het gecombineerde effect is op entiteiten.

**Kernmethode:**
```gdscript
static func recalculate(grid: CombatGrid) -> Dictionary:
    # Returns: { cell_id -> Array[AuraEffect] }
```

**Regels:**
- Puur functioneel — geen state, altijd zelfde output bij zelfde input
- Leegte-object trekt andere aura's naar zich toe: hun effecten worden omgeleid naar de Leegte-cel
- Verwondering verhoogt effectsterkte van kaarten gespeeld in zijn radius die beurt (niet via AuraCalculator maar via TurnSystem)

---

### 5. ResonanceSystem
**Pad:** `src/core/grid/resonance_system.gd`  
**Verantwoordelijkheid:** Detecteert aaneengesloten groepen van 3+ identieke Emotie-objecten en triggert uitbarstingen.

**Kernmethode:**
```gdscript
static func find_resonance_groups(grid: CombatGrid) -> Array[Array]:
    # Returns: groepen van 3+ aaneengesloten gelijke EmotionObjects
```

**Regels:**
- Gecontroleerd na élke `place_emotion()` aanroep
- Aaneengesloten = horizontaal, verticaal of diagonaal
- Verwondering binnen radius 2 van het groepsmiddelpunt: multiplier ×2 + speler teleporteert
- Meerdere simultane Resonanties in één beurt zijn mogelijk — elk apart afgehandeld

---

### 6. HandManager
**Pad:** `src/core/hand/hand_manager.gd`  
**Verantwoordelijkheid:** Beheert de spelerhand: draw, overflow (Fragmentatie) en Paniek-interacties.

**Signals:**
- `card_drawn(card: EmotionCard)`
- `card_fragmented(card: EmotionCard)`
- `hand_changed(hand: Array[EmotionCard])`

**Regels:**
- Handlimiet: `HAND_LIMIT = 6` (tuning knob)
- Overflow: oudste kaart wordt Gefragmenteerd (onmiddellijk effect, halve kracht)
- Paniek pakt willekeurige kaart rechtstreeks uit de hand — HandManager levert deze via `get_random_card()`
- Draw-volgorde: shuffle bij deck-leegte (standaard roguelite recycle)

---

### 7. TurnSystem
**Pad:** `src/core/turn/turn_system.gd`  
**Verantwoordelijkheid:** Orkestrator van de beurt-lus. Coördineert spelervolgorde, vijandbeweging en Paniek.

**Beurt-volgorde:**
```
1. Speler speelt 1 kaart  →  CombatGrid.place_emotion()
2. Speler beweegt 1 stap  →  CombatGrid.move_entity()
3. Paniek-check           →  indien actief: HandManager.get_random_card() → extra place_emotion()
4. AuraCalculator.recalculate()
5. Aura-effecten toepassen op alle entiteiten
6. CombatGrid.tick_all_objects()  (age +1, Collapse triggers)
7. ResonanceSystem.find_resonance_groups()
8. EnemyAI.execute_all()
9. HandManager.draw_card()
10. Gevecht-eindcheck
```

**Regels:**
- TurnSystem kent geen spellogica — delegeert alles naar de juiste subsystemen
- Signals van subsystemen worden hier samengevoegd voor UI-events

---

### 8. EnemyAI
**Pad:** `src/core/ai/enemy_ai.gd`  
**Verantwoordelijkheid:** Berekent per vijand de optimale cel op basis van emotie-attractie en voert aanvallen uit.

**Kernmethode:**
```gdscript
func calculate_move(enemy: EnemyEntity, aura_map: Dictionary) -> GridCell
```

**Data per vijandtype** (in `assets/data/enemy_config.tres`):
```gdscript
# emotion_responses: Dictionary[EmotionType, int]
# Waarden: -2 (sterk afgestoten) tot +2 (sterk aangetrokken)
```

**Regels:**
- Vijanden bewegen naar de naburige cel met hoogste attractie-score
- Bij gelijke score: willekeurig kiezen
- Aanval alleen als vijand naast speler staat (Manhattan-afstand = 1)

---

### 9. DeckMutationSystem
**Pad:** `src/core/deck/deck_mutation_system.gd`  
**Verantwoordelijkheid:** Houdt run-statistieken bij en past evolutie/degradatie toe na elk gevecht-segment (3 gevechten).

**State:**
```gdscript
var play_counts: Dictionary[EmotionType, int] = {}
var segment_fight_count: int = 0
```

**Regels:**
- Na elk gevecht: `segment_fight_count += 1`
- Na 3 gevechten: top-emotie evolueert (mutation_level +1, max 2), minst gespeelde degradeert
- Mutatie-niveau wordt opgeslagen in `PlayerDeck` resource en doorgegeven bij `EmotionObject` aanmaken

---

## Scene Structuur

```
CombatScene.tscn
├── CombatGrid          (Node2D)
│   ├── GridCells       (Node2D — 45 GridCell children)
│   └── EmotionLayer    (Node2D — dynamisch gevuld)
├── EntityLayer         (Node2D)
│   ├── PlayerEntity
│   └── EnemyEntities   (dynamisch gevuld)
├── HandUI              (CanvasLayer)
│   └── CardFan         (HBoxContainer)
├── HUD                 (CanvasLayer)
│   ├── HPBar
│   └── TurnIndicator
└── Systems             (Node — niet zichtbaar)
    ├── TurnSystem
    ├── HandManager
    ├── ResonanceSystem
    └── DeckMutationSystem
```

---

## Data-bestanden

| Bestand | Type | Inhoud |
|---------|------|--------|
| `assets/data/emotion_config.tres` | Resource | Alle balanceerbare waarden per emotie en mutatieniveau |
| `assets/data/enemy_config.tres` | Resource | Vijandtypen, HP, attractie-tabellen |
| `assets/data/run_config.tres` | Resource | Grid-dimensies, handlimiet, drempelwaarden |

Alle gameplay-waarden zitten in deze Resources — nooit hardcoded in GDScript.

---

## ADR Referenties

- ADR-001: Grid-gebaseerde combat (geen vrije beweging) — *nog aan te maken*
- ADR-002: Signals-over-directe-referenties architectuur — *nog aan te maken*
- ADR-003: Puur statische EmotionLibrary (geen singleton) — *nog aan te maken*
