class_name EmotionObjectVisual
extends Node2D

## Kleur per emotie-type
const EMOTION_COLORS: Dictionary = {
	EmotionObject.Type.RAGE:      Color(1.0, 0.2, 0.1),
	EmotionObject.Type.GRIEF:     Color(0.2, 0.4, 0.9),
	EmotionObject.Type.PANIC:     Color(1.0, 0.8, 0.0),
	EmotionObject.Type.AWE:       Color(0.8, 0.3, 1.0),
	EmotionObject.Type.VOID:      Color(0.1, 0.1, 0.15),
	EmotionObject.Type.HOPE:      Color(0.3, 1.0, 0.5),
	EmotionObject.Type.CONFUSION: Color(1.0, 0.5, 0.1),
	EmotionObject.Type.PRIDE:     Color(1.0, 0.85, 0.1),
	EmotionObject.Type.ENVY:      Color(0.5, 0.9, 0.2),
	EmotionObject.Type.NOSTALGIA: Color(0.9, 0.6, 0.8),
}

const CELL_SIZE := GridCellVisual.CELL_SIZE
const ICON_RADIUS := 36.0
const AURA_BASE_ALPHA := 0.18

var emotion_obj: EmotionObject
var _tween: Tween

func setup(obj: EmotionObject) -> void:
	emotion_obj = obj
	position = Vector2(
		obj.cell.col * CELL_SIZE + CELL_SIZE * 0.5,
		obj.cell.row * CELL_SIZE + CELL_SIZE * 0.5
	)
	_play_spawn_tween()
	queue_redraw()

func refresh() -> void:
	queue_redraw()

func play_collapse() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.15)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.tween_callback(queue_free)

func _draw() -> void:
	if not emotion_obj:
		return

	var color: Color = EMOTION_COLORS.get(emotion_obj.type, Color.WHITE)
	var alpha_mod := 0.5 if emotion_obj.phase == EmotionObject.Phase.FADED else 1.0

	# Aura cirkel
	var aura_r := emotion_obj.aura_radius * CELL_SIZE * 0.5
	draw_circle(Vector2.ZERO, aura_r, Color(color, AURA_BASE_ALPHA * alpha_mod))

	# Kern icoon
	draw_circle(Vector2.ZERO, ICON_RADIUS, Color(color, 0.9 * alpha_mod))
	draw_arc(Vector2.ZERO, ICON_RADIUS, 0, TAU, 32, Color(color, 1.0), 3.0)

func _play_spawn_tween() -> void:
	scale = Vector2(0.1, 0.1)
	modulate.a = 0.0
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)
