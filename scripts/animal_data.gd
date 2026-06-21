extends Resource
class_name AnimalData

@export var sprite: Texture2D
@export var name: String
@export var baseHealth: int
@export var baseAttack: int

var health : int
var attack : int

var xp : int = 0
var lvl : int = 1

func on_attack(target) -> void:
    pass

func on_damage(amount: int) -> void:
    pass

func on_bought() -> void:
    pass

func on_dead(attacker) -> void:
    pass
