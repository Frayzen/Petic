class_name MarktetGlobal
extends Control

static var selected = null

var team_animals : Array[TeamAnimal] = []
var shop_animals : Array[ShopAnimal] = []

var shop_animal_scene := preload("res://scene/shop_animal.tscn")
var team_animal_scene := preload("res://scene/team_animal.tscn")
var coins := 999

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(3):
		var shop_animal = shop_animal_scene.instantiate()
		shop_animals.append(shop_animal)

	for i in range(5):
		var team_animal = team_animal_scene.instantiate()
		team_animals.append(team_animal)

func startShopping():
	coins = NetworkHandler.amountCoins
	refresh(0)

func buy(team_animal: TeamAnimal, shop_animal : ShopAnimal) -> bool:
	if shop_animal.data == null:
		return false
	if coins < 3:
		return false
	if team_animal.data != null:
		if team_animal.data.name == shop_animal.data.name:
			coins -= 3
			team_animal.increaseXp()
			shop_animal.bought()
			return true
		return false
	coins -= 3
	team_animal.update(shop_animal.data)
	shop_animal.bought()
	return true

func refresh(cost : int = 1) -> bool:
	if coins < 1:
		return false
	for shop_animal in shop_animals:
		if not shop_animal.frozen:
			shop_animal.generate()
	coins -= cost
	if selected != null and selected is ShopAnimal:
		selected = null
	return true

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = null
