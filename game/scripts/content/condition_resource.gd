class_name ConditionResource extends Resource

@export var name: String
@export var stat_modifiers: Array[StatModResource]
@export var on_begin_turn_effects: Array[TargetedEffect]
@export var duration: int
@export var max_stack: int
@export var short_name: String
@export var application_str: String = "{monster_name} got condition"
