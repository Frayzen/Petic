class_name MainMenu
extends Control

@export var sessionInput : LineEdit
@export var waitingIndicator : TextureButton
@export var waitingIndicatorLabel : Label
@export var menuContainer : Control

@export var inputHp : LineEdit
@export var inputCoin : LineEdit
@export var inputTimer : LineEdit

func _ready() -> void:
	waitingIndicator.visible = false
	menuContainer.visible = true
	NetworkHandler.hostTeam = []

func _on_client_pressed() -> void:
	NetworkHandler.start_client(sessionInput.text)
	waitScreen("Server")

func _on_server_pressed() -> void:
	NetworkHandler.roundTime = int(inputTimer.text)
	NetworkHandler.start_server(int(inputHp.text), int(inputCoin.text))
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


func _on_ip_address_input_text_submitted(new_text: String) -> void:
	NetworkHandler.start_client(new_text)
	waitScreen("Server")
