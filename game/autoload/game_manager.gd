extends Node

# Game Manager - Handles game state and flow

enum GameState {
	LOADING,
	MENU,
	LOBBY,
	MATCHING,
	IN_GAME,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.LOADING
var previous_state: GameState = GameState.LOADING

signal state_changed(new_state: GameState, old_state: GameState)
signal game_started
signal game_ended
signal game_paused
signal game_resumed

var match_id: String = ""
var match_start_time: float = 0.0
var match_duration: float = 0.0

var players_alive: int = 0
var total_players: int = 0

func _ready():
	change_state(GameState.MENU)

func change_state(new_state: GameState):
	if current_state == new_state:
		return
	
	previous_state = current_state
	current_state = new_state
	state_changed.emit(new_state, previous_state)
	
	# Handle state-specific logic
	match new_state:
		GameState.MENU:
			_on_enter_menu()
		GameState.IN_GAME:
			_on_enter_game()
		GameState.PAUSED:
			_on_enter_paused()
		GameState.GAME_OVER:
			_on_game_over()

func _on_enter_menu():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_enter_game():
	get_tree().paused = false
	match_start_time = Time.get_ticks_msec() / 1000.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_started.emit()

func _on_enter_paused():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused.emit()

func _on_game_over():
	match_duration = (Time.get_ticks_msec() / 1000.0) - match_start_time
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_ended.emit()
	
	# Update player stats
	var player_manager = get_node("/root/PlayerManager")
	if player_manager.current_player:
		player_manager.current_player.total_play_time += match_duration
		player_manager.save_player()

func start_match():
	change_state(GameState.IN_GAME)

func pause_game():
	if current_state == GameState.IN_GAME:
		change_state(GameState.PAUSED)

func resume_game():
	if current_state == GameState.PAUSED:
		change_state(GameState.IN_GAME)

func end_match():
	change_state(GameState.GAME_OVER)

func return_to_menu():
	change_state(GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func get_match_duration() -> float:
	if current_state == GameState.IN_GAME:
		return (Time.get_ticks_msec() / 1000.0) - match_start_time
	return match_duration

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.IN_GAME:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()
