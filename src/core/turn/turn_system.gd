class_name TurnSystem
extends Node

var grid: CombatGrid
var player: PlayerEntity
var hand_manager: HandManager
var deck_mutation: DeckMutationSystem
var enemy_ai: EnemyAI
var enemies: Array[EnemyEntity] = []
var turn_number: int = 0
var panic_active: bool = false

signal turn_started(turn: int)
signal turn_ended(turn: int)
signal fight_ended(player_won: bool)

func setup(
		g: CombatGrid,
		p: PlayerEntity,
		hm: HandManager,
		dm: DeckMutationSystem) -> void:
	grid = g
	player = p
	hand_manager = hm
	deck_mutation = dm
	enemy_ai = EnemyAI.new()
	grid.resonance_triggered.connect(_on_resonance)
	hand_manager.card_fragmented.connect(_on_card_fragmented)

func execute_player_action(card: EmotionCard, target_cell: GridCell, move_to: GridCell) -> void:
	deck_mutation.record_play(card.emotion_type)

	if card.emotion_type == EmotionObject.Type.PANIC:
		panic_active = true
		_place_panic()
	else:
		grid.place_emotion(card.emotion_type, target_cell, card.mutation_level)

	hand_manager.play_card(card)

	if move_to and move_to != player.grid_cell:
		grid.move_entity(player, move_to)

	if panic_active:
		_trigger_panic_extra_card()

	_apply_aura_effects()
	grid.tick_all_objects()
	_execute_enemies()
	hand_manager.draw_card()
	turn_number += 1
	turn_ended.emit(turn_number)

	if not player.is_alive():
		fight_ended.emit(false)
	elif enemies.all(func(e: EnemyEntity) -> bool: return not e.is_alive()):
		fight_ended.emit(true)

func _place_panic() -> void:
	var existing := _find_panic_object()
	if existing:
		return
	grid.place_emotion(EmotionObject.Type.PANIC, player.grid_cell, 0)

func _trigger_panic_extra_card() -> void:
	var random_card := hand_manager.get_random_card()
	if not random_card:
		return
	var random_cell := grid.get_random_empty_cell()
	if not random_cell:
		return
	grid.place_emotion(random_card.emotion_type, random_cell, random_card.mutation_level)
	hand_manager.play_card(random_card)

func _apply_aura_effects() -> void:
	for cell in grid.cells:
		if cell.entity and cell.entity is EnemyEntity:
			for aura_obj in cell.active_auras:
				var effect := EmotionLibrary.build_aura_effect(
						aura_obj.type, aura_obj.mutation_level, aura_obj)
				_apply_effect(effect, cell.entity as EnemyEntity)

func _apply_effect(effect: AuraEffect, target: CombatEntity) -> void:
	match effect.effect_type:
		AuraEffect.EffectType.DAMAGE_PER_TURN:
			target.take_damage(int(effect.value))

func _execute_enemies() -> void:
	for enemy in enemies:
		if not enemy.is_alive():
			continue
		var target_cell := enemy_ai.calculate_move(enemy, grid)
		if target_cell != enemy.grid_cell:
			grid.move_entity(enemy, target_cell)
		enemy_ai.execute_attack(enemy, player)

func _on_resonance(group: Array[EmotionObject]) -> void:
	var center := ResonanceSystem.get_group_center(group)
	var total_power := 0.0
	var has_awe := _has_awe_in_radius(center, 2)

	for obj in group:
		total_power += EmotionLibrary.get_collapse_power(obj.type, obj.mutation_level)
		obj.force_remove()

	if has_awe:
		total_power *= 2.0
		grid.move_entity(player, center)

	for enemy in enemies:
		if enemy.grid_cell == center:
			enemy.take_damage(int(total_power))

	grid.emotion_objects = grid.emotion_objects.filter(
			func(o: EmotionObject) -> bool: return o.is_active())

func _on_card_fragmented(card: EmotionCard) -> void:
	var random_cell := grid.get_random_empty_cell()
	if random_cell:
		grid.place_emotion(card.emotion_type, random_cell, card.mutation_level)

func _has_awe_in_radius(center: GridCell, radius: int) -> bool:
	for obj in grid.emotion_objects:
		if obj.type == EmotionObject.Type.AWE and obj.is_active():
			if obj.cell.manhattan_distance_to(center) <= radius:
				return true
	return false

func _find_panic_object() -> EmotionObject:
	for obj in grid.emotion_objects:
		if obj.type == EmotionObject.Type.PANIC:
			return obj
	return null
