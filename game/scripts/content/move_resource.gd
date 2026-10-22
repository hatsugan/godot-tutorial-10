class_name MoveResource extends Resource

@export var name: String
@export var usage_max: int
@export var use_effects: Array[TargetedEffect]
@export var type: MonsterType.Type
@export var use_message: String = "{user_name} uses {move_name}"
@export var base_accuracy: float = 0.9  # 0.0 to 1.0
