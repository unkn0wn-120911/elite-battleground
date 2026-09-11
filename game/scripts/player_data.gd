extends Resource
class_name PlayerData

# Player Identity
@export var player_id: String = ""
@export var player_name: String = ""
@export var tag_line: String = ""  # যেমন: #1234
@export var avatar_path: String = ""
@export var bio: String = ""

# Account Info
@export var created_date: String = ""
@export var last_login: String = ""
@export var total_play_time: float = 0.0

# Game Stats
@export var level: int = 1
@export var experience: int = 0
@export var max_experience: int = 100
@export var kills: int = 0
@export var deaths: int = 0
@export var wins: int = 0
@export var matches_played: int = 0

# Currency
@export var coins: int = 500
@export var diamonds: int = 50

# Inventory
@export var owned_weapons: Array[String] = ["pistol"]
@export var owned_skins: Array[String] = ["default"]
@export var equipped_weapon: String = "pistol"
@export var equipped_skin: String = "default"

# Settings
@export var sensitivity: float = 0.5
@export var music_volume: float = 0.7
@export var sfx_volume: float = 0.8

# Rank
@export var rank: String = "Bronze"
@export var rank_points: int = 0

# Achievements
@export var achievements: Array[String] = []

func _init():
	player_id = _generate_player_id()
	created_date = Time.get_datetime_string_from_system()
	last_login = created_date

func _generate_player_id() -> String:
	var timestamp = str(Time.get_ticks_msec())
	var random = str(randi() % 10000)
	return "EB" + timestamp.right(6) + random

func get_display_name() -> String:
	return player_name + "#" + tag_line

func get_kd_ratio() -> float:
	if deaths == 0:
		return float(kills)
	return float(kills) / float(deaths)

func get_win_rate() -> float:
	if matches_played == 0:
		return 0.0
	return (float(wins) / float(matches_played)) * 100.0

func add_experience(amount: int):
	experience += amount
	while experience >= max_experience:
		level_up()

func level_up():
	experience -= max_experience
	level += 1
	max_experience = int(max_experience * 1.2)
	# Reward coins on level up
	coins += 100

func add_kill():
	kills += 1

func add_death():
	deaths += 1

func add_win():
	wins += 1

func add_match():
	matches_played += 1

func to_dict() -> Dictionary:
	return {
		"player_id": player_id,
		"player_name": player_name,
		"tag_line": tag_line,
		"avatar_path": avatar_path,
		"bio": bio,
		"created_date": created_date,
		"last_login": last_login,
		"total_play_time": total_play_time,
		"level": level,
		"experience": experience,
		"max_experience": max_experience,
		"kills": kills,
		"deaths": deaths,
		"wins": wins,
		"matches_played": matches_played,
		"coins": coins,
		"diamonds": diamonds,
		"owned_weapons": owned_weapons,
		"owned_skins": owned_skins,
		"equipped_weapon": equipped_weapon,
		"equipped_skin": equipped_skin,
		"sensitivity": sensitivity,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"rank": rank,
		"rank_points": rank_points,
		"achievements": achievements
	}

func from_dict(data: Dictionary):
	player_id = data.get("player_id", "")
	player_name = data.get("player_name", "")
	tag_line = data.get("tag_line", "")
	avatar_path = data.get("avatar_path", "")
	bio = data.get("bio", "")
	created_date = data.get("created_date", "")
	last_login = data.get("last_login", "")
	total_play_time = data.get("total_play_time", 0.0)
	level = data.get("level", 1)
	experience = data.get("experience", 0)
	max_experience = data.get("max_experience", 100)
	kills = data.get("kills", 0)
	deaths = data.get("deaths", 0)
	wins = data.get("wins", 0)
	matches_played = data.get("matches_played", 0)
	coins = data.get("coins", 500)
	diamonds = data.get("diamonds", 50)
	owned_weapons = data.get("owned_weapons", ["pistol"])
	owned_skins = data.get("owned_skins", ["default"])
	equipped_weapon = data.get("equipped_weapon", "pistol")
	equipped_skin = data.get("equipped_skin", "default")
	sensitivity = data.get("sensitivity", 0.5)
	music_volume = data.get("music_volume", 0.7)
	sfx_volume = data.get("sfx_volume", 0.8)
	rank = data.get("rank", "Bronze")
	rank_points = data.get("rank_points", 0)
	achievements = data.get("achievements", [])
