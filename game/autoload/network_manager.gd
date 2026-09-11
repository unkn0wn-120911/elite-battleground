extends Node

# Network Manager - Handles multiplayer connections

var peer: ENetMultiplayerPeer
var is_host: bool = false
var is_connected: bool = false
var server_ip: String = ""
var server_port: int = 7777
var max_players: int = 50

signal connected_to_server
signal disconnected_from_server
signal player_joined(id: int)
signal player_left(id: int)
signal connection_failed(reason: String)

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func create_server(port: int = 7777, players: int = 50) -> bool:
	server_port = port
	max_players = players
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, max_players)
	
	if error != OK:
		connection_failed.emit("Failed to create server: " + str(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	is_host = true
	is_connected = true
	
	print("Server created on port: ", server_port)
	connected_to_server.emit()
	return true

func join_server(ip: String, port: int = 7777) -> bool:
	server_ip = ip
	server_port = port
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_ip, server_port)
	
	if error != OK:
		connection_failed.emit("Failed to connect: " + str(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	is_host = false
	
	print("Connecting to: ", server_ip, ":", server_port)
	return true

func disconnect_from_server():
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = null
		peer = null
	
	is_host = false
	is_connected = false
	disconnected_from_server.emit()

func _on_player_connected(id: int):
	print("Player connected: ", id)
	player_joined.emit(id)

func _on_player_disconnected(id: int):
	print("Player disconnected: ", id)
	player_left.emit(id)

func _on_connected_to_server():
	print("Connected to server!")
	is_connected = true
	connected_to_server.emit()

func _on_connection_failed():
	print("Connection failed!")
	is_connected = false
	connection_failed.emit("Connection failed")

@rpc("any_peer", "reliable")
func sync_player_data(player_id: String, player_name: String, position: Vector3):
	# Sync player data across network
	pass

@rpc("any_peer", "call_local")
func sync_player_position(player_id: String, position: Vector3, rotation: Vector3):
	# Sync player movement
	pass

@rpc("any_peer", "unreliable")
func sync_player_rotation(player_id: String, rotation: Vector3):
	# Sync player rotation (high frequency)
	pass

@rpc("any_peer", "reliable")
func send_chat_message(sender_id: int, message: String):
	# Broadcast chat message
	pass

@rpc("any_peer", "reliable")
func sync_game_state(state: Dictionary):
	# Sync game state (kills, alive count, etc.)
	pass

func get_player_count() -> int:
	if is_host and peer:
		return peer.get_peers().size() + 1
	return 0

func is_server() -> bool:
	return is_host
