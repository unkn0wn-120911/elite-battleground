extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var profile_button: Button = $VBoxContainer/ProfileButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var player_panel: PanelContainer = $PlayerPanel
@onready var player_name_label: Label = $PlayerPanel/VBoxContainer/PlayerName
@onready var player_level_label: Label = $PlayerPanel/VBoxContainer/PlayerLevel
@onready var player_rank_label: Label = $PlayerPanel/VBoxContainer/PlayerRank
@onready var coins_label: Label = $PlayerPanel/VBoxContainer/CurrencyPanel/CoinsLabel
@onready var diamonds_label: Label = $PlayerPanel/VBoxContainer/CurrencyPanel/DiamondsLabel
@onready var xp_bar: ProgressBar = $PlayerPanel/VBoxContainer/XPBar

func _ready():
	# Check if player exists
	var player_manager = get_node("/root/PlayerManager")
	if player_manager.is_new_player():
		# New player - show registration
		get_tree().change_scene_to_file("res://scenes/player_registration.tscn")
		return
	
	# Show player info
	_update_player_info()
	
	# Connect buttons
	play_button.pressed.connect(_on_play_pressed)
	profile_button.pressed.connect(_on_profile_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Unlock mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Animate title
	_animate_title()

func _update_player_info():
	var player_manager = get_node("/root/PlayerManager")
	if player_manager.current_player:
		var player = player_manager.current_player
		
		player_name_label.text = player.get_display_name()
		player_level_label.text = "Level " + str(player.level)
		player_rank_label.text = player.rank
		
		coins_label.text = str(player.coins)
		diamonds_label.text = str(player.diamonds)
		
		# XP bar
		xp_bar.value = (float(player.experience) / float(player.max_experience)) * 100.0

func _animate_title():
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, 0.0)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)

func _on_play_pressed():
	# Go to loading screen then game
	var loading_scene = preload("res://scenes/loading_screen.tscn")
	var loading = loading_scene.instantiate()
	get_tree().current_scene.add_child(loading)
	loading.start_loading("res://scenes/game.tscn")

func _on_profile_pressed():
	get_tree().change_scene_to_file("res://scenes/player_profile.tscn")

func _on_settings_pressed():
	# TODO: Open settings
	pass

func _on_quit_pressed():
	# Save before quitting
	var player_manager = get_node("/root/PlayerManager")
	player_manager.save_player()
	get_tree().quit()
