class_name EnemyEntity
extends CombatEntity

## Attraction weights per emotion type. Positive = attracted, negative = repelled.
## Range: -2 (strongly repelled) to +2 (strongly attracted).
@export var emotion_responses: Dictionary[EmotionObject.Type, int] = {}
@export var attack_damage: int = 5
@export var move_speed: int = 1  # cells per turn

func get_response(emotion_type: EmotionObject.Type) -> int:
	return emotion_responses.get(emotion_type, 0)
