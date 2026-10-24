@abstract
class_name AVFXResource extends Resource

@export var target_self: bool

@abstract
func _do(instance: AVFXInstance)

func generate_instance(target: Monster) -> AVFXInstance:
	return AVFXInstance.new(self, target)
