extends CharacterBody3D

# Elite Battleground - Enemy AI
# Basic combat AI for battle royale enemies

@export var max_health: int = 100
@export var move_speed: float = 3.5
@export var detection_range: float = 25.0
@export var attack_range: float = 15.0
@export var damage: int = 10
@export var fire_rate: float = 0.5
@export var enemy_name: String = "Enemy"

var health: int
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target: Node3D = null
var is_alive = true
var last_fire_time: float = 0.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast3D

signal enemy_died(enemy: Node3D)

func _ready():
	add_to_group("enemies")
	health = max_health

func _physics_process(delta):
	if not is_alive:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Find target (player)
	if target == null or not is_instance_valid(target):
		_find_target()
	
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		
		if distance < detection_range:
			# Look at target
			_look_at_target()
			
			if distance < attack_range:
				# Attack
				_attack_target()
			else:
				# Move towards target
				_move_to_target()
		else:
			# Patrol
			_patrol()
	
	move_and_slide()

func _find_target():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _look_at_target():
	if target:
		var look_pos = target.global_position
		look_pos.y = global_position.y
		look_at(look_pos, Vector3.UP)

func _move_to_target():
	if target:
		navigation_agent.target_position = target.global_position
		if navigation_agent.is_navigation_finished():
			return
		
		var next_pos = navigation_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

func _patrol():
	# Simple random patrol
	velocity.x = move_toward(velocity.x, 0, move_speed)
	velocity.z = move_toward(velocity.z, 0, move_speed)

func _attack_target():
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_fire_time < fire_rate:
		return
	
	# Raycast to check line of sight
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider() == target:
		last_fire_time = current_time
		if target.has_method("take_damage"):
			target.take_damage(damage, self)

func take_damage(amount: int, attacker = null):
	if not is_alive:
		return
	
	health -= amount
	
	# Flash red
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		die(attacker)

func die(killer = null):
	is_alive = false
	health = 0
	enemy_died.emit(self)
	
	# Play death animation or just remove
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func get_health_percentage() -> float:
	return float(health) / float(max_health)
