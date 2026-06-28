class_name ShopAnimal
extends Button

@export var render: AnimalRender

var data: AnimalData
var frozen : bool = false

func _process(_delta: float) -> void:
	render.selected = (Market.selected == self)

func _ready() -> void:
	render.hideLevels()
	generate()

func freeze():
	frozen = true
	render.frozenIcon.visible = true

func unfreeze():
	frozen = false
	render.frozenIcon.visible = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if data == null:
		return false
	var c = Control.new()
	var dup = render.duplicate()
	dup.hideInfos()
	dup.position -= size * 0.5
	c.add_child(dup)
	render.visible = false
	c.propagate_maximum_size = true
	c.custom_minimum_size = size
	c.custom_maximum_size = size
	c.size = size  # Match the container size to the preview
	
	set_drag_preview(c)
	get_viewport().set_input_as_handled()

	return self

func _notification(what):
	if what == NOTIFICATION_DRAG_END and data != null:
		render.visible = true

func _on_pressed() -> void:
	if Market.selected != self and data != null:
		Market.selected = self
	else:
		Market.selected = null

func generate():
	data = animalRegistery.pickRandom()
	render.setData(data)
	render.visible = true

func bought():
	unfreeze()
	data = null
	render.visible = false
