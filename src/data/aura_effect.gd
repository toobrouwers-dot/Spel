class_name AuraEffect
extends RefCounted

enum EffectType { NONE, DAMAGE_PER_TURN, SLOW, AMPLIFY, ATTRACT_AURAS }

var effect_type: EffectType = EffectType.NONE
var value: float = 0.0
var source: EmotionObject

static func none() -> AuraEffect:
	return AuraEffect.new()

static func damage_per_turn(amount: float, src: EmotionObject) -> AuraEffect:
	var e := AuraEffect.new()
	e.effect_type = EffectType.DAMAGE_PER_TURN
	e.value = amount
	e.source = src
	return e

static func slow(duration: float, src: EmotionObject) -> AuraEffect:
	var e := AuraEffect.new()
	e.effect_type = EffectType.SLOW
	e.value = duration
	e.source = src
	return e

static func amplify(multiplier: float, src: EmotionObject) -> AuraEffect:
	var e := AuraEffect.new()
	e.effect_type = EffectType.AMPLIFY
	e.value = multiplier
	e.source = src
	return e
