class_name GridCellVisual
extends Node2D

const CELL_SIZE := 180.0
const BORDER_COLOR := Color(0.3, 0.3, 0.4, 0.6)
const HIGHLIGHT_COLOR := Color(0.8, 0.8, 1.0, 0.3)
const VALID_DROP_COLOR := Color(0.2, 1.0, 0.4, 0.4)

var cell: GridCell
var _highlighted := false
var _valid_drop := false

signal tapped(cell: GridCell)

func setup(c: GridCell) -> void:
	cell = c
	position = Vector2(
		c.col * CELL_SIZE + CELL_SIZE * 0.5,
		c.row * CELL_SIZE + CELL_SIZE * 0.5
	)
	queue_redraw()

func set_highlighted(on: bool) -> void:
	_highlighted = on
	queue_redraw()

func set_valid_drop(on: bool) -> void:
	_valid_drop = on
	queue_redraw()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tapped.emit(cell)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(cell)

func _draw() -> void:
	var half := CELL_SIZE * 0.5
	var rect := Rect2(-half, -half, CELL_SIZE, CELL_SIZE)

	if _valid_drop:
		draw_rect(rect, VALID_DROP_COLOR)
	elif _highlighted:
		draw_rect(rect, HIGHLIGHT_COLOR)

	draw_rect(rect, BORDER_COLOR, false, 2.0)
