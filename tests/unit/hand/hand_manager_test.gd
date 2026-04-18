extends GdUnitTestSuite

func _make_card(type := EmotionObject.Type.RAGE) -> EmotionCard:
	var card := EmotionCard.new()
	card.emotion_type = type
	card.mutation_level = 0
	return card

func _make_deck(size: int) -> Array[EmotionCard]:
	var deck: Array[EmotionCard] = []
	for i in size:
		deck.append(_make_card())
	return deck

func _make_manager(deck_size: int = 10) -> HandManager:
	var mgr := auto_free(HandManager.new())
	mgr.setup(_make_deck(deck_size))
	return mgr


func test_draw_adds_card_to_hand() -> void:
	var mgr := _make_manager()
	mgr.draw_card()
	assert_array(mgr.hand).has_size(1)


func test_hand_does_not_exceed_limit() -> void:
	var mgr := _make_manager(20)
	for i in HandManager.HAND_LIMIT + 3:
		mgr.draw_card()
	assert_array(mgr.hand).has_size(HandManager.HAND_LIMIT)


func test_overflow_fires_fragmented_signal() -> void:
	var mgr := _make_manager(20)
	var fragment_count := 0
	mgr.card_fragmented.connect(func(_c): fragment_count += 1)
	for i in HandManager.HAND_LIMIT + 1:
		mgr.draw_card()
	assert_int(fragment_count).is_equal(1)


func test_play_card_removes_from_hand() -> void:
	var mgr := _make_manager()
	mgr.draw_card()
	var card := mgr.hand[0]
	mgr.play_card(card)
	assert_array(mgr.hand).is_empty()


func test_play_card_goes_to_discard() -> void:
	var mgr := _make_manager()
	mgr.draw_card()
	var card := mgr.hand[0]
	mgr.play_card(card)
	assert_array(mgr.discard_pile).has_size(1)


func test_discard_recycled_when_draw_pile_empty() -> void:
	var mgr := _make_manager(2)
	# Trek beide kaarten
	mgr.draw_card()
	mgr.draw_card()
	# Speel ze af
	mgr.play_card(mgr.hand[0])
	mgr.play_card(mgr.hand[0])
	# Draw pile is leeg, discard wordt recycled
	mgr.draw_card()
	assert_array(mgr.hand).has_size(1)
	assert_array(mgr.draw_pile).has_size(0)


func test_get_random_card_returns_null_on_empty_hand() -> void:
	var mgr := _make_manager()
	assert_object(mgr.get_random_card()).is_null()


func test_get_random_card_returns_card_from_hand() -> void:
	var mgr := _make_manager()
	mgr.draw_card()
	var card := mgr.get_random_card()
	assert_object(card).is_not_null()
	assert_bool(mgr.hand.has(card)).is_true()


func test_hand_changed_signal_fires_on_draw() -> void:
	var mgr := _make_manager()
	var fired := false
	mgr.hand_changed.connect(func(_h): fired = true)
	mgr.draw_card()
	assert_bool(fired).is_true()


func test_hand_changed_signal_fires_on_play() -> void:
	var mgr := _make_manager()
	mgr.draw_card()
	var fired := false
	mgr.hand_changed.connect(func(_h): fired = true)
	mgr.play_card(mgr.hand[0])
	assert_bool(fired).is_true()
