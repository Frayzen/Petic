class_name DamageIndicator
extends Control

@export var texture : TextureRect
@export var label : Label

var damageAmount : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    label.text = "-" + str(damageAmount)

    var tween = create_tween()
    texture.modulate.a = 1
    var invAnimSpeed = (1 / FightingManager.animationSpeed)
    var delay = 0.4 * invAnimSpeed
    tween.tween_property(texture, "modulate:a", 0.0, delay)
    tween.tween_callback(queue_free).set_delay(delay)
