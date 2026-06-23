extends Node

const PORT = 24567
const ADDRESS = "127.0.0.1"
const MAX_CLIENTS = 1
const ROUND_TIME := 3.0

var is_server := false
var timer := ROUND_TIME
var timer_running := false
var player_id := str(randi())
var rng := RandomNumberGenerator.new()

const defaultHp : int = 3
var hpHost = 0
var hpOther = 0

func _process(delta):
    if multiplayer.multiplayer_peer == null:
        return
    if is_server and timer_running:
        timer -= delta

        # broadcast timer
        rpc("sync_timer", timer)

        if timer <= 0.0:
            _end_round()

func _on_disconnect():
    cancelConnection()
    transitionner.transition("res://scene/main_menu.tscn")

func start_client():
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(ADDRESS, PORT)

    multiplayer.multiplayer_peer = peer
    is_server = false
    multiplayer.server_disconnected.connect(_on_disconnect)

func start_server():
    var peer = ENetMultiplayerPeer.new()
    peer.peer_connected.connect(_on_client_connected)
    peer.peer_disconnected.connect(func(_peerid : int): _on_disconnect())
    peer.create_server(PORT, MAX_CLIENTS)

    multiplayer.multiplayer_peer = peer
    is_server = true

    print("Server started")

@rpc("any_peer", "reliable", "call_local")
func switch_scene_to_shop(serverHp : int, clientHp : int):
    hpHost = serverHp if is_server else clientHp
    hpOther = serverHp if not is_server else clientHp

    timer = ROUND_TIME
    await transitionner.transition("res://scene/shop.tscn")
    timer_running = true

@rpc("any_peer", "reliable", "call_local")
func send_seed(newSeed : int):
    rng.seed = newSeed

func _on_client_connected(peer_id : int) -> void:
    print("Client " + str(peer_id) + " joined")
    await get_tree().process_frame
    switch_scene_to_shop.rpc(defaultHp, defaultHp)
    send_seed.rpc_id(peer_id, rng.seed)

@rpc("authority", "reliable")
func sync_timer(t: float):
    timer = t

var hostTeam = null
var otherTeam = null
var sender_ids = []  # Track who has sent data

@rpc("any_peer", "reliable", "call_local")
func receive_round_data(json_data: String):
    var json = JSON.new()
    var error = json.parse(json_data)
    
    if error == OK:
        var received_array = json.data  # Array of dictionaries
        # print(str(multiplayer.get_unique_id()) + " Received data from peer: ", multiplayer.get_remote_sender_id())
        
        var animals : Array[AnimalData] = []
        for dict in received_array:
            var animal_data = AnimalData.from_dict(dict)
            animals.append(animal_data)
        var isHost = multiplayer.get_unique_id() == multiplayer.get_remote_sender_id()
        process_received_data(animals, isHost)
    else:
        print("Failed to parse JSON: ", json.get_error_message())

func process_received_data(animals: Array[AnimalData], isHost : bool):
    if isHost:
        hostTeam = animals
    else:
        otherTeam = animals
    if hostTeam != null and otherTeam != null:
        transitionner.transition("res://scene/fight.tscn")

@rpc("any_peer", "reliable", "call_local")
func send_round_data():
    var datas = []
    for animal in Market.instance.team_animals:
        if animal.data != null:
            datas.append(animal.data.to_dict())
    var json_string = JSON.stringify(datas)
    receive_round_data.rpc(json_string)

func _end_round():
    timer_running = false
    amount_finished_fight = 0
    send_round_data.rpc()

func cancelConnection():
    if multiplayer.multiplayer_peer != null:
        multiplayer.multiplayer_peer.close()
    multiplayer.multiplayer_peer = null

var amount_finished_fight : int  = 0

@rpc("any_peer", "call_local")
func send_finished_fight():
    amount_finished_fight += 1
    if amount_finished_fight == 2:
        if FightingManager.instance.isHostWin():
            hpHost -= 1
        if FightingManager.instance.isOtherWin():
            hpOther -= 1
        switch_scene_to_shop.rpc(hpHost, hpOther)

func finished_fight():
    send_finished_fight.rpc_id(1)
