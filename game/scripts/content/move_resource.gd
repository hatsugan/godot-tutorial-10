class_name MoveResource extends Resource

@export var name: String
@export var type: MonsterType.Type
@export var use_message: String = "{user_name} uses {move_name}"

@export var base_accuracy: float = 0.9  # 0.0 to 1.0
@export var priority: int = 0

@export var usage_max: int = 20
@export var use_effects: Array[TargetedEffect]
