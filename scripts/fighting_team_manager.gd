class_name FightingTeamManager
extends HBoxContainer

@export var isHost : bool
@export var opponentTeam : FightingTeamManager

var fightAnimal = preload("res://scene/fighting_animal.tscn")
var animals : Array[FightingAnimal] = []

func _ready() -> void:
	var animalDatas : Array[AnimalData] = []

	for i in range(3):
		var boar : AnimalData = load("res://animals/boar.tres").duplicate()
		boar.health = boar.baseHealth
		boar.attack = boar.baseAttack
		animalDatas.append(boar)
	animalDatas.append(null)
	animalDatas.append(null)

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
	animals.append(fightingAnimal)
	add_child(fightingAnimal)

func remove(animal : FightingAnimal):
	animals.erase(animal)
