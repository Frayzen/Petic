extends TextureButton

func _on_toggled(active: bool) -> void:
    if active:
        NetworkHandler.ready_fight()
    else:
        NetworkHandler.not_ready_fight()

