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

func use_monster_move_by_index(monster: Monster, move_idx: int):
	var move = monster.moves[move_idx]
	
	if move.usages < 1:
		return
	move.usages -= 1
	
	var use_message = move.use_message.format({"user_name": monster.name, "move_name": move.name})
	Events.request_log.emit(use_message)
	
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
	var condition = Condition.new()
	condition.resource = condition_resource
	monster.conditions.append(condition)
	
	Events.on_monster_updated.emit(monster)
