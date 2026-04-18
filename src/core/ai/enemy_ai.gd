class_name EnemyAI
extends RefCounted

func calculate_move(enemy: EnemyEntity, grid: CombatGrid) -> GridCell:
	var best_cell := enemy.grid_cell
	var best_score := _score_cell(enemy.grid_cell, enemy, grid)

	for neighbor in _get_walkable_neighbors(enemy.grid_cell, grid):
		var score := _score_cell(neighbor, enemy, grid)
		if score > best_score:
			best_score = score
			best_cell = neighbor

	return best_cell

func execute_attack(enemy: EnemyEntity, player: PlayerEntity) -> void:
	if enemy.grid_cell.manhattan_distance_to(player.grid_cell) == 1:
		player.record_damage(enemy.attack_damage)

func _score_cell(cell: GridCell, enemy: EnemyEntity, grid: CombatGrid) -> float:
	var score := 0.0
	for aura_obj in cell.active_auras:
		score += float(enemy.get_response(aura_obj.type)) * aura_obj.aura_radius
	return score

func _get_walkable_neighbors(cell: GridCell, grid: CombatGrid) -> Array[GridCell]:
	var result: Array[GridCell] = []
	for dc in [-1, 0, 1]:
		for dr in [-1, 0, 1]:
			if dc == 0 and dr == 0:
				continue
			var neighbor := grid.get_cell(cell.col + dc, cell.row + dr)
			if neighbor and neighbor.entity == null:
				result.append(neighbor)
	return result
