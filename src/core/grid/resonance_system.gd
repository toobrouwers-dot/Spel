class_name ResonanceSystem
extends RefCounted

const RESONANCE_SIZE := 3

## Returns groups of 3+ connected identical EmotionObjects.
static func find_resonance_groups(grid: CombatGrid) -> Array[Array]:
	var groups: Array[Array] = []
	var visited: Array[EmotionObject] = []

	for obj in grid.emotion_objects:
		if obj in visited or not obj.is_active():
			continue
		var group := _flood_fill(obj, grid)
		if group.size() >= RESONANCE_SIZE:
			groups.append(group)
			visited.append_array(group)

	return groups

static func _flood_fill(start: EmotionObject, grid: CombatGrid) -> Array[EmotionObject]:
	var result: Array[EmotionObject] = [start]
	var queue: Array[EmotionObject] = [start]

	while not queue.is_empty():
		var current: EmotionObject = queue.pop_front()
		var neighbors := _get_adjacent_objects(current.cell, grid)
		for neighbor in neighbors:
			if neighbor.type == start.type and neighbor not in result:
				result.append(neighbor)
				queue.append(neighbor)

	return result

## Checks all 8 directions (including diagonal).
static func _get_adjacent_objects(cell: GridCell, grid: CombatGrid) -> Array[EmotionObject]:
	var result: Array[EmotionObject] = []
	for dc in [-1, 0, 1]:
		for dr in [-1, 0, 1]:
			if dc == 0 and dr == 0:
				continue
			var neighbor := grid.get_cell(cell.col + dc, cell.row + dr)
			if neighbor and neighbor.emotion_object and neighbor.emotion_object.is_active():
				result.append(neighbor.emotion_object)
	return result

static func get_group_center(group: Array[EmotionObject]) -> GridCell:
	var avg_col := 0
	var avg_row := 0
	for obj in group:
		avg_col += obj.cell.col
		avg_row += obj.cell.row
	return group[0].cell  # Simplified — full implementation uses nearest-to-average cell
