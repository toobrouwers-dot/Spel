class_name EmotionCard
extends Resource

@export var emotion_type: EmotionObject.Type
@export var mutation_level: int = 0
@export var display_name: String
@export var description: String
@export var icon: Texture2D

func get_aura_radius() -> int:
	return EmotionLibrary.get_aura_radius(emotion_type, mutation_level)
