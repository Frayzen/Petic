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

var hostTeam = null
var otherTeam = null
var sender_ids = []  # Track who has sent data

@rpc("any_peer", "reliable", "call_local")
func send_round_data(json_data: String):
	var json = JSON.new()
	var error = json.parse(json_data)
	
	if error == OK:
		var received_array = json.data  # Array of dictionaries
		print("Received data from peer: ", multiplayer.get_remote_sender_id())
		
		# Convert dictionaries back to AnimalData objects
		var animals = []
		for dict in received_array:
			var animal_data = AnimalData.from_dict(dict)
			animals.append(animal_data)
		
		print("Deserialized ", animals.size(), " animals")
		
		process_received_data(animals)
	else:
		print("Failed to parse JSON: ", json.get_error_message())

func process_received_data(animals: Array):
	for animal in animals:
		print("Received animal: ", animal.name, " HP: ", animal.health)


#     var json = JSON.new()
#     var error = json.parse(dataRcv)
#     assert(error == OK)
#     var data = json.data
#     var sender_id = multiplayer.get_remote_sender_id()
#     var peer_id = multiplayer.get_unique_id()
	
#     # Check if this is the local peer
#     if sender_id == 0 or sender_id == peer_id:
#         # Called locally
#         hostTeam = data
#         print("RECEIVED HOST (local)")
#     else:
#         # Called remotely
#         otherTeam = data
#         print("RECEIVED OTHER from peer: ", sender_id)
#     print(data)
#     for d in data:
#         print(d.name)
	
#     sender_ids.append(sender_id)
	
#     if otherTeam != null and hostTeam != null:
#         print("LETS GO")
#         # Reset for next round
#         hostTeam = null
#         otherTeam = null
#         sender_ids = []

func _end_round():
	print("END ROUND")
	
	var datas = []  # Untyped array
	for animal in Market.instance.team_animals:
		if animal.data != null:
			# Convert AnimalData to dictionary
			datas.append(animal.data.to_dict())
	
	# Convert to JSON
	var json_string = JSON.stringify(datas)
	print("SENDING: " + json_string)
	send_round_data.rpc(json_string)

func cancelConnection():
	multiplayer.multiplayer_peer.free()
	multiplayer.multiplayer_peer = null
