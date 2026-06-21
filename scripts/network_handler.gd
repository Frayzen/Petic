extends Node

const PORT = 24567
const ADDRESS = "127.0.0.1"
const MAX_CLIENTS = 1
const ROUND_TIME := 10.0

var is_server := false
var timer := ROUND_TIME
var timer_running := false
var player_id := str(randi())


func _process(delta):
	if multiplayer.multiplayer_peer == null:
		return

	if is_server and timer_running:
		timer -= delta

		# broadcast timer
		rpc("sync_timer", timer)

		if timer <= 0.0:
			_end_round()
			timer = ROUND_TIME


func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.peer_connected.connect(_on_client_connected)
	peer.create_server(PORT, MAX_CLIENTS)

	multiplayer.multiplayer_peer = peer
	is_server = true

	print("Server started")

@rpc("any_peer", "reliable", "call_local")
func switch_scene_to_level():
	print("Switch scene !")
	get_tree().change_scene_to_file("res://scene/shop.tscn")

func _on_client_connected(peer_id : int) -> void:
	print("Client " + str(peer_id) + " joined")
	await get_tree().process_frame
	switch_scene_to_level.rpc()
	timer_running = true
	

func start_client():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)

	multiplayer.multiplayer_peer = peer
	is_server = false


@rpc("authority", "reliable")
func sync_timer(t: float):
	timer = t


@rpc("any_peer", "reliable", "call_local")
func send_round_data(data: String):
	print("Received from peer: ", data)


@rpc("authority")
func client_send_data():
	send_round_data.rpc_id(1, "Hello World") # send to server (peer 1 usually)


func _end_round():
	rpc("client_send_data")
	client_send_data()
