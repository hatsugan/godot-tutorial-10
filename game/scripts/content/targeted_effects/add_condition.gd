class_name AddCondition extends TargetedEffect

@export var condition_resource: ConditionResource

func _do(doer: Monster, source: Move, game_state: GameState):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	# Create a new condition from resource and add it to targets
	MonsterController.instantiate_condition_on_monster(target, condition_resource)
	
	return
