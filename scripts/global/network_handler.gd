extends Node

const PORT = 24567
const MAX_CLIENTS = 1

var is_server := false
var roundTime : float = 1
var timer : float = 1
var timer_running := false
var player_id := str(randi())
var rng := RandomNumberGenerator.new()

var defaultHp : int = 1

var hpHost = 0
var hpOther = 0
var amountCoins = 0

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
    if get_tree().current_scene is not MainMenu:
        transitionner.transition("res://scene/main_menu.tscn")

func start_client(sessionId : String):
    is_server = false
    if not tube_client.context.is_session_id_valid(sessionId):
        return
    tube_client.join_session(sessionId)

func start_server(pDefaultHp : int, pDefaultCoins):
    is_server = true
    defaultHp = pDefaultHp
    amountCoins = pDefaultCoins
    tube_client.create_session()
    tube_client.refuse_new_connections = false

@rpc("any_peer", "reliable", "call_local")
func switch_scene_to_shop(serverHp : int, clientHp : int, coins : int):
    amountCoins = coins
    hpHost = serverHp if is_server else clientHp
    hpOther = serverHp if not is_server else clientHp
    if hpHost == 0 or hpOther == 0:
        await transitionner.transition("res://scene/end_scene.tscn")
        return
    timer = roundTime
    await transitionner.transition("res://scene/shop.tscn", func(): Market.startShopping())
    timer_running = true

@rpc("any_peer", "reliable", "call_local")
func send_rng(newSeed : int):
    rng.seed = newSeed

func _on_client_connected(peer_id : int) -> void:
    await get_tree().process_frame
    send_rng.rpc_id(peer_id, rng.seed)
    if is_server:
        switch_scene_to_shop.rpc(defaultHp, defaultHp, amountCoins)
        tube_client.refuse_new_connections = true

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
    for animal in Market.team_animals:
        if animal.data != null:
            datas.append(animal.data.to_dict())
        hostTeam.append(animal.data)
    var json_string = JSON.stringify(datas)
    receive_round_data.rpc(json_string)

func _end_round():
    amountReady = 0
    timer_running = false
    amount_finished_fight = 0
    send_round_data.rpc()

func cancelConnection():
    if tube_client.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
        return
    tube_client.leave_session()

var amount_finished_fight : int  = 0

@rpc("any_peer", "call_local")
func send_finished_fight():
    amount_finished_fight += 1
    if amount_finished_fight == 2:
        if FightingManager.instance.isHostWin():
            hpOther -= 1
        if FightingManager.instance.isOtherWin():
            hpHost -= 1
        switch_scene_to_shop.rpc(hpHost, hpOther, amountCoins)

var amountReady : int = 0
@rpc("any_peer", "call_local")
func send_ready_fight():
    amountReady += 1
    if amountReady == 2:
        _end_round()

@rpc("any_peer", "call_local")
func send_not_ready_fight():
    amountReady -= 1

func ready_fight():
    send_ready_fight.rpc_id(1)

func not_ready_fight():
    send_not_ready_fight.rpc_id(1)

func finished_fight():
    send_finished_fight.rpc_id(1)
