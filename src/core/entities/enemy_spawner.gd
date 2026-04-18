class_name EnemySpawner
extends Node

## Rijen waar vijanden spawnen (bovenkant grid)
const SPAWN_ROWS := [6, 7, 8]

## Standaard emotie-responses: aangetrokken door Hoop, afgestoten door Woede
const DEFAULT_RESPONSES := {
	EmotionObject.Type.RAGE:  -2,
	EmotionObject.Type.HOPE:   1,
	EmotionObject.Type.GRIEF:  0,
	EmotionObject.Type.PANIC:  1,
	EmotionObject.Type.AWE:   -1,
}

signal enemy_spawned(enemy: EnemyEntity)

func spawn_wave(grid: CombatGrid, count: int) -> Array[EnemyEntity]:
	var spawned: Array[EnemyEntity] = []
	var available := _get_available_spawn_cells(grid)
	available.shuffle()

	for i in min(count, available.size()):
		var cell := available[i]
		var enemy := _create_enemy(cell)
		grid.move_entity(enemy, cell)
		spawned.append(enemy)
		enemy_spawned.emit(enemy)

	return spawned

func _get_available_spawn_cells(grid: CombatGrid) -> Array[GridCell]:
	var cells: Array[GridCell] = []
	for cell in grid.cells:
		if cell.row in SPAWN_ROWS and cell.entity == null:
			cells.append(cell)
	return cells

func _create_enemy(cell: GridCell) -> EnemyEntity:
	var enemy := EnemyEntity.new()
	enemy.max_hp = 12
	enemy.attack_damage = 4
	enemy.move_speed = 1
	enemy.emotion_responses = DEFAULT_RESPONSES.duplicate()
	enemy.grid_cell = cell
	cell.entity = enemy
	return enemy
