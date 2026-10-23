class_name BlockMove extends TargetedEffect

@export var chance_to_block: float = 0.5

func _do(doer: Monster, source: Object, game_state: GameState, does_crit: bool = false):
	var target = doer if target_self else MonsterController.get_monster_opponent(doer)
	
	if GameRunner.rng.randf() < chance_to_block:
		target.move_blocked = true
