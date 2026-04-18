class_name EmotionObject
extends RefCounted

enum Type { RAGE, GRIEF, PANIC, AWE, VOID, HOPE, CONFUSION, PRIDE, ENVY, NOSTALGIA }
enum Phase { ACTIVE, FADED, COLLAPSED, GONE }

const FADE_AT_AGE := 2
const COLLAPSE_AT_AGE := 4

var type: Type
var cell: GridCell
var age: int = 0
var aura_radius: int = 1
var echo_tokens: int = 0
var mutation_level: int = 0
var phase: Phase = Phase.ACTIVE

signal collapsed(obj: EmotionObject, power: float)

func _init(t: Type, c: GridCell, radius: int, mutation: int) -> void:
	type = t
	cell = c
	aura_radius = radius
	mutation_level = mutation

func tick() -> void:
	if phase == Phase.GONE:
		return
	age += 1
	if age == FADE_AT_AGE:
		phase = Phase.FADED
		aura_radius = max(1, aura_radius - 1)
	elif age >= COLLAPSE_AT_AGE:
		_collapse()

func _collapse() -> void:
	phase = Phase.COLLAPSED
	var power := EmotionLibrary.get_collapse_power(type, mutation_level)
	power *= (1.0 + float(echo_tokens))
	collapsed.emit(self, power)
	cell.emotion_object = null
	cell = null
	phase = Phase.GONE

func add_echo_token() -> void:
	echo_tokens += 1

## Paniek verwijderd door externe trigger, niet door age.
func force_remove() -> void:
	if cell:
		cell.emotion_object = null
		cell = null
	phase = Phase.GONE

func is_active() -> bool:
	return phase == Phase.ACTIVE or phase == Phase.FADED
