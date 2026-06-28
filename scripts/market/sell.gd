extends TextureButton

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
    return _data is TeamAnimal 

func sell(animal : TeamAnimal):
    if Market.selected == animal:
        Market.selected = null
    animal.update(null)
    Market.coins += 1

func _drop_data(_at_position: Vector2, dropped_data: Variant) -> void:
    if dropped_data is not TeamAnimal :
        return
    var teamAnimal : TeamAnimal = dropped_data
    sell(teamAnimal)

func _on_pressed() -> void:
    if Market.selected is TeamAnimal:
        sell(Market.selected)

