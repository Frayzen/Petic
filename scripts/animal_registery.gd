extends Node
class_name AnimalRegistry

var rng = RandomNumberGenerator.new()
var animals: Array[AnimalData] = []

func _init() -> void:
	var dir = DirAccess.open("res://animals")
	for file in dir.get_files():
		if file.ends_with(".tres"):
			animals.append(load("res://animals/" + file))
	for animal in animals:
		print(animal.name + " has " + str(animal.health) + " health")

func pickRandom() -> AnimalData:
	return animals[randi_range(0, animals.size() - 1)]
