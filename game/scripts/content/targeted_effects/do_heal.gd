class_name DoHeal extends TargetedEffect

@export var base_heal: int
@export var percentage_heal_enabled: bool
@export var percentage_heal_fraction: float

func _do(doer: Monster, source: Object, game_state: GameState, does_crit: bool = false):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	if percentage_heal_enabled:
		assert(percentage_heal_fraction != null)
		
	var heal = roundi(target.base_max_hp * percentage_heal_fraction) if percentage_heal_enabled else base_heal 
	
	# APPLY HEAL (positive hp adjust)
	MonsterController.adjust_monster_hp(target, heal)
	
	var str_verb: String = "heals"
	var str_target: String = "self" if target_self else doer.name
	
	Events.request_log.emit(" {doer} {verb} {target} for {damage} hp.".format({
		"doer": doer.name,
		"verb": str_verb,
		"target": str_target,
		"damage": heal
	}))
