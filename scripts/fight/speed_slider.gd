extends HSlider

func _process(_delta: float) -> void:
    FightingManager.instance.updateAnimationSpeed(value)
