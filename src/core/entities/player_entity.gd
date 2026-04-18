class_name PlayerEntity
extends CombatEntity

signal moved(from: GridCell, to: GridCell)

var damage_taken_this_fight: int = 0

func move_to(target: GridCell) -> void:
	var from := grid_cell
	grid_cell = target
	moved.emit(from, target)

func record_damage(amount: int) -> void:
	damage_taken_this_fight += amount
	take_damage(amount)

func reset_fight_stats() -> void:
	damage_taken_this_fight = 0
