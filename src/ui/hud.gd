class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var turn_label: Label = $TurnLabel

func update_hp(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func update_turn(turn_number: int) -> void:
	turn_label.text = "Beurt %d" % turn_number
