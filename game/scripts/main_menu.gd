extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var version_label: Label = $VersionLabel

var game_scene_path: String = "res://scenes/game.tscn"

func _ready():
	# Animate title
	_animate_title()
	
	# Connect buttons
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Show version
	version_label.text = "v0.1.0 - Alpha"
	
	# Unlock mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _animate_title():
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, 0.0)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)

func _on_play_pressed():
	# Transition to game
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(game_scene_path)

func _on_settings_pressed():
	# TODO: Open settings popup
	print("Settings pressed")

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
