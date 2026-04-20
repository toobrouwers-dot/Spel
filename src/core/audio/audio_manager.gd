class_name AudioManager
extends Node

## Procedurele audio voor FRACTURE — genereert PCM16-tonen zonder externe bestanden.
## Gebruik: AudioManager.play_card_played() etc. (autoload)

const SAMPLE_RATE := 44100
const MAX_AMPLITUDE := 28000
const POOL_SIZE := 8

var _players: Array[AudioStreamPlayer] = []
var _player_index: int = 0

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

# --- Game events ---

func play_card_played() -> void:
	_play(880.0, 0.09, -4.0, 0.005, 0.06)

func play_emotion_collapse() -> void:
	_play(260.0, 0.38, -2.0, 0.01, 0.32)

func play_resonance() -> void:
	_play(440.0, 0.55, -8.0, 0.01, 0.4)
	_play(550.0, 0.55, -8.0, 0.01, 0.4)
	_play(660.0, 0.55, -8.0, 0.01, 0.4)

func play_player_hit() -> void:
	_play(180.0, 0.22, 0.0, 0.004, 0.18)

func play_enemy_hit() -> void:
	_play(110.0, 0.16, -3.0, 0.004, 0.13)

func play_panic_on() -> void:
	_play(620.0, 0.28, -5.0, 0.01, 0.2)

func play_turn_tick() -> void:
	_play(1400.0, 0.045, -10.0, 0.003, 0.03)

func play_card_drawn() -> void:
	_play(1100.0, 0.06, -8.0, 0.004, 0.04)

func play_fight_won() -> void:
	var freqs := [440.0, 550.0, 660.0, 880.0, 1100.0]
	for i in freqs.size():
		var freq: float = freqs[i]
		get_tree().create_timer(i * 0.1).timeout.connect(
			func() -> void: _play(freq, 0.3, -5.0, 0.01, 0.25)
		)

func play_fight_lost() -> void:
	var freqs := [330.0, 275.0, 220.0, 165.0]
	for i in freqs.size():
		var freq: float = freqs[i]
		get_tree().create_timer(i * 0.18).timeout.connect(
			func() -> void: _play(freq, 0.45, -3.0, 0.01, 0.4)
		)

# --- Internals ---

func _play(frequency: float, duration: float, volume_db: float,
		attack: float, decay: float) -> void:
	var player := _get_free_player()
	player.stream = _generate_sine(frequency, duration, attack, decay)
	player.volume_db = volume_db
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for i in POOL_SIZE:
		var idx := (_player_index + i) % POOL_SIZE
		if not _players[idx].playing:
			_player_index = (idx + 1) % POOL_SIZE
			return _players[idx]
	_player_index = (_player_index + 1) % POOL_SIZE
	return _players[_player_index]

func _generate_sine(frequency: float, duration: float,
		attack: float, decay: float) -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	var attack_s := int(SAMPLE_RATE * attack)
	var decay_s := int(SAMPLE_RATE * decay)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		var sample := sin(TAU * frequency * t)

		var env := 1.0
		if i < attack_s and attack_s > 0:
			env = float(i) / attack_s
		elif i >= num_samples - decay_s and decay_s > 0:
			env = float(num_samples - i) / decay_s

		var value := clamp(int(sample * env * MAX_AMPLITUDE), -32768, 32767)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BIT
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	return stream
