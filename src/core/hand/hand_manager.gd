class_name HandManager
extends Node

const HAND_LIMIT := 6

var hand: Array[EmotionCard] = []
var draw_pile: Array[EmotionCard] = []
var discard_pile: Array[EmotionCard] = []

signal card_drawn(card: EmotionCard)
signal card_fragmented(card: EmotionCard)
signal hand_changed(hand: Array[EmotionCard])

func setup(deck: Array[EmotionCard]) -> void:
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()

func draw_card() -> void:
	if draw_pile.is_empty():
		_recycle_discard()
	if draw_pile.is_empty():
		return

	var card := draw_pile.pop_front() as EmotionCard

	if hand.size() >= HAND_LIMIT:
		_fragment(hand[0])
		hand.remove_at(0)

	hand.append(card)
	card_drawn.emit(card)
	hand_changed.emit(hand)

func play_card(card: EmotionCard) -> void:
	hand.erase(card)
	discard_pile.append(card)
	hand_changed.emit(hand)

func get_random_card() -> EmotionCard:
	if hand.is_empty():
		return null
	return hand[randi() % hand.size()]

func _fragment(card: EmotionCard) -> void:
	## Fragmented card fires at half power via signal — TurnSystem handles the effect.
	card_fragmented.emit(card)

func _recycle_discard() -> void:
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
