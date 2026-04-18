class_name PlayerVisual
extends Node2D

const CELL_SIZE := GridCellVisual.CELL_SIZE
const BODY_RADIUS := 28.0
const BODY_COLOR := Color(0.3, 0.8, 1.0)
const OUTLINE_COLOR := Color(0.6, 1.0, 1.0)
const HP_BAR_WIDTH := 60.0
const HP_BAR_HEIGHT := 8.0
const HP_BAR_OFFSET := Vector2(-HP_BAR_WIDTH * 0.5, -BODY_RADIUS - 16.0)

var player: PlayerEntity
var _tween: Tween
var _panic_pulse: Tween

func setup(p: PlayerEntity) -> void:
	player = p
	player.hp_changed.connect(_on_hp_changed)
	position = _cell_to_position(p.grid_cell)
	queue_redraw()

func move_to_cell(cell: GridCell) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", _cell_to_position(cell), 0.14) \
		.set_trans(Tween.TRANS_SINE)

func show_panic(active: bool) -> void:
	if _panic_pulse:
		_panic_pulse.kill()
	if active:
		_panic_pulse = create_tween().set_loops()
		_panic_pulse.tween_property(self, "modulate", Color(1.0, 0.6, 0.1), 0.3)
		_panic_pulse.tween_property(self, "modulate", Color.WHITE, 0.3)
	else:
		modulate = Color.WHITE

func _on_hp_changed(_old: int, _new: int) -> void:
	queue_redraw()
	# Schade-flash
	var flash := create_tween()
	flash.tween_property(self, "modulate", Color(1.0, 0.2, 0.2), 0.08)
	flash.tween_property(self, "modulate", Color.WHITE, 0.15)

func _draw() -> void:
	if not player:
		return

	# Lichaam
	draw_circle(Vector2.ZERO, BODY_RADIUS, BODY_COLOR)
	draw_arc(Vector2.ZERO, BODY_RADIUS, 0, TAU, 32, OUTLINE_COLOR, 3.0)

	# HP-balk
	var bg_rect := Rect2(HP_BAR_OFFSET, Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT))
	draw_rect(bg_rect, Color(0.1, 0.1, 0.2))
	var ratio := float(player.current_hp) / float(player.max_hp)
	draw_rect(Rect2(HP_BAR_OFFSET, Vector2(HP_BAR_WIDTH * ratio, HP_BAR_HEIGHT)),
		Color(0.2, 0.8, 1.0))

func _cell_to_position(cell: GridCell) -> Vector2:
	return Vector2(
		cell.col * CELL_SIZE + CELL_SIZE * 0.5,
		cell.row * CELL_SIZE + CELL_SIZE * 0.5
	)
