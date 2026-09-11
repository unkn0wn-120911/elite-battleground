extends CharacterBody3D

# Elite Battleground - Player Controller
# Version: 0.1.0

# Player Stats
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 4.5
@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health, max_health)
@export var max_health: int = 100
@export var armor: int = 0
@export var max_armor: int = 100

# Movement states
enum MovementState { IDLE, WALKING, SPRINTING, CROUCHING, JUMPING, FALLING }
var current_state: MovementState = MovementState.IDLE

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Components
@onready var camera: Camera3D = $Camera3D
@onready var weapon_spawn: Marker3D = $Camera3D/WeaponSpawn
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# Signals
signal health_changed(new_health: int, max_health: int)
signal player_died
signal player_respawned

# Current weapon
var current_weapon = null
var is_alive = true
var sensitivity: float = 0.002

func _ready():
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_alive:
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if not is_alive:
		return
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		current_state = MovementState.JUMPING

	# Handle Sprint
	var is_sprinting = Input.is_action_pressed("sprint") and velocity.length() > 0.1
	
	# Handle Crouch
	var is_crouching = Input.is_action_pressed("crouch")
	
	# Determine speed
	var current_speed = walk_speed
	if is_sprinting:
		current_speed = sprint_speed
		current_state = MovementState.SPRINTING
	elif is_crouching:
		current_speed = crouch_speed
		current_state = MovementState.CROUCHING
	elif velocity.length() > 0.1:
		current_state = MovementState.WALKING
	else:
		current_state = MovementState.IDLE

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 2)
		velocity.z = move_toward(velocity.z, 0, current_speed * 2)

	move_and_slide()

func _unhandled_input(event):
	if not is_alive:
		return
		
	if event.is_action_pressed("fire"):
		fire_weapon()
	elif event.is_action_pressed("reload"):
		reload_weapon()
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func fire_weapon():
	if current_weapon and current_weapon.has_method("shoot"):
		current_weapon.shoot(raycast)

func reload_weapon():
	if current_weapon and current_weapon.has_method("reload"):
		current_weapon.reload()

func take_damage(amount: int, attacker = null):
	if not is_alive:
		return
	
	# Armor absorbs damage first
	if armor > 0:
		var armor_damage = min(armor, amount * 0.6)
		armor -= int(armor_damage)
		amount -= int(armor_damage)
	
	health -= amount
	
	if health <= 0:
		die(attacker)

func die(killer = null):
	is_alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	health = 0
	player_died.emit()
	
	# Play death animation
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")

func respawn(spawn_position: Vector3 = Vector3.ZERO):
	health = max_health
	armor = 0
	is_alive = true
	position = spawn_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_respawned.emit()

func equip_weapon(weapon):
	current_weapon = weapon

func add_armor(amount: int):
	armor = clamp(armor + amount, 0, max_armor)

func heal(amount: int):
	health = clamp(health + amount, 0, max_health)
	health_changed.emit(health, max_health)

func get_health_percentage() -> float:
	return float(health) / float(max_health)
