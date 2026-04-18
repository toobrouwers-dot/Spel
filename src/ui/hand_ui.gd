class_name HandUI
extends CanvasLayer

@onready var card_fan: HBoxContainer = $CardFan

var _card_buttons: Array[Button] = []

signal card_selected(card: EmotionCard)

## Herbouw de kaart-rij op basis van de actuele hand.
func refresh_hand(hand: Array[EmotionCard]) -> void:
	for btn in _card_buttons:
		btn.queue_free()
	_card_buttons.clear()

	for card in hand:
		var btn := _make_card_button(card)
		card_fan.add_child(btn)
		_card_buttons.append(btn)

func _make_card_button(card: EmotionCard) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(180.0, 260.0)
	btn.text = EmotionObject.Type.keys()[card.emotion_type]
	btn.pressed.connect(func() -> void: card_selected.emit(card))
	return btn
