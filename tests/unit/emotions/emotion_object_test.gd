extends GdUnitTestSuite

# Helper: bouwt een minimale GridCell zonder CombatGrid
func _make_cell(col: int = 0, row: int = 0) -> GridCell:
	return GridCell.new(col, row)

func _make_obj(type := EmotionObject.Type.RAGE) -> EmotionObject:
	var cell := _make_cell()
	var obj := EmotionObject.new(type, cell, 1, 0)
	cell.emotion_object = obj
	return obj


func test_initial_phase_is_active() -> void:
	var obj := _make_obj()
	assert_int(obj.phase).is_equal(EmotionObject.Phase.ACTIVE)


func test_tick_twice_sets_faded() -> void:
	var obj := _make_obj()
	obj.tick()
	obj.tick()
	assert_int(obj.phase).is_equal(EmotionObject.Phase.FADED)


func test_faded_reduces_aura_radius() -> void:
	var cell := _make_cell()
	var obj := EmotionObject.new(EmotionObject.Type.RAGE, cell, 2, 0)
	cell.emotion_object = obj
	obj.tick()
	obj.tick()
	assert_int(obj.aura_radius).is_equal(1)


func test_aura_radius_never_below_one_after_fade() -> void:
	var cell := _make_cell()
	var obj := EmotionObject.new(EmotionObject.Type.GRIEF, cell, 1, 0)
	cell.emotion_object = obj
	obj.tick()
	obj.tick()
	assert_int(obj.aura_radius).is_greater_equal(1)


func test_tick_four_times_triggers_collapse() -> void:
	var obj := _make_obj()
	var collapsed_fired := false
	obj.collapsed.connect(func(_o, _p): collapsed_fired = true)
	for i in 4:
		obj.tick()
	assert_bool(collapsed_fired).is_true()


func test_collapse_clears_cell_reference() -> void:
	var obj := _make_obj()
	for i in 4:
		obj.tick()
	assert_object(obj.cell).is_null()


func test_collapse_phase_is_gone() -> void:
	var obj := _make_obj()
	for i in 4:
		obj.tick()
	assert_int(obj.phase).is_equal(EmotionObject.Phase.GONE)


func test_echo_tokens_double_collapse_power() -> void:
	var obj := _make_obj()
	obj.echo_tokens = 1
	var received_power := 0.0
	obj.collapsed.connect(func(_o, power): received_power = power)
	for i in 4:
		obj.tick()
	# Met 1 echo token: power × (1 + 1) = 2×
	var base := EmotionLibrary.get_collapse_power(EmotionObject.Type.RAGE, 0)
	assert_float(received_power).is_equal_approx(base * 2.0, 0.01)


func test_force_remove_sets_gone_immediately() -> void:
	var obj := _make_obj()
	obj.force_remove()
	assert_int(obj.phase).is_equal(EmotionObject.Phase.GONE)
	assert_object(obj.cell).is_null()


func test_is_active_returns_false_after_collapse() -> void:
	var obj := _make_obj()
	for i in 4:
		obj.tick()
	assert_bool(obj.is_active()).is_false()


func test_is_active_returns_true_when_faded() -> void:
	var obj := _make_obj()
	obj.tick()
	obj.tick()
	assert_bool(obj.is_active()).is_true()
