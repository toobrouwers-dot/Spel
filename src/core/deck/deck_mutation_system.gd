class_name DeckMutationSystem
extends Node

const SEGMENT_LENGTH := 3
const EVOLVE_THRESHOLD := 4
const DEGRADE_THRESHOLD := 1

var play_counts: Dictionary = {}  # EmotionObject.Type -> int
var fight_count: int = 0

signal emotion_evolved(type: EmotionObject.Type, new_level: int)
signal emotion_degraded(type: EmotionObject.Type, new_level: int)

func record_play(type: EmotionObject.Type) -> void:
	play_counts[type] = play_counts.get(type, 0) + 1

func on_fight_ended(deck: Array[EmotionCard]) -> void:
	fight_count += 1
	if fight_count >= SEGMENT_LENGTH:
		_apply_mutations(deck)
		fight_count = 0
		play_counts.clear()

func _apply_mutations(deck: Array[EmotionCard]) -> void:
	if play_counts.is_empty():
		return

	var top_type := _get_top_played()
	var bottom_type := _get_least_played()

	_evolve_cards(deck, top_type)
	if bottom_type != top_type:
		_degrade_cards(deck, bottom_type)

func _evolve_cards(deck: Array[EmotionCard], type: EmotionObject.Type) -> void:
	for card in deck:
		if card.emotion_type == type and card.mutation_level < 2:
			card.mutation_level += 1
			emotion_evolved.emit(type, card.mutation_level)
			return  # Evolve one card per segment

func _degrade_cards(deck: Array[EmotionCard], type: EmotionObject.Type) -> void:
	for card in deck:
		if card.emotion_type == type and card.mutation_level > 0:
			card.mutation_level -= 1
			emotion_degraded.emit(type, card.mutation_level)
			return

func _get_top_played() -> EmotionObject.Type:
	var top: EmotionObject.Type = EmotionObject.Type.RAGE
	var top_count := -1
	for type in play_counts:
		if play_counts[type] > top_count:
			top_count = play_counts[type]
			top = type
	return top

func _get_least_played() -> EmotionObject.Type:
	var bottom: EmotionObject.Type = EmotionObject.Type.RAGE
	var bottom_count := INF
	for type in play_counts:
		if play_counts[type] < bottom_count:
			bottom_count = play_counts[type]
			bottom = type
	return bottom
