extends TextureButton

func _process(_delta: float) -> void:
    if not button_pressed and FightingManager.instance.eventManager.pause:
        FightingManager.instance.eventManager.unpause.emit()
    FightingManager.instance.eventManager.pause = button_pressed
