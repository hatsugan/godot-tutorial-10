class_name Move

var resource: MoveResource
var usages: int

var type: MonsterType.Type:
	get: return resource.type

var name: String:
	get: return resource.name

var use_message: String:
	get: return resource.use_message

var base_accuracy: float:
	get: return resource.base_accuracy	

var priority: float:
	get: return resource.priority

var max_usages: int:
	get: return resource.usage_max

# for duck typing in TargetedEffect
func get_type() -> MonsterType.Type:
	return type

#func do_all_avfx(instance: AVFXInstance) -> void:
	#for avfx in resource.avfx_on_use:
		#avfx._do(instance)
