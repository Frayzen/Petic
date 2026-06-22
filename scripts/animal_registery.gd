extends Node
class_name AnimalRegistery

var rng = RandomNumberGenerator.new()
var animals: Array[AnimalData] = []

func _init() -> void:
	var dir = DirAccess.open("res://animals")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			animals.append(load("res://animals/" + file))
	for animal in animals:
		print(animal.name + " has " + str(animal.baseHealth) + " health")

func pickRandom() -> AnimalData:
	var generated = animals[randi_range(0, animals.size() - 1)].duplicate()
	generated.health = generated.baseHealth
	generated.attack = generated.baseAttack
	return generated

func getAnimal(nameAnimal : String) -> AnimalData:
	for animal in animals:
		if animal.name == nameAnimal:
			return animal.duplicate()
	return null
