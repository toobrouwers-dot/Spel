class_name CombatGrid
extends Node2D

const GRID_WIDTH := 5
const GRID_HEIGHT := 9

var cells: Array[GridCell] = []
var emotion_objects: Array[EmotionObject] = []
var entities: Array[CombatEntity] = []

signal emotion_placed(obj: EmotionObject, cell: GridCell)
signal emotion_collapsed(obj: EmotionObject, power: float)
signal aura_recalculated()
signal resonance_triggered(group: Array[EmotionObject])

func _ready() -> void:
	_build_grid()

func _build_grid() -> void:
	cells.clear()
	for row in GRID_HEIGHT:
		for col in GRID_WIDTH:
			cells.append(GridCell.new(col, row))

func place_emotion(type: EmotionObject.Type, target_cell: GridCell, mutation_level: int = 0) -> void:
	if not target_cell.is_empty_of_emotion():
		return
	var radius := EmotionLibrary.get_aura_radius(type, mutation_level)
	var obj := EmotionObject.new(type, target_cell, radius, mutation_level)
	obj.collapsed.connect(_on_emotion_collapsed)
	target_cell.emotion_object = obj
	emotion_objects.append(obj)
	_recalculate_auras()
	emotion_placed.emit(obj, target_cell)
	_check_resonance(target_cell)

func tick_all_objects() -> void:
	for obj in emotion_objects.duplicate():
		obj.tick()
	emotion_objects = emotion_objects.filter(func(o: EmotionObject) -> bool: return o.is_active())
	_recalculate_auras()

func move_entity(entity: CombatEntity, target_cell: GridCell) -> void:
	if entity.grid_cell:
		entity.grid_cell.entity = null
	entity.grid_cell = target_cell
	target_cell.entity = entity

func get_cell(col: int, row: int) -> GridCell:
	if col < 0 or col >= GRID_WIDTH or row < 0 or row >= GRID_HEIGHT:
		return null
	return cells[row * GRID_WIDTH + col]

func get_cells_in_radius(origin: GridCell, radius: int) -> Array[GridCell]:
	var result: Array[GridCell] = []
	for cell in cells:
		if abs(cell.col - origin.col) <= radius and abs(cell.row - origin.row) <= radius:
			result.append(cell)
	return result

func get_random_empty_cell() -> GridCell:
	var empty := cells.filter(func(c: GridCell) -> bool: return c.is_empty_of_emotion() and c.entity == null)
	if empty.is_empty():
		return null
	return empty[randi() % empty.size()]

func _recalculate_auras() -> void:
	AuraCalculator.recalculate(self)
	aura_recalculated.emit()

func _check_resonance(origin: GridCell) -> void:
	var groups := ResonanceSystem.find_resonance_groups(self)
	for group in groups:
		resonance_triggered.emit(group)

func _on_emotion_collapsed(obj: EmotionObject, power: float) -> void:
	emotion_collapsed.emit(obj, power)
