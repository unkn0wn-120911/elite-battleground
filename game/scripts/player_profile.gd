extends Control

@onready var player_name_label: Label = $VBoxContainer/PlayerInfo/PlayerName
@onready var player_id_label: Label = $VBoxContainer/PlayerInfo/PlayerID
@onready var player_level_label: Label = $VBoxContainer/PlayerInfo/PlayerLevel
@onready var player_rank_label: Label = $VBoxContainer/PlayerInfo/PlayerRank
@onready var avatar: TextureRect = $VBoxContainer/PlayerInfo/Avatar
@onready var stats_panel: VBoxContainer = $VBoxContainer/StatsPanel
@onready var back_button: Button = $BackButton

func _ready():
	_load_player_profile()
	back_button.pressed.connect(_on_back_pressed)

func _load_player_profile():
	var player_manager = get_node("/root/PlayerManager")
	if player_manager.current_player:
		var player = player_manager.current_player
		
		player_name_label.text = player.get_display_name()
		player_id_label.text = "ID: " + player.player_id
		player_level_label.text = "Level " + str(player.level)
		player_rank_label.text = player.rank
		
		# Load avatar
		if player.avatar_path != "" and ResourceLoader.exists(player.avatar_path):
			avatar.texture = load(player.avatar_path)
		
		# Stats
		_add_stat("Kills", str(player.kills))
		_add_stat("Deaths", str(player.deaths))
		_add_stat("K/D Ratio", String.num(player.get_kd_ratio(), 2))
		_add_stat("Wins", str(player.wins))
		_add_stat("Win Rate", String.num(player.get_win_rate(), 1) + "%")
		_add_stat("Matches", str(player.matches_played))
		_add_stat("Play Time", _format_time(player.total_play_time))
		_add_stat("Member Since", player.created_date.substr(0, 10))

func _add_stat(label_text: String, value_text: String):
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text + ":"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var value = Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	hbox.add_child(label)
	hbox.add_child(value)
	stats_panel.add_child(hbox)

func _format_time(seconds: float) -> String:
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	
	if hours > 0:
		return str(hours) + "h " + str(minutes) + "m"
	else:
		return str(minutes) + "m"

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
