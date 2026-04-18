class_name AuraCalculator
extends RefCounted

## Returns a map of cell_id -> Array[AuraEffect] for all active emotion objects.
static func recalculate(grid: CombatGrid) -> Dictionary:
	var result: Dictionary = {}

	for cell in grid.cells:
		cell.active_auras.clear()

	var void_cells: Array[GridCell] = _find_void_cells(grid)

	for obj in grid.emotion_objects:
		if not obj.is_active():
			continue
		var affected := grid.get_cells_in_radius(obj.cell, obj.aura_radius)
		for cell in affected:
			var target_cell: GridCell = _redirect_to_void(cell, void_cells)
			target_cell.active_auras.append(obj)

	for cell in grid.cells:
		var effects: Array[AuraEffect] = []
		for obj in cell.active_auras:
			var effect := EmotionLibrary.build_aura_effect(obj.type, obj.mutation_level, obj)
			if effect.effect_type != AuraEffect.EffectType.NONE:
				effects.append(effect)
		if effects.size() > 0:
			result[cell.get_id()] = effects

	return result

## Leegte-objecten trekken andere aura's naar hun cel.
static func _find_void_cells(grid: CombatGrid) -> Array[GridCell]:
	var voids: Array[GridCell] = []
	for obj in grid.emotion_objects:
		if obj.type == EmotionObject.Type.VOID and obj.is_active():
			voids.append(obj.cell)
	return voids

static func _redirect_to_void(cell: GridCell, void_cells: Array[GridCell]) -> GridCell:
	if void_cells.is_empty():
		return cell
	# Redirect to nearest void cell if within radius 3
	for void_cell in void_cells:
		if cell.manhattan_distance_to(void_cell) <= 3:
			return void_cell
	return cell
