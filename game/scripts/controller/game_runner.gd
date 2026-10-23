extends Node
# The main script that controls the flow of the game.

enum INTERACTION_MODE {NONE, FIGHT, ITEM, MON}
enum PHASE {AWAIT_INPUT, RESOLVE_ROUND, GAME_OVER}
enum OUTCOME {TBD, WIN, LOSE, TIE}

var game_state: GameState
var rng: RandomNumberGenerator
var game_phase: PHASE
var game_outcome: OUTCOME


# SETUP

func _ready():
	# Connect gui signal listeners
	Events.request_menu_fight.connect(handle_request_menu_fight)
	Events.request_option_selected.connect(handle_menu_option_selected)
	Events.request_menu_run.connect(handle_run_away)
	Events.request_menu_monsters.connect(handle_request_menu_monster)
	Events.request_menu_option_by_index.connect(handle_request_menu_option_by_index)
	
	Events.request_restart.connect(handle_game_restart)
	Events.request_quit.connect(handle_game_quit)
	
	Events.on_ui_ready.connect(setup_model)

func setup_model():
	game_state = GameState.new()
	rng = RandomNumberGenerator.new()
	
	game_phase = PHASE.AWAIT_INPUT
	game_outcome = OUTCOME.TBD
	
	Events.on_new_gamestate_created.emit()
	Events.request_log_clear.emit()
	
	# Create monsters
	var species_salamander = preload("res://content/species/salamander.tres")
	var species_turtle = preload("res://content/species/turtle.tres")
	var species_dino = preload("res://content/species/dino.tres")

	var monster1 = MonsterController.create_monster(species_salamander)
	var monster2 = MonsterController.create_monster(species_turtle)
	var monster3 = MonsterController.create_monster(species_dino)
	
	game_state.player = TrainerController.create_trainer([monster1, monster2], true, "Aures")
	game_state.opponent = TrainerController.create_trainer([monster3], false, "Evil Guy")

	ProjLog.info("GameRunner setup complete.")
	
	log_round_header()


# RUN GAME

func _process(_delta: float) -> void:
	
	#ProjLog.info("PHASE=%s   OUTCOME=%s"%[PHASE.find_key(game_phase), OUTCOME.find_key(game_outcome)])
	#
	#if game_outcome != OUTCOME.TBD and game_phase == PHASE.GAME_OVER:
		#pass
	
	match game_phase:
		
		PHASE.AWAIT_INPUT:
			if game_state.opponent_monster.selected_move == null:
				game_state.opponent_monster.selected_move = ai_choose_opponent_move()
			
			if game_state.player_monster.selected_move != null:
				game_phase = PHASE.RESOLVE_ROUND
		
		PHASE.RESOLVE_ROUND:
			resolve_round()
			game_phase = PHASE.AWAIT_INPUT
			resolve_fainting()
			game_state.current_round += 1
			
			log_round_header()
			
		PHASE.GAME_OVER:
			Events.on_game_over.emit(game_outcome)
		
			
	#if !game_state.is_player_turn:
		#run_ai_turn()

func resolve_round() -> void:
	var turn_order: Array[Trainer]
	
	if does_player_go_first():
		turn_order = [game_state.player, game_state.opponent]
	else: 
		turn_order = [game_state.opponent, game_state.player]

	for trainer in turn_order:
		log_turn_header(trainer)
		MonsterController.resolve_turn(trainer.current_monster)
	

func resolve_fainting() -> void:
	if game_state.player_monster.is_fainted():
		log_faint(game_state.player)
		var next_idx = TrainerController.get_next_available_monster_index(game_state.player)
		if next_idx == -1:
			pass
			Events.request_log.emit("\nAll your monsters are fainted! You lose...")
			game_phase = PHASE.GAME_OVER
			game_outcome = OUTCOME.LOSE
		else:
			TrainerController.add_trainer_monster_to_battle(game_state.player, next_idx)

	if game_state.opponent_monster.is_fainted():
		log_faint(game_state.opponent)
		var next_idx = TrainerController.get_next_available_monster_index(game_state.opponent)
		if next_idx == -1:
			Events.request_log.emit("\nAll of %s's monsters are fainted! You win!"%game_state.opponent.name)
			game_phase = PHASE.GAME_OVER
			game_outcome = OUTCOME.TIE if game_outcome == OUTCOME.LOSE else OUTCOME.WIN
		else:
			TrainerController.add_trainer_monster_to_battle(game_state.opponent, next_idx)

func does_player_go_first():
	var player_monster = game_state.player_monster
	var opponent_monster = game_state.opponent_monster
	
	assert(player_monster.selected_move != null, "Player monster does not have a move selected.")
	assert(opponent_monster.selected_move != null, "Opponent monster does not have a move selected.")
	
	# Check move priority
	if player_monster.selected_move.priority > opponent_monster.selected_move.priority:
		return true
	elif player_monster.selected_move.priority < opponent_monster.selected_move.priority:
		return false
	
	# Check monster speed if no priority difference
	else:
		if player_monster.speed == opponent_monster.speed:
			return rng_flip_coin()
		elif player_monster.speed > opponent_monster.speed:
			return true
		else:
			return false


# OPPONENT AI

func ai_choose_opponent_move() -> Move:
	var monster = game_state.opponent_monster
	var usable_move_idxs = monster.get_usable_move_indices()
	
	if usable_move_idxs.size() <= 0:
		# TODO: struggle move?
		Events.request_log.emit("%s has exhausted all its moves!"%[monster.name])
		return monster.fallback_move
	else:
		var move_idx = usable_move_idxs.pick_random()
		return MonsterController.get_monster_move_by_index(monster, move_idx)


# HANDLE INPUTS

func handle_request_menu_fight():
	if game_phase != PHASE.AWAIT_INPUT:
		return
		
	var labels: Array[StringEnabled]
	for move in game_state.player.current_monster.moves:
		labels.append(StringEnabled.new(move.resource.name, move.usages > 0))
	Events.on_menu_fight.emit(labels)

func handle_request_menu_monster():
	if game_phase != PHASE.AWAIT_INPUT:
		return
	
	var labels: Array[StringEnabled] = []
	for mon in game_state.player.monsters:
		var is_available = mon.hp > 0 and mon != game_state.player.current_monster
		labels.append(StringEnabled.new(mon.name, is_available))
	Events.on_menu_select_monster.emit(labels)

func handle_request_menu_option_by_index(mode: INTERACTION_MODE, index: int):
	if game_phase != PHASE.AWAIT_INPUT:
		return
	
	ProjLog.debug("GameRunner handle_menu_option_by_index mode={mode}, idx={idx}".format({"mode": mode, "index": index}))
	
	match(mode):
		INTERACTION_MODE.MON:
			# handling player case only
			TrainerController.add_trainer_monster_to_battle(game_state.player, index)
			
		INTERACTION_MODE.FIGHT:
			game_state.player_monster.selected_move = MonsterController.get_monster_move_by_index(game_state.player.current_monster, index)

	Events.on_menu_option_selected.emit()

func handle_menu_option_selected(mode: INTERACTION_MODE, index: int):
	if game_phase != PHASE.AWAIT_INPUT:
		return
		
	ProjLog.debug("Selecting menu option: mode=%s, index=%d"%[INTERACTION_MODE.find_key(mode), index])

func handle_run_away():
	if game_phase != PHASE.AWAIT_INPUT:
		return

	Events.request_log.emit("Call the wambulance! You ran away...")
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = 2.0
	timer.timeout.connect(handle_game_quit())
	
	timer.start()

func handle_game_restart():
	setup_model()
	
func handle_game_quit():
	get_tree().quit()

# HELPERS

func rng_flip_coin() -> bool:
	return true if rng.randi_range(0, 1) else false

func log_faint(trainer: Trainer):
	Events.request_log.emit("\nOh no! %s's %s fainted!\n" % [trainer.name, trainer.current_monster.name])

func log_round_header():
	var turn_str = "\n======  ROUND %d  ======"%[game_state.current_round]
	Events.request_log.emit(turn_str)	
	ProjLog.info("Start Round %s" % game_state.current_round, true, false)

func log_turn_header(trainer: Trainer):
	var turn_str = "-- %s's %s's Turn --" % [trainer.name, trainer.current_monster.name]
	Events.request_log.emit(turn_str)
