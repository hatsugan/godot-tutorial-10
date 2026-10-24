class_name AVFXMoveMonsterResource extends AVFXResource

@export var offsets_duration: Array[Vector2Float]

func _do(instance: AVFXInstance):
	Events.on_avfx_move.emit(instance, offsets_duration)
