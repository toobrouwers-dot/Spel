class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var turn_label: Label = $TurnLabel
@onready var fight_label: Label = $FightLabel

func update_hp(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func update_turn(turn_number: int) -> void:
	turn_label.text = "Beurt %d" % turn_number

func update_fight_number(fight_number: int) -> void:
	fight_label.text = "Gevecht %d" % fight_number
