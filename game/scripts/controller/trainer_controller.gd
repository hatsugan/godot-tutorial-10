extends Node

var game_state: GameState
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_new_gamestate_created.connect(get_controller_components)

func get_controller_components():
	game_state = GameRunner.game_state
	rng = GameRunner.rng
	
func create_trainer(monsters: Array[Monster], is_player: bool, name: String) -> Trainer:
	var trainer = Trainer.new()
	trainer.is_player = is_player
	trainer.monsters = monsters
	trainer.name = name
	add_trainer_monster_to_battle(trainer, 0)
	return trainer
	
func add_trainer_monster_to_battle(trainer: Trainer, monster_idx: int):
	var selected_mon = trainer.monsters[monster_idx]
	trainer.current_monster_index = monster_idx
	Events.on_monster_added_to_battle.emit(selected_mon, trainer.is_player)
	Events.request_log.emit("{player_name} sent out a monster!\n  \"Go, {monster_name}!\""\
		.format({"player_name": trainer.name, "monster_name": selected_mon.name}))

func get_next_available_monster_index(trainer: Trainer) -> int:
	for idx in range(trainer.monsters.size()):
		if not trainer.monsters[idx].is_fainted():
			return idx
	
	# No monsters are available:
	return -1
	
