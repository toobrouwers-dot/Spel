class_name EmotionLibrary
extends RefCounted

## All balance values loaded from external resource — never hardcoded here.
static var _config: Resource

static func get_aura_radius(type: EmotionObject.Type, level: int) -> int:
	return _get_int("aura_radius", type, level, 1)

static func get_collapse_power(type: EmotionObject.Type, level: int) -> float:
	return _get_float("collapse_power", type, level, 5.0)

static func get_aura_damage(type: EmotionObject.Type, level: int) -> float:
	return _get_float("aura_damage", type, level, 0.0)

static func build_aura_effect(
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

static func _get_int(key: String, type: EmotionObject.Type, level: int, default: int) -> int:
	if _config and _config.has_method("get_value"):
		return _config.get_value(key, type, level)
	return default

static func _get_float(key: String, type: EmotionObject.Type, level: int, default: float) -> float:
	if _config and _config.has_method("get_value"):
		return float(_config.get_value(key, type, level))
	return default
