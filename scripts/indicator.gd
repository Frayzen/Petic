class_name Indicator
extends Control

@export var texture : TextureRect
@export var label : Label

var amount : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    label.text = str(amount)
    if amount >= 0:
        label.text = "+" + label.text
    var tween = create_tween()
    texture.modulate.a = 1
    var invAnimSpeed = (1 / FightingManager.instance.animationSpeed)
    var delay = 0.4 * invAnimSpeed
    tween.tween_property(texture, "modulate:a", 0.0, delay)
    tween.tween_callback(queue_free).set_delay(delay)
