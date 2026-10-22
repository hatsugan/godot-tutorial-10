class_name Move

var usages: int
var resource: MoveResource
	
var type: MonsterType.Type:
	get: return resource.type
	
var name: String:
	get: return resource.name
	
var use_message: String:
	get: return resource.use_message
	
var base_accuracy: float:
	get: return resource.base_accuracy
	
var max_usages: int:
	get: return resource.usage_max

# for duck typing in TargetedEffect
func get_type() -> MonsterType.Type:
	return type
