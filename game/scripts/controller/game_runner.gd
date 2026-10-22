extends Node

# The main script that controls the flow of the game.

# INTERACTION_MODE encodes the menu states the main battle menu can be in.
# Since RUN isn't a special menu, it does not get an entry here
enum INTERACTION_MODE {NONE, FIGHT, ITEM, MON}

var game_state: GameState
var rng: RandomNumberGenerator

func _ready():
	# Connect signal listeners
	Events.request_menu_fight.connect(handle_request_menu_fight)
	Events.request_option_selected.connect(handle_menu_option_selected)
	Events.request_menu_run.connect(handle_run)
	Events.request_menu_monsters.connect(handle_request_menu_monster)
	Events.request_menu_option_by_index.connect(handle_menu_option_by_index)
	
	Events.on_ui_ready.connect(setup_model)
	
func _process(_delta: float) -> void:
	if !game_state.is_player_turn:
		run_ai_turn()
	
func setup_model():
	game_state = GameState.new()
	rng = RandomNumberGenerator.new()
	
	Events.on_new_gamestate_created.emit()
	
	# Create monsters
	var species_salamander = preload("res://content/species/salamander.tres")
	var species_turtle = preload("res://content/species/turtle.tres")
	var species_dino = preload("res://content/species/dino.tres")

	var monster1 = MonsterController.create_monster(species_salamander)
	var monster2 = MonsterController.create_monster(species_turtle)
	var monster3 = MonsterController.create_monster(species_dino)
	
	game_state.player = TrainerController.create_trainer([monster1, monster2], true)
	game_state.opponent = TrainerController.create_trainer([monster3], false)
	
	# Basic turn order
	# TODO: Make better
	game_state.is_player_turn = game_state.player_monster.speed >= game_state.opponent_monster.speed
	log_round_header()
	log_turn_header()
	return
	
func handle_request_menu_fight():
	var labels: Array[StringEnabled]
	for move in game_state.player.current_monster.moves:
		labels.append(StringEnabled.new(move.resource.name, move.usages > 0))
	Events.on_menu_fight.emit(labels)
	
func handle_request_menu_monster():
	var labels: Array[StringEnabled] = []
	for mon in game_state.player.monsters:
		var is_available = mon.hp > 0 and mon != game_state.player.current_monster
		labels.append(StringEnabled.new(mon.name, is_available))
	Events.on_menu_select_monster.emit(labels)

func handle_menu_option_by_index(mode: INTERACTION_MODE, index: int):
	print(mode, index)
	
	match(mode):
		INTERACTION_MODE.MON:
			# handling player case only
			TrainerController.add_trainer_monster_to_battle(game_state.player, index)
			
		INTERACTION_MODE.FIGHT:
			MonsterController.use_monster_move_by_index(game_state.player.current_monster, index)
		

	
	Events.on_menu_option_selected.emit()


func handle_menu_option_selected(mode: INTERACTION_MODE, index: int):
	print("Selecting mode: %s  number: %d"%[mode, index])
	
	
func handle_run():
	Events.request_log.emit("Call the wambulance! You ran away...")
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = 2.0
	timer.timeout.connect(func(): get_tree().quit())
	
	timer.start()
	
	
func log_round_header():
	var turn_str = "\n======  ROUND %d  ======"%[game_state.current_round]
	Events.request_log.emit(turn_str)	
	
func log_turn_header():
	var turn_str = "-- Player Turn --" if game_state.is_player_turn else "-- Opponent Turn --"
	Events.request_log.emit(turn_str)
	
	
func on_turn_begun():
	var monster = MonsterController.get_current_monster()
	log_turn_header()
	
	for condition in monster.conditions:
		for effect in condition.resource.on_begin_turn_effects:
			effect._do(monster, condition, game_state)
		condition.duration_remaining -= 1
		if condition.duration_remaining <= 0:
			MonsterController.end_condition(monster, condition)
	
func on_turn_ended():
	game_state.is_player_turn = !game_state.is_player_turn
	game_state.num_turns += 1
	if game_state.num_turns % 2 == 0:
		game_state.current_round += 1
		log_round_header()
		
	on_turn_begun()
	
func run_ai_turn():
	var monster = game_state.opponent_monster
	var usable_move_idxs = monster.get_usable_move_indices()
	
	if usable_move_idxs.size() <= 0:
		# TODO: struggle move?
		Events.request_log.emit("%s has exhausted all its moves!"%[monster.name])
		on_turn_ended()
	else:
		var move_idx = usable_move_idxs.pick_random()
		MonsterController.use_monster_move_by_index(monster, move_idx)
		#Events.on_monster_updated.emit(monster)
		#on_turn_ended()
