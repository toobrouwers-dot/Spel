class_name GridCell
extends RefCounted

var col: int
var row: int
var entity: CombatEntity
var emotion_object: EmotionObject
var active_auras: Array[EmotionObject] = []

func _init(c: int, r: int) -> void:
	col = c
	row = r

func is_empty_of_emotion() -> bool:
	return emotion_object == null

func get_id() -> String:
	return "%d_%d" % [col, row]

func manhattan_distance_to(other: GridCell) -> int:
	return abs(col - other.col) + abs(row - other.row)
