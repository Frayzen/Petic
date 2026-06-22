extends Control

@export var waitingIndicator : TextureButton
@export var waitingIndicatorLabel : Label
@export var buttonContainer : VBoxContainer

func _ready() -> void:
	waitingIndicator.visible = false
	buttonContainer.visible = true

func _on_client_pressed() -> void:
	NetworkHandler.start_client()
	waitScreen("Server")

func _on_server_pressed() -> void:
	NetworkHandler.start_server()
	waitScreen("Client")

func waitScreen(waitFor : String):
	waitingIndicatorLabel.text = "Waiting for "+waitFor
	waitingIndicator.visible = true
	buttonContainer.visible = false

func _on_cacnel_button_pressed() -> void:
	NetworkHandler.cancelConnection()
	waitingIndicator.visible = false
	buttonContainer.visible = true
