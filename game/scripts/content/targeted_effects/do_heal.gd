class_name DoHeal extends TargetedEffect

@export var base_heal: int

func _do(doer: Monster, source: Object, game_state: GameState):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	var heal = base_heal
	MonsterController.adjust_monster_hp(target, heal)
	#print("DoDamage: base_damage=%d"%[base_damage])
	
	var str_verb: String = "heals"
	var str_target: String = "self" if target_self else doer.name
	
	Events.request_log.emit("{doer} {verb} {target} for {damage} hp.".format({
		"doer": doer.name,
		"verb": str_verb,
		"target": str_target,
		"damage": heal
	}))
