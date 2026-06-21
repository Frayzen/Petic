class_name AnimalRender
extends TextureRect

@export var healthLabel : Label
@export var attackLabel : Label
@export var selectedTexture : TextureRect
@export var attackTexture : TextureRect
@export var healthTexture : TextureRect

var data : AnimalData = null
var empty : bool = true
var selected : bool = false

func _process(_delta: float) -> void:
	selectedTexture.visible = selected

func hideInfos():
	healthTexture.hide()
	attackTexture.hide()
	selectedTexture.hide()

func update(update_data : AnimalData):
	data = update_data
	if update_data == null:
		empty = true
		visible = false
		return
	empty = false
	texture = update_data.sprite
	visible = true
	healthLabel.text = str(data.health)
	attackLabel.text = str(data.attack)
	selectedTexture.visible = selected
