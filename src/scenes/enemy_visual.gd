class_name EnemyVisual
extends Node2D

const CELL_SIZE := GridCellVisual.CELL_SIZE
const ENEMY_COLOR := Color(0.9, 0.15, 0.1)
const BODY_RADIUS := 30.0
const HP_BAR_WIDTH := 60.0
const HP_BAR_HEIGHT := 8.0
const HP_BAR_OFFSET := Vector2(-HP_BAR_WIDTH * 0.5, -BODY_RADIUS - 16.0)

var enemy: EnemyEntity
var _tween: Tween

func setup(e: EnemyEntity) -> void:
	enemy = e
	enemy.hp_changed.connect(_on_hp_changed)
	enemy.died.connect(_on_died)
	position = _cell_to_position(e.grid_cell)
	_play_spawn_tween()
	queue_redraw()

func move_to_cell(cell: GridCell) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", _cell_to_position(cell), 0.18) \
		.set_trans(Tween.TRANS_SINE)

func _on_hp_changed(_old: int, _new: int) -> void:
	queue_redraw()

func _on_died() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.chain().tween_callback(queue_free)

func _draw() -> void:
	if not enemy:
		return

	# Lichaam
	draw_circle(Vector2.ZERO, BODY_RADIUS, ENEMY_COLOR)
	draw_arc(Vector2.ZERO, BODY_RADIUS, 0, TAU, 32, Color(1.0, 0.4, 0.3), 3.0)

	# HP-balk achtergrond
	var bg_rect := Rect2(HP_BAR_OFFSET, Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT))
	draw_rect(bg_rect, Color(0.2, 0.0, 0.0))

	# HP-balk vulling
	var ratio := float(enemy.current_hp) / float(enemy.max_hp)
	var fill_rect := Rect2(HP_BAR_OFFSET, Vector2(HP_BAR_WIDTH * ratio, HP_BAR_HEIGHT))
	draw_rect(fill_rect, Color(0.9, 0.1, 0.1))

func _play_spawn_tween() -> void:
	scale = Vector2(0.1, 0.1)
	modulate.a = 0.0
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "modulate:a", 1.0, 0.18)

func _cell_to_position(cell: GridCell) -> Vector2:
	return Vector2(
		cell.col * CELL_SIZE + CELL_SIZE * 0.5,
		cell.row * CELL_SIZE + CELL_SIZE * 0.5
	)
