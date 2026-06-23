extends Control

@export var ipAddressInput : LineEdit
@export var ipAddressInfo : Label
@export var waitingIndicator : TextureButton
@export var waitingIndicatorLabel : Label
@export var buttonContainer : VBoxContainer

func _ready() -> void:
	waitingIndicator.visible = false
	buttonContainer.visible = true
	var ipStr = ""
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172.16."):
			ipStr = ip + " "
			print(ipStr)
	ipAddressInfo.text = ipStr
		

func _on_client_pressed() -> void:
	NetworkHandler.start_client(ipAddressInput.text)
	waitScreen("Server")

func _on_server_pressed() -> void:
	NetworkHandler.start_server()
	waitScreen("Client")

func waitScreen(waitFor : String):
	waitingIndicatorLabel.text = "Waiting for "+waitFor
	waitingIndicator.visible = true
	buttonContainer.visible = false

func _on_cancel_button_pressed() -> void:
	if transitionner.transitionning:
		return
	NetworkHandler.cancelConnection()
	waitingIndicator.visible = false
	buttonContainer.visible = true
	print("CANCEL")
