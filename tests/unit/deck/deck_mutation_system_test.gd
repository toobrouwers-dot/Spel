extends GdUnitTestSuite

func _make_deck(types: Array[EmotionObject.Type]) -> Array[EmotionCard]:
	var deck: Array[EmotionCard] = []
	for type in types:
		var card := EmotionCard.new()
		card.emotion_type = type
		card.mutation_level = 0
		deck.append(card)
	return deck


func test_no_mutation_before_segment_complete() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([
		EmotionObject.Type.RAGE, EmotionObject.Type.RAGE, EmotionObject.Type.GRIEF
	])
	for i in 3:
		system.record_play(EmotionObject.Type.RAGE)
	# Nog geen gevecht afgerond
	assert_int(deck[0].mutation_level).is_equal(0)


func test_top_emotion_evolves_after_segment() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([
		EmotionObject.Type.RAGE, EmotionObject.Type.GRIEF
	])
	# RAGE 5× spelen, GRIEF 1×
	for i in 5:
		system.record_play(EmotionObject.Type.RAGE)
	system.record_play(EmotionObject.Type.GRIEF)
	# 3 gevechten afronden = segment
	for i in 3:
		system.on_fight_ended(deck)
	var rage_card := deck.filter(func(c): return c.emotion_type == EmotionObject.Type.RAGE)[0]
	assert_int(rage_card.mutation_level).is_equal(1)


func test_least_played_degrades_after_segment() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([
		EmotionObject.Type.RAGE, EmotionObject.Type.GRIEF
	])
	deck[1].mutation_level = 1  # GRIEF start op niveau 1
	for i in 5:
		system.record_play(EmotionObject.Type.RAGE)
	system.record_play(EmotionObject.Type.GRIEF)
	for i in 3:
		system.on_fight_ended(deck)
	var grief_card := deck.filter(func(c): return c.emotion_type == EmotionObject.Type.GRIEF)[0]
	assert_int(grief_card.mutation_level).is_equal(0)


func test_mutation_level_caps_at_two() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([EmotionObject.Type.RAGE])
	deck[0].mutation_level = 2
	for i in 5:
		system.record_play(EmotionObject.Type.RAGE)
	for i in 3:
		system.on_fight_ended(deck)
	assert_int(deck[0].mutation_level).is_equal(2)


func test_mutation_level_never_below_zero() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([EmotionObject.Type.GRIEF])
	deck[0].mutation_level = 0
	# Nooit gespeeld in het segment
	for i in 3:
		system.on_fight_ended(deck)
	assert_int(deck[0].mutation_level).is_equal(0)


func test_play_counts_reset_after_segment() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([EmotionObject.Type.RAGE, EmotionObject.Type.GRIEF])
	for i in 5:
		system.record_play(EmotionObject.Type.RAGE)
	for i in 3:
		system.on_fight_ended(deck)
	# Na segment: counts gereset, fight_count = 0
	assert_int(system.fight_count).is_equal(0)
	assert_bool(system.play_counts.is_empty()).is_true()


func test_emotion_evolved_signal_fires() -> void:
	var system := auto_free(DeckMutationSystem.new())
	var deck := _make_deck([EmotionObject.Type.RAGE])
	var signal_fired := false
	system.emotion_evolved.connect(func(_t, _l): signal_fired = true)
	for i in 5:
		system.record_play(EmotionObject.Type.RAGE)
	for i in 3:
		system.on_fight_ended(deck)
	assert_bool(signal_fired).is_true()
