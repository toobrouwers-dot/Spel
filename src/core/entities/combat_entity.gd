class_name CombatEntity
extends Node2D

signal hp_changed(old_hp: int, new_hp: int)
signal died()

@export var max_hp: int = 20
var current_hp: int
var grid_cell: GridCell

func _ready() -> void:
	current_hp = max_hp

func take_damage(amount: int) -> void:
	var old := current_hp
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(old, current_hp)
	if current_hp == 0:
		died.emit()

func heal(amount: int) -> void:
	var old := current_hp
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(old, current_hp)

func is_alive() -> bool:
	return current_hp > 0
