class_name TeamAnimal
extends Control

@export var render : AnimalRender
var data : AnimalData = null

func _ready() -> void:
	update(null)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return _data is ShopAnimal or _data is TeamAnimal 

func _drop_data(_at_position: Vector2, dropped_data: Variant) -> void:
	if dropped_data is ShopAnimal:
		Market.instance.buy(self, dropped_data)
	if dropped_data is TeamAnimal:
		var tmp = data
		update(dropped_data.data)
		dropped_data.update(tmp)

func _on_pressed() -> void:
	if ShopAnimal.selected != null:
		Market.instance.buy(self, ShopAnimal.selected)
		ShopAnimal.selected = null

func _get_drag_data(_at_position: Vector2) -> Variant:
	if render.empty:
		return false
	var c = Control.new()
	var dup = render.duplicate()
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

func update(update_data : AnimalData):
	data = update_data
	render.update(update_data)

func _notification(what):
	if what == NOTIFICATION_DRAG_END and not render.empty:
		render.visible = true
