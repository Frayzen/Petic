extends HBoxContainer

func _ready() -> void:
    for animal in Market.team_animals:
        add_child(animal)

