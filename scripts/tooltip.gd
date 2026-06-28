class_name Tooltip
extends PanelContainer

@export var animalName : Label
@export var description : Label
@export var sprite : TextureRect

func update(data : AnimalData):
	sprite.texture = data.sprite
	animalName.text = data.name
	description.text = data.description


func _on_focus_entered() -> void:
	visible = false
	get_viewport().set_input_as_handled()
