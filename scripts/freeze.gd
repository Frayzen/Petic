extends TextureButton

func _on_pressed() -> void:
    if Market.selected != null and Market.selected is ShopAnimal:
        var shopAnimal : ShopAnimal = Market.selected 
        if shopAnimal.frozen:
            shopAnimal.unfreeze()
        else:
            shopAnimal.freeze()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return data is ShopAnimal 

func _drop_data(_at_position: Vector2, dropped_data: Variant) -> void:
    if dropped_data == self:
        return
    if dropped_data is ShopAnimal:
        if dropped_data.frozen:
            dropped_data.unfreeze()
        else:
            dropped_data.freeze()
