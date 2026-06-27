class_name FightingTeamManager
extends HBoxContainer

@export var isHost : bool
@export var opponentTeam : FightingTeamManager

var fightAnimal = preload("res://scene/fighting_animal.tscn")
var animals : Array[FightingAnimal] = []

func _ready() -> void:
    var animalDatas = NetworkHandler.hostTeam if isHost else NetworkHandler.otherTeam
    for animalData in animalDatas:
        summon(animalData)

func front():
    return animals.front()

func summon(animalData : AnimalData):
    if animalData == null:
        return
    var fightingAnimal : FightingAnimal = fightAnimal.instantiate()
    fightingAnimal.setup(self, animalData, isHost)
    fightingAnimal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    animals.push_front(fightingAnimal)
    add_child(fightingAnimal)
    if not isHost:
        move_child(fightingAnimal, 0)

func getDeadAnimals():
    var deads = animals.filter(func(animal:FightingAnimal): return animal.data.health <= 0)
    for d in deads:
        animals.erase(d)
    return deads

func remove(animal : FightingAnimal):
    animals.erase(animal)
