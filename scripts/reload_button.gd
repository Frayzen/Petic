extends TextureButton

func _on_pressed() -> void:
    Market.instance.refresh()

