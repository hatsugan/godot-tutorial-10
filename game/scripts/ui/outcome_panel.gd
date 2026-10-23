extends PanelContainer

# A simple panel that we can pop up to select quit/restart after a game.

@export var restart: Button
@export var quit: Button
@export var label: Label

func _ready():
	# Connect signals
	Events.on_game_over.connect(game_over)
	Events.on_new_game_state.connect(hide)
	restart.pressed.connect(handle_request_restart)
	quit.pressed.connect(func(): Events.request_quit.emit())
	
	hide()

func handle_request_restart():
	hide()
	Events.request_restart.emit()

func game_over(game_outcome: GameRunner.OUTCOME):
	show()
	
	assert(game_outcome != GameRunner.OUTCOME.TBD, "Game over screen reached but outcome is TBD...")
	
	match game_outcome:
		GameRunner.OUTCOME.WIN:
			label.text = "YOU WIN!"
		GameRunner.OUTCOME.LOSE:
			label.text = "YOU LOSE! Womp womp..."
		GameRunner.OUTCOME.WIN:
			label.text = "It's a tie..."
			
