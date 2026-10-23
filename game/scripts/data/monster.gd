class_name Monster

var nickname: String
var fallback_move: Move

# SPECIES INHERENT

var species: SpeciesResource
var name: String:
	get: return nickname if nickname else species.name
var type: MonsterType.Type:
	get: return species.type
var image: Texture2D:
	get: return species.image

# STATE

var hp: int
var moves: Array[Move]
var conditions: Array[Condition]
var move_blocked: bool
# Ephemeral
var selected_move

func is_fainted() -> bool:
	return true if hp <= 0 else false

# STATS

var base_max_hp: int:
	get: return species.base_max_hp
var max_hp: int:
	get: return clamp(resolve_stat_per_conditions_by_code(Stat.Code.MAX_HP), StatLimits.minStat, StatLimits.maxStat)

var base_attack: int:
	get: return species.base_attack
var attack: int:
	get: return clamp(resolve_stat_per_conditions_by_code(Stat.Code.ATK), StatLimits.minStat, StatLimits.maxStat)

var base_defence: int:
	get: return species.base_defence
var defence: int:
	get: return clamp(resolve_stat_per_conditions_by_code(Stat.Code.DEF), StatLimits.minStat, StatLimits.maxStat)

var base_speed: int:
	get: return species.base_speed
var speed: int:
	get: return clamp(resolve_stat_per_conditions_by_code(Stat.Code.SPE), StatLimits.minStat, StatLimits.maxStat)

func get_base_stat_by_code(code: Stat.Code):
	match code:
		Stat.Code.MAX_HP:
			return base_max_hp
		Stat.Code.ATK:
			return base_attack
		Stat.Code.DEF:
			return base_defence
		Stat.Code.SPE:
			return base_speed

func resolve_stat_per_conditions_by_code(code: Stat.Code):
	var result = get_base_stat_by_code(code)
	
	for condition in conditions:
		for stat_modifier in condition.resource.stat_modifiers:
			if stat_modifier.stat_code == code:
				#if stat_modifier.ModMode == StatModResource.ModMode.ADD:
					#result += stat_modifier.mod_add
				#elif stat_modifier.ModMode == StatModResource.ModMode.MUL:
					#result *= stat_modifier.mod_mul
				match stat_modifier.mod_mode:
					StatModResource.ModMode.ADD:
						result += stat_modifier.mod_add
					StatModResource.ModMode.MUL:
						result *= stat_modifier.mod_mul
	
	return result


# -- METHODS --

# CLEANUP

func clear_ephemeral() -> void:
	selected_move = null

# DATA DUMP

func get_condition_string():
	if conditions.size() == 0:
		return ""
	else:
		return conditions[0].resource.short_name

func get_usable_move_indices() -> Array[int]:
	var usable_idxs: Array[int] = []
	for i in range(0, moves.size()):
		if moves[i] and moves[i].usages > 0:
			usable_idxs.append(i)
	return usable_idxs

func dump_state() -> String:
	var conditions_string = ""
	for condition in conditions:
		conditions_string += "\n " + condition.name + " (%s)"%[condition.duration_remaining]
	
	var moves_string = ""
	for move in moves:
		moves_string += " " + move.name + " -- acc {acc}% ({u}/{um})\n".format({
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
