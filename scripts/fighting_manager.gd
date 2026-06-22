class_name FightingManager
extends Control

var animationSpeed : float = 0.2

static var instance: FightingManager

@export var hostTeam : FightingTeamManager
@export var otherTeam : FightingTeamManager

func getAllAnimals() -> Array[FightingAnimal]:
    return hostTeam.animals + otherTeam.animals

func _ready() -> void:
    instance = self
    fight()

func updateAnimationSpeed(newValue : float):
    animationSpeed = newValue
    for animal in getAllAnimals():
        animal.render.animator.speed_scale = animationSpeed


func mutualAttack():
    hostTeam.front().attack(otherTeam.front())
    otherTeam.front().attack(hostTeam.front())
    await AsyncUtils.await_all([
        hostTeam.front().endOfAttack,
        otherTeam.front().endOfAttack,
    ])
func fight():
    while true:
        await mutualAttack()
        if hostTeam.animals.is_empty() or otherTeam.animals.is_empty():
            return
