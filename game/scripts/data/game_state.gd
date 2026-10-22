class_name GameState

var player: Trainer
var opponent: Trainer
var is_player_turn: bool
var current_round: int = 1
var num_turns: int = 0

var player_monster: Monster:
	get: return player.current_monster
	
var opponent_monster: Monster:
	get: return opponent.current_monster
