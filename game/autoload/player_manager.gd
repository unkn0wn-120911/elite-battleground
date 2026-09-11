extends Node

# Singleton - Add this to Project > Project Settings > Autoload

var current_player: PlayerData = null
var is_logged_in: bool = false

signal player_logged_in
signal player_logged_out
signal player_data_updated

func _ready():
	# Load player data on startup
	load_player()

func load_player():
	var save_manager = get_node("/root/SaveManager")
	if save_manager:
		current_player = save_manager.load_player_data()
		if current_player.player_name != "":
			is_logged_in = true
			player_logged_in.emit()

func save_player():
	if current_player:
		var save_manager = get_node("/root/SaveManager")
		if save_manager:
			save_manager.save_player_data(current_player)
			player_data_updated.emit()

func create_new_player(name: String, tag: String = "") -> PlayerData:
	current_player = PlayerData.new()
	current_player.player_name = name
	current_player.tag_line = tag if tag != "" else str(randi() % 10000)
	current_player.created_date = Time.get_datetime_string_from_system()
	current_player.last_login = current_player.created_date
	
	is_logged_in = true
	save_player()
	player_logged_in.emit()
	
	return current_player

func login_existing_player():
	if current_player and current_player.player_name != "":
		current_player.last_login = Time.get_datetime_string_from_system()
		is_logged_in = true
		save_player()
		player_logged_in.emit()
		return true
	return false

func logout():
	is_logged_in = false
	save_player()
	player_logged_out.emit()

func update_player_name(new_name: String):
	if current_player:
		current_player.player_name = new_name
		save_player()

func update_avatar(avatar_path: String):
	if current_player:
		current_player.avatar_path = avatar_path
		save_player()

func add_game_stats(kill: bool = false, death: bool = false, win: bool = false):
	if current_player:
		if kill:
			current_player.add_kill()
		if death:
			current_player.add_death()
		if win:
			current_player.add_win()
		current_player.add_match()
		save_player()

func add_experience(amount: int):
	if current_player:
		current_player.add_experience(amount)
		save_player()

func add_coins(amount: int):
	if current_player:
		current_player.coins += amount
		save_player()

func add_diamonds(amount: int):
	if current_player:
		current_player.diamonds += amount
		save_player()

func unlock_weapon(weapon_name: String):
	if current_player and weapon_name not in current_player.owned_weapons:
		current_player.owned_weapons.append(weapon_name)
		save_player()

func unlock_skin(skin_name: String):
	if current_player and skin_name not in current_player.owned_skins:
		current_player.owned_skins.append(skin_name)
		save_player()

func equip_weapon(weapon_name: String):
	if current_player and weapon_name in current_player.owned_weapons:
		current_player.equipped_weapon = weapon_name
		save_player()

func equip_skin(skin_name: String):
	if current_player and skin_name in current_player.owned_skins:
		current_player.equipped_skin = skin_name
		save_player()

func get_player_level() -> int:
	return current_player.level if current_player else 1

func get_player_rank() -> String:
	return current_player.rank if current_player else "Bronze"

func is_new_player() -> bool:
	return current_player == null or current_player.player_name == ""
