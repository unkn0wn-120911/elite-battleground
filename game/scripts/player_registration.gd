extends Control

@onready var name_input: LineEdit = $VBoxContainer/NameInput
@onready var tag_input: LineEdit = $VBoxContainer/TagInput
@onready var error_label: Label = $VBoxContainer/ErrorLabel
@onready var create_button: Button = $VBoxContainer/CreateButton
@onready var avatar_selector: HBoxContainer = $VBoxContainer/AvatarSelector

var selected_avatar: int = 0
var available_avatars: Array[String] = [
	"res://assets/avatars/avatar1.png",
	"res://assets/avatars/avatar2.png",
	"res://assets/avatars/avatar3.png",
	"res://assets/avatars/avatar4.png"
]

func _ready():
	# Generate random tag
	tag_input.text = str(randi() % 10000)
	tag_input.editable = false
	
	# Connect signals
	create_button.pressed.connect(_on_create_pressed)
	name_input.text_changed.connect(_validate_input)
	
	# Setup avatar selector
	_setup_avatar_selector()
	
	# Show error label hidden
	error_label.visible = false

func _setup_avatar_selector():
	for i in range(avatar_selector.get_child_count()):
		var button = avatar_selector.get_child(i)
		if button is Button:
			button.pressed.connect(_on_avatar_selected.bind(i))

func _on_avatar_selected(index: int):
	selected_avatar = index
	# Highlight selected avatar
	for i in range(avatar_selector.get_child_count()):
		var button = avatar_selector.get_child(i)
		if button is Button:
			button.modulate = Color.WHITE if i != index else Color.YELLOW

func _validate_input(text: String):
	error_label.visible = false
	
	if text.length() < 3:
		error_label.text = "Name must be at least 3 characters"
		error_label.visible = true
		create_button.disabled = true
	elif text.length() > 15:
		error_label.text = "Name must be less than 15 characters"
		error_label.visible = true
		create_button.disabled = true
	elif not _is_valid_name(text):
		error_label.text = "Name can only contain letters, numbers, and spaces"
		error_label.visible = true
		create_button.disabled = true
	else:
		create_button.disabled = false

func _is_valid_name(name: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9 ]+$")
	return regex.search(name) != null

func _on_create_pressed():
	var player_name = name_input.text.strip_edges()
	var tag_line = tag_input.text
	
	if player_name == "":
		error_label.text = "Please enter a name"
		error_label.visible = true
		return
	
	# Create player
	var player_manager = get_node("/root/PlayerManager")
	if player_manager:
		var player = player_manager.create_new_player(player_name, tag_line)
		player.avatar_path = available_avatars[selected_avatar]
		player_manager.save_player()
		
		# Transition to loading screen
		_transition_to_loading()

func _transition_to_loading():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# Load main menu through loading screen
	var loading_scene = preload("res://scenes/loading_screen.tscn")
	var loading = loading_scene.instantiate()
	get_tree().current_scene.add_child(loading)
	loading.start_loading("res://scenes/main_menu.tscn")
