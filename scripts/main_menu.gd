extends Control

@export var sessionInput : LineEdit
@export var waitingIndicator : TextureButton
@export var waitingIndicatorLabel : Label
@export var menuContainer : Control

func _ready() -> void:
    waitingIndicator.visible = false
    menuContainer.visible = true
    var ipStr = ""
    for ip in IP.get_local_addresses():
        if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172.16."):
            ipStr = ip + " "
            print(ipStr)
        

func _on_client_pressed() -> void:
    NetworkHandler.start_client(sessionInput.text)
    waitScreen("Server")

func _on_server_pressed() -> void:
    NetworkHandler.start_server()
    waitScreen("Client\nSession ID: " + tube_client.session_id)

func waitScreen(waitFor : String):
    waitingIndicatorLabel.text = "Waiting for "+waitFor
    waitingIndicator.visible = true
    menuContainer.visible = false

func _on_cancel_button_pressed() -> void:
    if transitionner.transitionning:
        return
    NetworkHandler.cancelConnection()
    waitingIndicator.visible = false
    menuContainer.visible = true
    print("CANCEL")


func _on_ip_address_input_text_submitted(new_text: String) -> void:
    NetworkHandler.start_client(new_text)
    waitScreen("Server")

