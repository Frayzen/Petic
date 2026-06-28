extends HBoxContainer

func _ready() -> void:
    for animal in Market.team_animals:
        add_child(animal)

func _exit_tree() -> void:
    for c in get_children():
        remove_child(c)
