class_name MonsterType

enum Type {
	DIRECT,
	NORMAL,
	FIRE,
	WATER,
	GRASS
}

enum Effectiveness {
	NEUTRAL,
	WEAK,
	STRONG
}

const DAMAGE_MOD_BY_EFFECT: Dictionary[Effectiveness, float] = {
	Effectiveness.WEAK: 0.5,
	Effectiveness.NEUTRAL: 1.0,
	Effectiveness.STRONG: 2.0
}

# Source -> Target:Effectiveness
const EFFECTIVENESS_BY_TYPE: Dictionary[Type, Dictionary] = {
	Type.NORMAL: {},
	Type.FIRE: {
		Type.GRASS: Effectiveness.STRONG,
		Type.WATER: Effectiveness.WEAK
	},
	Type.WATER: {
		Type.FIRE: Effectiveness.STRONG,
		Type.GRASS: Effectiveness.WEAK
	},
	Type.GRASS: {
		Type.WATER: Effectiveness.STRONG,
		Type.FIRE: Effectiveness.WEAK
	}
}

static func get_factor_type_effectiveness(source_type: Type, target_type: Type) -> float:
	if !EFFECTIVENESS_BY_TYPE.has(source_type) or !EFFECTIVENESS_BY_TYPE[source_type].has(target_type):
		return 1.0
	else:
		var effectiveness = EFFECTIVENESS_BY_TYPE[source_type][target_type]
		return DAMAGE_MOD_BY_EFFECT[effectiveness]
	
