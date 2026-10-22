class_name Monster

var species: SpeciesResource
var hp: int
var nickname: String
var moves: Array[Move]
var conditions: Array[Condition]

var image: Texture2D:
	get: return species.image
	
var name: String:
	get: return nickname if nickname else species.name
	
var type: MonsterType.Type:
	get: return species.type

# Stats
var base_max_hp: int:
	get: return species.base_max_hp
var max_hp: int:
	get: return clamp(base_max_hp + sum_condition_stats_by_code(Stat.Code.MAX_HP), StatLimits.minStat, StatLimits.maxStat)

var base_attack: int:
	get: return species.base_attack
var attack: int:
	get: return clamp(base_attack + sum_condition_stats_by_code(Stat.Code.ATK), StatLimits.minStat, StatLimits.maxStat)

var base_defence: int:
	get: return species.base_defence
var defence: int:
	get: return clamp(base_defence + sum_condition_stats_by_code(Stat.Code.DEF), StatLimits.minStat, StatLimits.maxStat)

var base_speed: int:
	get: return species.base_speed
var speed: int:
	get: return clamp(base_speed + sum_condition_stats_by_code(Stat.Code.SPE), StatLimits.minStat, StatLimits.maxStat)


# Getters

func sum_condition_stats_by_code(code: Stat.Code):
	var sum = 0
	for condition in conditions:
		for stat_modifier in condition.resource.stat_modifiers:
			if stat_modifier.stat_code == code:
				sum += stat_modifier.mod_add
	return sum

func get_usable_move_indices() -> Array[int]:
	var usable_idxs: Array[int] = []
	for i in range(0, moves.size()):
		if moves[i] and moves[i].usages > 0:
			usable_idxs.append(i)
	return usable_idxs

func dump_state() -> String:
	var conditions_string = ""
	for condition in conditions:
		conditions_string += condition.name + ", "
	
	var moves_string = ""
	for move in moves:
		moves_string += " " + move.name + ", acc {acc}% ({u}/{um})\n".format({
			"acc": move.base_accuracy*100,
			"u": move.usages,
			"um": move.max_usages
		})
	
	var state_string = "
	NAME: {name}
	SPECIES: {species}
	HP: {hp}/{max_hp} ({base_max_hp})
	ATK: {attack} ({base_attack})
	DEF: {defence} ({base_defence})
	SPE: {speed} ({base_speed})
	CONDITIONS: {conditions}
	MOVES: \n{moves}
	".format({
		"name": name,
		"species": species.name,
		"hp": hp,
		"max_hp": max_hp,
		"base_max_hp": base_max_hp,
		"attack": attack,
		"base_attack": base_attack,
		"defence": defence,
		"base_defence": base_defence,
		"speed": speed,
		"base_speed": base_speed,
		"conditions": conditions_string,
		"moves": moves_string
	})
	
	return state_string
