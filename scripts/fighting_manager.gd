extends Control

const animationSpeed : float = 1

@export var hostTeam : HBoxContainer
@export var otherTeam : HBoxContainer

@export var otherDamage : TextureRect
@export var otherDamageLabel : Label
@export var hostDamage : TextureRect
@export var hostDamageLabel : Label

var fightAnimal = preload("res://scene/fighting_animal.tscn")

var hostFightAnimals : Array[FightingAnimal] = []
var otherFightAnimals : Array[FightingAnimal] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var hostAnimalDatas : Array[AnimalData] = []
	var otherAnimalDatas : Array[AnimalData] = []

	for i in range(3):
		var boar : AnimalData = load("res://animals/boar.tres").duplicate()
		boar.health = boar.baseHealth
		boar.attack = boar.baseAttack
		hostAnimalDatas.append(boar)
	hostAnimalDatas.append(null)
	hostAnimalDatas.append(null)
	for i in range(5):
		var cat : AnimalData = load("res://animals/cat.tres").duplicate()
		cat.health = cat.baseHealth
		cat.attack = cat.baseAttack
		otherAnimalDatas.append(cat)
	
	for animalData in hostAnimalDatas:
		summon(animalData, true)
	for animalData in otherAnimalDatas:
		summon(animalData, false)

	# prepare fight
	for animal in hostFightAnimals:
		animal.render.damage_dealt.connect(_showDamages)

	setAnimationSpeed()
	fight()


func summon(animalData : AnimalData, isHostTeam : bool):
	if animalData == null:
		return

	var fightingAnimal : FightingAnimal = fightAnimal.instantiate()
	fightingAnimal.setData(animalData, isHostTeam)
	if isHostTeam:
		hostFightAnimals.append(fightingAnimal)
		hostTeam.add_child(fightingAnimal)
	else:
		otherFightAnimals.append(fightingAnimal)
		otherTeam.add_child(fightingAnimal)

func _showDamages():

	hostFightAnimals[0].damaged(otherFightAnimals[0])
	otherFightAnimals[0].damaged(hostFightAnimals[0])

	var tween = create_tween()
	otherDamageLabel.text = "-" + str(hostFightAnimals[0].data.attack)
	hostDamageLabel.text = "-" + str(otherFightAnimals[0].data.attack)

	hostDamage.modulate.a = 1
	otherDamage.modulate.a = 1
	var invAnimSpeed = (1 / animationSpeed)
	tween.tween_property(hostDamage, "modulate:a", 0.0, 0.4 * invAnimSpeed)
	tween.parallel().tween_property(otherDamage, "modulate:a", 0.0, 0.4 * invAnimSpeed)

func setAnimationSpeed():
	for animal in hostFightAnimals:
		animal.render.animator.speed_scale = animationSpeed
	for animal in otherFightAnimals:
		animal.render.animator.speed_scale = animationSpeed

func checkDeath(animals : Array[FightingAnimal]):
	for animal in animals:
		if animal.data.health <= 0:
			animal.die()
			animals.erase(animal)
			animal.queue_free()
			


func fight():
	while true:
		hostFightAnimals[0].attack()
		otherFightAnimals[0].attack()
		await hostFightAnimals[0].endOfAnimationEvent()
			
		checkDeath(hostFightAnimals)
		checkDeath(otherFightAnimals)
		if hostFightAnimals.is_empty() or otherFightAnimals.is_empty():
			return
