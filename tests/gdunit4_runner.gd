## GdUnit4 headless runner — gebruikt door CI.
## Uitvoeren met: godot --headless --script tests/gdunit4_runner.gd
extends SceneTree

const GdUnitRunner = preload("res://addons/gdUnit4/src/core/GdUnitRunner.gd")

func _initialize() -> void:
	var runner := GdUnitRunner.new()
	runner.run_tests_from_directory("res://tests/unit")
	quit()
