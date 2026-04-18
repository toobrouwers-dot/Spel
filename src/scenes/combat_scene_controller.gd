class_name CombatSceneController
extends Node2D

const CELL_SIZE := GridCellVisual.CELL_SIZE
const GRID_OFFSET := Vector2(
	(1080.0 - CombatGrid.GRID_WIDTH * GridCellVisual.CELL_SIZE) * 0.5,
	80.0
)

@onready var grid_layer: Node2D = $GridLayer
@onready var emotion_layer: Node2D = $EmotionLayer
@onready var entity_layer: Node2D = $EntityLayer
@onready var hud: CanvasLayer = $HUD
@onready var hand_ui: CanvasLayer = $HandUI
@onready var turn_system: TurnSystem = $Systems/TurnSystem
@onready var hand_manager: HandManager = $Systems/HandManager
@onready var deck_mutation: DeckMutationSystem = $Systems/DeckMutationSystem

var combat_grid: CombatGrid
var cell_visuals: Dictionary = {}        # GridCell -> GridCellVisual
var emotion_visuals: Dictionary = {}     # EmotionObject -> EmotionObjectVisual
var _selected_card: EmotionCard = null

func _ready() -> void:
	combat_grid = CombatGrid.new()
	add_child(combat_grid)
	combat_grid.position = GRID_OFFSET
	_build_cell_visuals()
	_connect_signals()
	_start_fight()

func _build_cell_visuals() -> void:
	for cell in combat_grid.cells:
		var vis := GridCellVisual.new()
		vis.setup(cell)
		vis.tapped.connect(on_cell_tapped)
		grid_layer.add_child(vis)
		cell_visuals[cell] = vis

func _connect_signals() -> void:
	combat_grid.emotion_placed.connect(_on_emotion_placed)
	combat_grid.emotion_collapsed.connect(_on_emotion_collapsed)
	combat_grid.resonance_triggered.connect(_on_resonance_triggered)
	hand_manager.hand_changed.connect(_on_hand_changed)
	turn_system.fight_ended.connect(_on_fight_ended)
	hand_ui.card_selected.connect(on_card_selected)
	turn_system.turn_ended.connect(func(t): hud.update_turn(t))
	_get_player().hp_changed.connect(func(_o, c): hud.update_hp(c, _get_player().max_hp))

func _start_fight() -> void:
	var starter_deck := _build_starter_deck()
	hand_manager.setup(starter_deck)
	turn_system.setup(combat_grid, _get_player(), hand_manager, deck_mutation)
	for i in 4:
		hand_manager.draw_card()

## Kaart geselecteerd vanuit HandUI
func on_card_selected(card: EmotionCard) -> void:
	_selected_card = card
	_highlight_valid_cells(card)

## Cel getapt — plaatst geselecteerde kaart
func on_cell_tapped(cell: GridCell) -> void:
	if not _selected_card or not cell.is_empty_of_emotion():
		return
	var move_target := _get_player().grid_cell
	turn_system.execute_player_action(_selected_card, cell, move_target)
	_selected_card = null
	_clear_highlights()

func _highlight_valid_cells(card: EmotionCard) -> void:
	_clear_highlights()
	if card.emotion_type == EmotionObject.Type.PANIC:
		return  # Panic plaatst altijd op spelercel
	for cell in combat_grid.cells:
		if cell.is_empty_of_emotion():
			cell_visuals[cell].set_valid_drop(true)

func _clear_highlights() -> void:
	for vis in cell_visuals.values():
		vis.set_highlighted(false)
		vis.set_valid_drop(false)

func _on_emotion_placed(obj: EmotionObject, _cell: GridCell) -> void:
	var vis := EmotionObjectVisual.new()
	vis.setup(obj)
	emotion_layer.add_child(vis)
	emotion_visuals[obj] = vis

func _on_emotion_collapsed(obj: EmotionObject, _power: float) -> void:
	if emotion_visuals.has(obj):
		emotion_visuals[obj].play_collapse()
		emotion_visuals.erase(obj)

func _on_resonance_triggered(group: Array[EmotionObject]) -> void:
	for obj in group:
		if emotion_visuals.has(obj):
			emotion_visuals[obj].play_collapse()
			emotion_visuals.erase(obj)

func _on_hand_changed(_hand: Array[EmotionCard]) -> void:
	hand_ui.refresh_hand(hand_manager.hand)

func _on_fight_ended(player_won: bool) -> void:
	if player_won:
		deck_mutation.on_fight_ended(hand_manager.draw_pile + hand_manager.hand + hand_manager.discard_pile)

func _get_player() -> PlayerEntity:
	return entity_layer.get_node("PlayerEntity") as PlayerEntity

func _build_starter_deck() -> Array[EmotionCard]:
	var deck: Array[EmotionCard] = []
	var types := [
		EmotionObject.Type.RAGE, EmotionObject.Type.RAGE, EmotionObject.Type.RAGE,
		EmotionObject.Type.GRIEF, EmotionObject.Type.GRIEF,
		EmotionObject.Type.HOPE, EmotionObject.Type.HOPE,
		EmotionObject.Type.AWE,
		EmotionObject.Type.PANIC,
		EmotionObject.Type.CONFUSION,
	]
	for type in types:
		var card := EmotionCard.new()
		card.emotion_type = type
		card.mutation_level = 0
		deck.append(card)
	return deck
