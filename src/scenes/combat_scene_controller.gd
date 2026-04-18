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
@onready var enemy_spawner: EnemySpawner = $Systems/EnemySpawner

const PLAYER_START_COL := 2
const PLAYER_START_ROW := 0
const SWIPE_THRESHOLD := 40.0

var combat_grid: CombatGrid
var cell_visuals: Dictionary = {}        # GridCell -> GridCellVisual
var emotion_visuals: Dictionary = {}     # EmotionObject -> EmotionObjectVisual
var enemy_visuals: Dictionary = {}       # EnemyEntity -> EnemyVisual
var player_visual: PlayerVisual
var game_over_screen: GameOverScreen
var _selected_card: EmotionCard = null
var _queued_move_cell: GridCell = null
var _touch_start: Vector2 = Vector2.ZERO

func _ready() -> void:
	combat_grid = CombatGrid.new()
	add_child(combat_grid)
	combat_grid.position = GRID_OFFSET
	_build_cell_visuals()
	_build_game_over_screen()
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
	enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
	turn_system.enemy_moved.connect(_on_enemy_moved)
	turn_system.turn_ended.connect(func(t): hud.update_turn(t))
	turn_system.panic_changed.connect(func(active): player_visual.show_panic(active))
	var p := _get_player()
	p.hp_changed.connect(func(_o, c): hud.update_hp(c, p.max_hp))
	p.moved.connect(func(_from, to): player_visual.move_to_cell(to))

func _start_fight() -> void:
	_place_player_on_grid()
	var starter_deck := _build_starter_deck()
	hand_manager.setup(starter_deck)
	var spawned_enemies := enemy_spawner.spawn_wave(combat_grid, 3)
	turn_system.setup(combat_grid, _get_player(), hand_manager, deck_mutation)
	turn_system.enemies = spawned_enemies
	hud.update_hp(_get_player().current_hp, _get_player().max_hp)
	for i in 4:
		hand_manager.draw_card()

func _build_game_over_screen() -> void:
	game_over_screen = GameOverScreen.new()
	game_over_screen.restart_requested.connect(
		func() -> void: get_tree().reload_current_scene()
	)
	add_child(game_over_screen)

func _place_player_on_grid() -> void:
	var p := _get_player()
	var start_cell := combat_grid.get_cell(PLAYER_START_COL, PLAYER_START_ROW)
	combat_grid.move_entity(p, start_cell)
	player_visual = PlayerVisual.new()
	player_visual.setup(p)
	entity_layer.add_child(player_visual)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
		else:
			_handle_swipe(event.position - _touch_start)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_touch_start = event.position
		else:
			_handle_swipe(event.position - _touch_start)

func _handle_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_THRESHOLD:
		return
	var dir := Vector2.ZERO
	if abs(delta.x) > abs(delta.y):
		dir = Vector2.RIGHT if delta.x > 0 else Vector2.LEFT
	else:
		dir = Vector2.DOWN if delta.y > 0 else Vector2.UP
	var player := _get_player()
	var target_col := player.grid_cell.col + int(dir.x)
	var target_row := player.grid_cell.row + int(dir.y)
	var target := combat_grid.get_cell(target_col, target_row)
	if target and target.entity == null:
		_set_queued_move(target)

func _set_queued_move(cell: GridCell) -> void:
	if _queued_move_cell and cell_visuals.has(_queued_move_cell):
		cell_visuals[_queued_move_cell].set_queued_move(false)
	_queued_move_cell = cell
	if cell and cell_visuals.has(cell):
		cell_visuals[cell].set_queued_move(true)

## Kaart geselecteerd vanuit HandUI
func on_card_selected(card: EmotionCard) -> void:
	_selected_card = card
	_highlight_valid_cells(card)

## Cel getapt — plaatst geselecteerde kaart en voert gequeued beweging uit
func on_cell_tapped(cell: GridCell) -> void:
	if not _selected_card or not cell.is_empty_of_emotion():
		return
	var move_target := _queued_move_cell if _queued_move_cell else _get_player().grid_cell
	turn_system.execute_player_action(_selected_card, cell, move_target)
	_selected_card = null
	_set_queued_move(null)
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

func _on_enemy_moved(enemy: EnemyEntity, new_cell: GridCell) -> void:
	if enemy_visuals.has(enemy):
		enemy_visuals[enemy].move_to_cell(new_cell)

func _on_enemy_spawned(enemy: EnemyEntity) -> void:
	var vis := EnemyVisual.new()
	vis.setup(enemy)
	entity_layer.add_child(vis)
	enemy_visuals[enemy] = vis
	enemy.died.connect(func() -> void: _on_enemy_died(enemy))

func _on_enemy_died(enemy: EnemyEntity) -> void:
	enemy_visuals.erase(enemy)
	turn_system.enemies.erase(enemy)

func _on_fight_ended(player_won: bool) -> void:
	if player_won:
		deck_mutation.on_fight_ended(hand_manager.draw_pile + hand_manager.hand + hand_manager.discard_pile)
		game_over_screen.show_win()
	else:
		game_over_screen.show_lose()

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
