extends Node

var game_state: GameState
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_new_gamestate_created.connect(get_controller_components)

func get_controller_components():
	game_state = GameRunner.game_state
	rng = GameRunner.rng

func get_monster_opponent(monster: Monster) -> Monster:
	if monster == game_state.player_monster:
		return game_state.opponent_monster
	elif monster == game_state.opponent_monster:
		return game_state.player_monster
	else:
		push_error("monster is neither player nor opponent monster")
		return null
		
func adjust_monster_hp(monster: Monster, amount: int):
	monster.hp = clamp(monster.hp + amount, 0, monster.max_hp)
	
	Events.on_monster_updated.emit(monster)
	# TODO check fainting
	
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
	
	return monster
	
func get_current_monster() -> Monster:
	if game_state.is_player_turn:
		return game_state.player_monster
	else:
		return game_state.opponent_monster

func use_monster_move_by_index(monster: Monster, move_idx: int):
	var move = monster.moves[move_idx]
	
	# Log move use attempt
	var use_message = move.use_message.format({"user_name": monster.name, "move_name": move.name})
	Events.request_log.emit(use_message)
		
	if move.usages < 1:
		Events.request_log.emit(" But it failed...")
		GameRunner.on_turn_ended()
		return
	
	# Check move not blocked
	if monster.move_blocked:
		Events.request_log.emit(" But if failed. %s cannot move..."%[monster.name])
		monster.move_blocked = false
		GameRunner.on_turn_ended()
		return
	
	move.usages -= 1
	
	var rngf = rng.randf()
	var move_acc = move.base_accuracy
	print("move acc=%f rngf=%f"%[move_acc, rngf])
	var does_hit = rngf < move_acc
	
	if !does_hit:
		Events.request_log.emit("   But it misses!")
	for effect in move.resource.use_effects:
		if effect._should_do(does_hit):
			effect._do(monster, move, game_state)
			
	Events.on_monster_updated.emit(monster)
	GameRunner.on_turn_ended()

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
	
