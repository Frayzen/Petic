extends Node


const PORT = 24567
const MAX_CLIENTS = 1
const ROUND_TIME := 6.0

var is_server := false
var timer := ROUND_TIME
var timer_running := false
var player_id := str(randi())
var rng := RandomNumberGenerator.new()

const defaultHp : int = 3
var hpHost = 0
var hpOther = 0

func _ready() -> void:
    tube_client.context = load("res://tube_context.tres")
    tube_client.multiplayer.server_disconnected.connect(_on_disconnect)
    tube_client.peer_connected.connect(_on_client_connected)
    tube_client.peer_disconnected.connect(_on_disconnect_peer)

func _process(delta):
    if tube_client.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
        return
    if is_server and timer_running:
        timer -= delta

        # broadcast timer
        rpc("sync_timer", timer)

        if timer <= 0.0:
            _end_round()

func _on_disconnect_peer(_peerID : int):
    if not is_server:
        return
    cancelConnection()
    transitionner.transition("res://scene/main_menu.tscn")

func _on_disconnect():
    cancelConnection()
    transitionner.transition("res://scene/main_menu.tscn")

func start_client(sessionId : String):
    tube_client.join_session(sessionId)
    is_server = false

func start_server():
    print("OK HERE")
    tube_client.create_session()
    is_server = true

    print("Server started ID " + tube_client.session_id)

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

var hostTeam : Array
var otherTeam : Array
var sender_ids = []  # Track who has sent data

@rpc("any_peer", "reliable")
func receive_round_data(json_data: String):
    var json = JSON.new()
    var error = json.parse(json_data)
    
    if error == OK:
        var received_array = json.data  # Array of dictionaries
        
        var animals : Array[AnimalData] = []
        for dict in received_array:
            var animal_data = AnimalData.from_dict(dict)
            animals.append(animal_data)
        otherTeam = animals
        transitionner.transition("res://scene/fight.tscn")
    else:
        print("Failed to parse JSON: ", json.get_error_message())

@rpc("any_peer", "reliable", "call_local")
func send_round_data():
    hostTeam.clear()
    var datas = []
    for animal in Market.instance.team_animals:
        if animal.data != null:
            datas.append(animal.data.to_dict())
        hostTeam.append(animal.data)
    var json_string = JSON.stringify(datas)
    receive_round_data.rpc(json_string)

func _end_round():
    timer_running = false
    amount_finished_fight = 0
    send_round_data.rpc()

func cancelConnection():
    tube_client.leave_session()

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
