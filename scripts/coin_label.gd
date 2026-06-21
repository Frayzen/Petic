extends Label

func _process(_delta: float) -> void:
    text = str(Market.instance.coins)
