class_name Vector2Float extends Resource

@export var vec2: Vector2
@export var f: float

func _init(vec2_x: float = 0.0, vec2_y: float = 0.0, f_val: float = 0.0) -> void:
	vec2 = Vector2(vec2_x, vec2_y)
	f = f_val
