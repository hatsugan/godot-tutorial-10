class_name DoDamage extends TargetedEffect

@export var base_damage: int

func _do(doer: Monster, source: Move, game_state: GameState):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	# Damage Type Multiplier
	var effectiveness_multiplier: float = MonsterType.get_effectiveness_multiplier(\
	source.type, target.type)
	
	# Damage Stat Difference Multiplier
	var stat_diff_multiplier: float = doer.attack / max(target.defence, 1)
	
	# Damage Calculation
	var damage = clamp(effectiveness_multiplier * stat_diff_multiplier * base_damage, StatLimits.minHP, StatLimits.maxHP)
	MonsterController.adjust_monster_hp(target, -damage)
	
	#print("DoDamage: base_damage=%d"%[base_damage])
	
	var str_verb: String = "hits"
	var str_target: String = "self" if target_self else target.name
	
	Events.request_log.emit(" {doer} {verb} {target} for {damage} damage.".format({
		"doer": doer.name,
		"verb": str_verb,
		"target": str_target,
		"damage": damage
	}))
	if effectiveness_multiplier < 1.0:
		Events.request_log.emit("   It was not very effective...")
	elif effectiveness_multiplier > 1.0:
		Events.request_log.emit("   It was super effective!")
	
