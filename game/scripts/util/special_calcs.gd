class_name SpecialCalcs

static func get_crit_chance(attacking_monster: Monster) -> float:
	var value = clamp(attacking_monster.speed / 100.0, 0.01, 0.5)
	#ProjLog.debug("critical hit chance: %f" % value)
	#ProjLog.debug("critical hit raw: %f" % (attacking_monster.speed / 100.0))
	return value
	
#static func get_crit_chance(attacking_monster: Monster, defending_monster: Monster) -> float:
	#return clamp((attacking_monster.speed - defending_monster.speed + 20) / 100, 0.01, 0.3)
