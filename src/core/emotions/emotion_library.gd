class_name EmotionLibrary
extends Node

const CONFIG_PATH := "res://assets/data/emotion_config.tres"

## Fallback defaults wanneer config niet geladen is of entry ontbreekt.
const _DEFAULTS := {
	"aura_radius":    { 0: 1, 1: 2, 2: 3 },
	"collapse_power": { 0: 5.0, 1: 10.0, 2: 18.0 },
	"aura_damage":    { 0: 0.0, 1: 0.0, 2: 0.0 },
}

var _config: EmotionConfig

func _ready() -> void:
	if ResourceLoader.exists(CONFIG_PATH):
		_config = load(CONFIG_PATH) as EmotionConfig

func get_aura_radius(type: EmotionObject.Type, level: int) -> int:
	return _get_int("aura_radius", type, level, 1)

func get_collapse_power(type: EmotionObject.Type, level: int) -> float:
	return _get_float("collapse_power", type, level, 5.0)

func get_aura_damage(type: EmotionObject.Type, level: int) -> float:
	return _get_float("aura_damage", type, level, 0.0)

func build_aura_effect(
		type: EmotionObject.Type,
		level: int,
		source: EmotionObject) -> AuraEffect:
	match type:
		EmotionObject.Type.RAGE:
			return AuraEffect.damage_per_turn(get_aura_damage(type, level), source)
		EmotionObject.Type.GRIEF:
			return AuraEffect.slow(1.0, source)
		EmotionObject.Type.AWE:
			return AuraEffect.amplify(1.5, source)
		_:
			return AuraEffect.none()

func _get_int(key: String, type: EmotionObject.Type, level: int, default: int) -> int:
	if _config:
		var val: Variant = _config.get_value(key, type, level)
		if val != null:
			return int(val)
	return _DEFAULTS.get(key, {}).get(level, default)

func _get_float(key: String, type: EmotionObject.Type, level: int, default: float) -> float:
	if _config:
		var val: Variant = _config.get_value(key, type, level)
		if val != null:
			return float(val)
	return float(_DEFAULTS.get(key, {}).get(level, default))
