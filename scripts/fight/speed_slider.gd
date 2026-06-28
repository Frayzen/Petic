extends HSlider

const default : float = 0.1

func _ready() -> void:
	var val = configManager.load("slider", str(default))
	if val.is_valid_float():
		value = float(val)
	else:
		value = default
	configManager.save("slider", str(value))
	await get_tree().create_timer(0.1).timeout
	FightingManager.instance.updateAnimationSpeed(value)

func _on_drag_ended(has_value_changed: bool) -> void:
	if not has_value_changed:
		return
	configManager.save("slider", str(value))
	FightingManager.instance.updateAnimationSpeed(value)
