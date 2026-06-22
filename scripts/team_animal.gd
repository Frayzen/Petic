class_name TeamAnimal
extends Control

@export var render : AnimalRender
var data : AnimalData = null

func _process(_delta: float) -> void:
    render.selected = (Market.selected == self)

func _ready() -> void:
    update(null)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
    return _data is ShopAnimal or _data is TeamAnimal 

func _drop_data(_at_position: Vector2, dropped_data: Variant) -> void:
    if dropped_data == self:
        return
    if dropped_data is ShopAnimal:
        Market.instance.buy(self, dropped_data)
    if dropped_data is TeamAnimal:
        if dropped_data.data != null and data != null and dropped_data.data.name == data.name:
            merge(dropped_data.data)
            dropped_data.update(null)
            return
        swap(dropped_data)


func swap(other : TeamAnimal):
    var tmp = data
    update(other.data)
    other.update(tmp)

func _on_pressed() -> void:
    if Market.selected != null:
        if Market.selected is ShopAnimal:
            if Market.instance.buy(self, Market.selected):
                Market.selected = null
        elif Market.selected is TeamAnimal:
            if data != null and Market.selected.data.name == data.name:
                merge(Market.selected.data)
                Market.selected.update(null)
            else:
                swap(Market.selected)
            Market.selected = null
        return
    else:
        if data != null:
            Market.selected = self
        else:
            Market.selected = null

func _get_drag_data(_at_position: Vector2) -> Variant:
    if render.empty:
        return false
    var c = Control.new()
    var dup = render.duplicate()
    dup.setData(render.data)
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
    render.setData(update_data)

func _notification(what):
    if what == NOTIFICATION_DRAG_END and not render.empty:
        render.visible = true

func increaseXp(xp : int = 1):
    for i in range(xp):
        data.xp += 1
        data.health += 1
        data.attack += 1
        if data.xp >= data.lvl + 1:
            data.lvl += 1
            data.xp = 0
    render.update()

func merge(other : AnimalData):
    var oLvl : int = other.lvl - 1
    @warning_ignore("integer_division")
    var nbAnimalMerged : int = int(oLvl * (oLvl + 1)) / 2 + other.xp
    increaseXp(nbAnimalMerged + 1)
    data.health += other.health - (other.baseHealth + nbAnimalMerged)
    data.attack += other.attack - (other.baseAttack + nbAnimalMerged)
