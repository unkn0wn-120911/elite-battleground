extends Node

# Audio Manager - Handles all game sounds and music

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_players: int = 10

var music_volume: float = 0.7
var sfx_volume: float = 0.8
var master_volume: float = 1.0

var current_music: String = ""
var is_music_playing: bool = false

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX players pool
	for i in range(max_sfx_players):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_music(music_path: String, fade_in: float = 1.0):
	if current_music == music_path and is_music_playing:
		return
	
	if ResourceLoader.exists(music_path):
		var stream = load(music_path)
		music_player.stream = stream
		music_player.volume_db = -80.0
		music_player.play()
		current_music = music_path
		is_music_playing = true
		
		# Fade in
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume * master_volume), fade_in)

func stop_music(fade_out: float = 1.0):
	if is_music_playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(music_player.stop)
		is_music_playing = false
		current_music = ""

func play_sfx(sfx_path: String, volume: float = 1.0):
	if not ResourceLoader.exists(sfx_path):
		return
	
	var stream = load(sfx_path)
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
			player.play()
			return
	
	# If all players busy, use first one
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = linear_to_db(volume * sfx_volume * master_volume)
	sfx_players[0].play()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if is_music_playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	if is_music_playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
