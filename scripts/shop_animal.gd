class_name ShopAnimal
extends Button

@export var render: AnimalRender
var data: AnimalData

static var selected : ShopAnimal = null

func _process(_delta: float) -> void:
	render.selected = (selected == self)


func _ready() -> void:
	render.flip_h = true
	generate()

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
	if selected != self and data != null:
		selected = self
	else:
		selected = null

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = null

func generate():
	data = registery.pickRandom()
	render.update(data)
	render.visible = true

func bought():
	data = null
	render.visible = false
