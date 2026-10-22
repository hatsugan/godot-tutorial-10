class_name DoDamage extends TargetedEffect

@export var base_damage: int
@export var ignore_stats: bool
@export var ignore_type: bool
@export var effect_verb_str: String = "hits"

func _do(doer: Monster, source: Object, game_state: GameState):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	var is_condition: bool = source.get_script().get_global_name() == "Condition"
	
	# Duck typing with type
	var source_type = source.get_type() if source.has_method("get_type") else MonsterType.Type.NORMAL
	
	# Damage Type Multiplier
	var factor_type_effectiveness: float = MonsterType.get_factor_type_effectiveness(\
	source_type, target.type)
	factor_type_effectiveness = 1 if ignore_type else factor_type_effectiveness
	
	# Damage Stat Difference Multiplier
	var factor_stat_diff: float = doer.attack / max(target.defence, 1) 
	factor_stat_diff = 1 if ignore_stats else factor_stat_diff

	# Damage Calculation
	var damage = clamp(factor_type_effectiveness * factor_stat_diff * base_damage, StatLimits.minHP, StatLimits.maxHP)
	MonsterController.adjust_monster_hp(target, -damage)
	
	#print("DoDamage: base_damage=%d"%[base_damage])
	
	var str_target: String = "self" if target_self and !is_condition else target.name
	
	if is_condition:
		Events.request_log.emit("{target} is {verb} by {cond_name} for {damage} damage.".format({
			"target": str_target,
			"verb": effect_verb_str,
			"cond_name": source.name,
			"damage": damage
		}))
	else:
		Events.request_log.emit(" {doer} {verb} {target} for {damage} damage.".format({
			"doer": doer.name,
			"verb": effect_verb_str,
			"target": str_target,
			"damage": damage
		}))
	
	
	if factor_type_effectiveness < 1.0:
		Events.request_log.emit("   It was not very effective...")
	elif factor_type_effectiveness > 1.0:
		Events.request_log.emit("   It was super effective!")
	
