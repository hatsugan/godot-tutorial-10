class_name TargetedEffect extends Resource

enum OutcomeFilter {
	HIT,
	MISS,
	BOTH,
	CRIT
}

@export var outcome_filter: OutcomeFilter
@export var target_self: bool

func _do(doer: Monster, source: Object, game_state: GameState, does_crit: bool = false):
	return

func _should_do(does_hit: bool, does_crit: bool = false):
	return outcome_filter == OutcomeFilter.BOTH \
	or (does_hit and outcome_filter == OutcomeFilter.HIT) \
	or (!does_hit and outcome_filter == OutcomeFilter.MISS) \
	or (does_crit and outcome_filter == OutcomeFilter.CRIT)
