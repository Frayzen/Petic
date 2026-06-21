extends Resource
class_name AnimalData

@export var sprite: Texture2D
@export var name: String
@export var health: int
@export var attack: int

func on_attack(target) -> void:
    pass

func on_damage(amount: int) -> void:
    pass

func on_bought() -> void:
    pass

func on_dead(attacker) -> void:
    pass
