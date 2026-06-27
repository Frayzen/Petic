extends Control

@export var bg : TextureRect
@export var winBg : Texture
@export var lostBg : Texture

func _ready() -> void:
    if NetworkHandler.hpHost == 0:
        bg.texture = lostBg
    else:
        bg.texture = winBg
    await get_tree().create_timer(3).timeout
    NetworkHandler.cancelConnection()

