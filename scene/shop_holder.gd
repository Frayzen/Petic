extends HBoxContainer

func _ready() -> void:
    for animal in Market.shop_animals:
        add_child(animal)
