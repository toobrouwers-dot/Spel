class_name EmotionConfig
extends Resource

## Balance data voor alle emotie-typen per mutatieniveau (0/1/2).
## Bewerkt via Godot Inspector — nooit hardcoded in GDScript.

@export var entries: Array[EmotionConfigEntry] = []

func get_value(key: String, type: EmotionObject.Type, level: int) -> Variant:
	for entry in entries:
		if entry.emotion_type == type and entry.mutation_level == level:
			match key:
				"aura_radius":    return entry.aura_radius
				"collapse_power": return entry.collapse_power
				"aura_damage":    return entry.aura_damage
	return null
