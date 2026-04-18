class_name RunProgressionSystem
extends Node

## Houdt de run-staat bij over meerdere gevechten.
## Persisteert via SceneTree autoload zodat reload_current_scene() het niet wist.

var fight_number: int = 1
var enemies_defeated: int = 0
var run_active: bool = true

func get_enemy_count() -> int:
	return min(3 + (fight_number - 1) / 2, 6)

func get_enemy_hp() -> int:
	return 12 + (fight_number - 1) * 3

func get_enemy_damage() -> int:
	return 4 + (fight_number - 1) * 1

func advance_fight(defeated_this_fight: int) -> void:
	enemies_defeated += defeated_this_fight
	fight_number += 1

func reset() -> void:
	fight_number = 1
	enemies_defeated = 0
	run_active = true
