extends Node

const SAVE_PATH = "user://player_data.json"
const BACKUP_PATH = "user://player_data_backup.json"

signal save_completed
signal load_completed
signal save_error

func save_player_data(player_data: PlayerData) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		save_error.emit()
		return false
	
	var json_string = JSON.stringify(player_data.to_dict(), "\t")
	file.store_string(json_string)
	file.close()
	
	# Create backup
	_create_backup()
	
	save_completed.emit()
	return true

func load_player_data() -> PlayerData:
	var player_data = PlayerData.new()
	
	if not FileAccess.file_exists(SAVE_PATH):
		return player_data
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		# Try backup
		return _load_from_backup()
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse player data: " + json.get_error_message())
		return _load_from_backup()
	
	var data = json.data
	if data is Dictionary:
		player_data.from_dict(data)
	
	load_completed.emit()
	return player_data

func _create_backup():
	if FileAccess.file_exists(SAVE_PATH):
		var source = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var backup = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if source and backup:
			backup.store_string(source.get_as_text())
			source.close()
			backup.close()

func _load_from_backup() -> PlayerData:
	var player_data = PlayerData.new()
	
	if not FileAccess.file_exists(BACKUP_PATH):
		return player_data
	
	var file = FileAccess.open(BACKUP_PATH, FileAccess.READ)
	if file == null:
		return player_data
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return player_data
	
	var data = json.data
	if data is Dictionary:
		player_data.from_dict(data)
	
	return player_data

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(BACKUP_PATH)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func get_save_info() -> Dictionary:
	if not has_save():
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}
	
	var data = json.data
	if data is Dictionary:
		return {
			"name": data.get("player_name", "Unknown"),
			"level": data.get("level", 1),
			"last_login": data.get("last_login", "")
		}
	
	return {}
