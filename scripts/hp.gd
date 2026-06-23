extends Label

func _ready() -> void:
	text = str(NetworkHandler.hpHost)
