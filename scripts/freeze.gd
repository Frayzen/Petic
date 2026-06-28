extends TextureButton

func _on_pressed() -> void:
    if Market.selected != null and Market.selected is ShopAnimal:
        var shopAnimal : ShopAnimal = Market.selected 
        if shopAnimal.frozen:
            shopAnimal.unfreeze()
        else:
            shopAnimal.freeze()

