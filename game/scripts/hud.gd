extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/AmmoPanel/AmmoLabel
@onready var kills_label: Label = $TopRight/KillsLabel
@onready var alive_count_label: Label = $TopRight/AliveCountLabel
@onready var crosshair: TextureRect = $Crosshair
@onready var damage_overlay: ColorRect = $DamageOverlay
@onready var kill_feed: VBoxContainer = $KillFeed

var player: CharacterBody3D = null
var kills: int = 0

func _ready():
	# Hide damage overlay initially
	damage_overlay.modulate.a = 0.0
	
	# Find player
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		player.health_changed.connect(_on_player_health_changed)

func _process(_delta):
	if player:
		_update_health_bar()

func _update_health_bar():
	if player:
		health_bar.value = player.get_health_percentage() * 100
		
		# Change color based on health
		if health_bar.value > 60:
			health_bar.modulate = Color.GREEN
		elif health_bar.value > 30:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

func _on_player_health_changed(new_health: int, max_health: int):
	# Flash damage overlay
	var tween = create_tween()
	damage_overlay.modulate.a = 0.5
	tween.tween_property(damage_overlay, "modulate:a", 0.0, 0.3)

func update_ammo(current: int, max: int):
	ammo_label.text = str(current) + " / " + str(max)

func add_kill(enemy_name: String):
	kills += 1
	kills_label.text = "Kills: " + str(kills)
	
	# Add to kill feed
	var feed_item = Label.new()
	feed_item.text = "You eliminated " + enemy_name
	feed_item.add_theme_color_override("font_color", Color.RED)
	kill_feed.add_child(feed_item)
	
	# Remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(feed_item):
		feed_item.queue_free()

func update_alive_count(count: int):
	alive_count_label.text = "Alive: " + str(count)

func show_victory_screen():
	# TODO: Show victory UI
	pass

func show_defeat_screen():
	# TODO: Show defeat UI
	pass
