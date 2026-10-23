class_name DoDamage extends TargetedEffect

@export var base_damage: int
@export var ignore_stats: bool
@export var ignore_type: bool
@export var percentage_damage_enabled: bool
@export var percentage_damage_fraction: float
@export var effect_verb_str: String = "hits"
@export var crit_damage_factor = 1.5

func _do(doer: Monster, source: Object, game_state: GameState, does_crit: bool = false):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	var damage: int = 0
	var factor_type_effectiveness: float
	var factor_stat_diff: float
	
	var factor_crit = crit_damage_factor if does_crit else 1.0
	
	# Duck typing with type
	var source_type = source.get_type() if source.has_method("get_type") else MonsterType.Type.NORMAL
	
	# -- RESOLVE DAMAGE --
	# PERCENTAGE DAMAGE
	if percentage_damage_enabled:
		assert(percentage_damage_fraction != null)
		damage = roundi(target.base_max_hp * percentage_damage_fraction * factor_crit)
	
	# NUMERICAL DAMAGE
	else:
		# Type Difference Factor
		factor_type_effectiveness = MonsterType.get_factor_type_effectiveness(\
		source_type, target.type)
		factor_type_effectiveness = 1 if ignore_type else factor_type_effectiveness
		
		# Stat Difference Factor
		factor_stat_diff = doer.attack / max(target.defence, 1) 
		factor_stat_diff = 1 if ignore_stats else factor_stat_diff

		damage = clamp(factor_type_effectiveness * factor_stat_diff * base_damage * factor_crit, \
			1, StatLimits.maxHP)
	
	# APPLY DAMAGE (Negative hp adjust)
	MonsterController.adjust_monster_hp(target, -damage)
	
	
	# -- BATTLE LOG --
	var is_condition: bool = source.get_script().get_global_name() == "Condition"
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
	
	if not percentage_damage_enabled:
		if factor_type_effectiveness < 1.0:
			Events.request_log.emit("   It was not very effective...")
		elif factor_type_effectiveness > 1.0:
			Events.request_log.emit("   It was super effective!")
	
