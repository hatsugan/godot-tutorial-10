extends Node

var game_state: GameState
var rng: RandomNumberGenerator

@onready var fallback_move = load("res://content/moves/struggle.tres")


# SETUP

func _ready() -> void:
	Events.on_new_gamestate_created.connect(setup_controller_components)

func setup_controller_components():
	game_state = GameRunner.game_state
	rng = GameRunner.rng

func create_monster(species: SpeciesResource, nickname: String = "") -> Monster:
	var monster = Monster.new()
	monster.species = species
	monster.hp = species.base_max_hp
	monster.nickname = nickname
	
	var moves: Array[Move] = []
	
	for _move_res in species.starter_moves:
		if _move_res == null:
			continue
		var move = Move.new()
		move.usages = _move_res.usage_max
		move.resource = _move_res
		moves.append(move)
	
	monster.moves = moves
	
	monster.fallback_move = Move.new()
	monster.fallback_move.resource = fallback_move
	monster.fallback_move.usages = 9999

	return monster


# GETTERS

func get_monster_opponent(monster: Monster) -> Monster:
	if monster == game_state.player_monster:
		return game_state.opponent_monster
	elif monster == game_state.opponent_monster:
		return game_state.player_monster
	else:
		push_error("monster is neither player nor opponent monster")
		return null

func get_current_monster() -> Monster:
	if game_state.is_player_turn:
		return game_state.player_monster
	else:
		return game_state.opponent_monster


# MOVES

func get_monster_move_by_index(monster: Monster, move_idx: int):
	return monster.moves[move_idx]

func use_monster_move_by_index(monster: Monster, move_idx: int):
	use_monster_move(monster, get_monster_move_by_index(monster, move_idx))

func use_monster_move(monster: Monster, move: Move):
	# Log move use attempt
	var use_message = move.use_message.format({"user_name": monster.name, "move_name": move.name})
	Events.request_log.emit(use_message)
		
	if move.usages < 1 or monster.is_fainted():
		Events.request_log.emit(" But it failed...")
		return
	
	if get_monster_opponent(monster).is_fainted():
		monster.move_blocked = false
		return
	
	# Check move not blocked
	if monster.move_blocked:
		Events.request_log.emit(" But if failed. %s cannot move..."%[monster.name])
		monster.move_blocked = false
		return
	
	move.usages -= 1
	
	var move_acc = move.base_accuracy
	
	# HIT RNG
	var does_hit = rng.randf() < move_acc
	if !does_hit:
		Events.request_log.emit("   But it misses!")
	
	# CRIT RNG
	var does_crit = rng.randf() < SpecialCalcs.get_crit_chance(monster)
	if does_crit and does_hit:
		Events.request_log.emit(" Critical hit!")
	
	# RESOLVE EFFECTS
	for effect in move.resource.use_effects:
		if effect._should_do(does_hit, does_crit):
			effect._do(monster, move, game_state, does_crit)
			
	Events.on_monster_updated.emit(monster)


# CONDITIONS

func instantiate_condition_on_monster(monster: Monster, condition_resource: ConditionResource):
	# NOTE Lambda filter NEEDS a return!!
	var num_current_conditions = monster.conditions.filter(func(condition): return condition.resource == condition_resource).size()
	if num_current_conditions < condition_resource.max_stack:
		var condition = Condition.new()
		condition.resource = condition_resource
		condition.duration_remaining = condition.resource.duration
		monster.conditions.append(condition)
	
	Events.request_log.emit(" " + condition_resource.application_str.format({"monster_name": monster.name}))
	Events.on_monster_updated.emit(monster)

func end_condition(monster: Monster, condition: Condition):
	monster.conditions.remove_at(monster.conditions.find(condition))
	
	Events.on_monster_updated.emit(monster)


# RESOLVE TURN

func adjust_monster_hp(monster: Monster, amount: int):
	monster.hp = clamp(monster.hp + amount, 0, monster.max_hp)
	
	if monster.hp == 0:
		faint_monster(monster)
	
	Events.on_monster_updated.emit(monster)

func faint_monster(monster) -> void:
	pass

func resolve_turn(monster: Monster) -> void:
	if monster.hp == 0:
		return
	
	resolve_condition_effects(monster)
	use_monster_move(monster, monster.selected_move)
	# Cleanup
	monster.clear_ephemeral()

func resolve_condition_effects(monster: Monster):
	for condition in monster.conditions:
		for effect in condition.resource.on_begin_turn_effects:
			effect._do(monster, condition, game_state)
		condition.duration_remaining -= 1
		if condition.duration_remaining <= 0:
			MonsterController.end_condition(monster, condition)
