extends GdUnitTestSuite

# Bouwt een minimale CombatGrid zonder _ready() scene-tree logica.
func _make_grid() -> CombatGrid:
	var grid := CombatGrid.new()
	# Grid handmatig initialiseren (omzeilt _ready)
	for row in CombatGrid.GRID_HEIGHT:
		for col in CombatGrid.GRID_WIDTH:
			grid.cells.append(GridCell.new(col, row))
	return grid

func _place(grid: CombatGrid, type: EmotionObject.Type, col: int, row: int) -> EmotionObject:
	var cell := grid.get_cell(col, row)
	var obj := EmotionObject.new(type, cell, 1, 0)
	cell.emotion_object = obj
	grid.emotion_objects.append(obj)
	return obj


func test_no_resonance_with_two_identical() -> void:
	var grid := _make_grid()
	_place(grid, EmotionObject.Type.RAGE, 0, 0)
	_place(grid, EmotionObject.Type.RAGE, 1, 0)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).is_empty()


func test_resonance_with_three_horizontal() -> void:
	var grid := _make_grid()
	_place(grid, EmotionObject.Type.RAGE, 0, 0)
	_place(grid, EmotionObject.Type.RAGE, 1, 0)
	_place(grid, EmotionObject.Type.RAGE, 2, 0)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).has_size(1)
	assert_array(groups[0]).has_size(3)


func test_resonance_with_three_vertical() -> void:
	var grid := _make_grid()
	_place(grid, EmotionObject.Type.GRIEF, 2, 0)
	_place(grid, EmotionObject.Type.GRIEF, 2, 1)
	_place(grid, EmotionObject.Type.GRIEF, 2, 2)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).has_size(1)


func test_resonance_with_three_diagonal() -> void:
	var grid := _make_grid()
	_place(grid, EmotionObject.Type.AWE, 0, 0)
	_place(grid, EmotionObject.Type.AWE, 1, 1)
	_place(grid, EmotionObject.Type.AWE, 2, 2)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).has_size(1)


func test_no_resonance_mixed_types() -> void:
	var grid := _make_grid()
	_place(grid, EmotionObject.Type.RAGE, 0, 0)
	_place(grid, EmotionObject.Type.GRIEF, 1, 0)
	_place(grid, EmotionObject.Type.RAGE, 2, 0)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).is_empty()


func test_resonance_group_of_four() -> void:
	var grid := _make_grid()
	for col in 4:
		_place(grid, EmotionObject.Type.VOID, col, 0)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).has_size(1)
	assert_array(groups[0]).has_size(4)


func test_inactive_objects_excluded_from_resonance() -> void:
	var grid := _make_grid()
	var obj := _place(grid, EmotionObject.Type.RAGE, 0, 0)
	_place(grid, EmotionObject.Type.RAGE, 1, 0)
	_place(grid, EmotionObject.Type.RAGE, 2, 0)
	# Maak eerste object inactief
	for i in 4:
		obj.tick()
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).is_empty()


func test_two_separate_resonance_groups() -> void:
	var grid := _make_grid()
	# Groep 1: rij 0
	_place(grid, EmotionObject.Type.HOPE, 0, 0)
	_place(grid, EmotionObject.Type.HOPE, 1, 0)
	_place(grid, EmotionObject.Type.HOPE, 2, 0)
	# Groep 2: rij 4 (niet aangrenzend)
	_place(grid, EmotionObject.Type.HOPE, 0, 4)
	_place(grid, EmotionObject.Type.HOPE, 1, 4)
	_place(grid, EmotionObject.Type.HOPE, 2, 4)
	var groups := ResonanceSystem.find_resonance_groups(grid)
	assert_array(groups).has_size(2)
