extends Control

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var loading_label: Label = $VBoxContainer/LoadingLabel
@onready var tip_label: Label = $VBoxContainer/TipLabel
@onready var player_info: HBoxContainer = $PlayerInfo
@onready var player_name_label: Label = $PlayerInfo/PlayerName
@onready var player_level_label: Label = $PlayerInfo/PlayerLevel
@onready var avatar: TextureRect = $PlayerInfo/Avatar

var target_scene: String = ""
var loading_progress: float = 0.0
var tips: Array[String] = [
	"Headshots deal extra damage!",
	"Use cover to avoid enemy fire",
	"Collect armor for better protection",
	"Team up with friends for better chances",
	"Check the minimap for enemy positions",
	"Reload in safe areas",
	"Use grenades to flush out enemies",
	"Stay mobile to avoid being an easy target"
]

func _ready():
	# Hide mouse
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# Show random tip
	tip_label.text = tips[randi() % tips.size()]
	
	# Show player info
	_show_player_info()
	
	# Start loading animation
	_animate_loading()

func _show_player_info():
	var player_manager = get_node("/root/PlayerManager")
	if player_manager and player_manager.current_player:
		var player = player_manager.current_player
		player_name_label.text = player.get_display_name()
		player_level_label.text = "Lv." + str(player.level)
		
		# Load avatar if exists
		if player.avatar_path != "" and ResourceLoader.exists(player.avatar_path):
			avatar.texture = load(player.avatar_path)

func _animate_loading():
	# Animate progress bar
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	
	# Update loading text
	var loading_texts = [
		"Connecting to server...",
		"Loading assets...",
		"Preparing battlefield...",
		"Syncing player data...",
		"Almost ready..."
	]
	
	for i in range(loading_texts.size()):
		await get_tree().create_timer(0.6).timeout
		loading_label.text = loading_texts[i]

func start_loading(scene_path: String):
	target_scene = scene_path
	
	# Simulate loading progress
	var progress_tween = create_tween()
	progress_tween.tween_method(_update_progress, 0.0, 100.0, 2.5)
	
	await progress_tween.finished
	
	# Load the actual scene
	var resource = ResourceLoader.load(target_scene)
	if resource:
		get_tree().change_scene_to_packed(resource)
	else:
		push_error("Failed to load scene: " + target_scene)

func _update_progress(value: float):
	progress_bar.value = value
	loading_progress = value

func _on_loading_finished():
	# Transition to game
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
