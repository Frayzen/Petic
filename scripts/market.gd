class_name Market
extends Control

static var instance: Market

static var selected = null

@export var coin_label : Label
@export var shop_holder : HBoxContainer
@export var team_holder : HBoxContainer

var team_animals : Array[TeamAnimal] = []
var shop_animals : Array[ShopAnimal] = []

var shop_animal_scene := preload("res://scene/shop_animal.tscn")
var team_animal_scene := preload("res://scene/team_animal.tscn")
var coins := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    instance = self
    coins = NetworkHandler.amountCoins

    for i in range(3):
        var shop_animal = shop_animal_scene.instantiate()
        shop_animals.append(shop_animal)
        shop_holder.add_child(shop_animal)

    for i in range(5):
        var team_animal = team_animal_scene.instantiate()
        team_animals.append(team_animal)
        team_holder.add_child(team_animal)

    var animalDatas = NetworkHandler.hostTeam
    if animalDatas != null:
        for i in range(animalDatas.size()):
            if animalDatas[i] != null:
                team_animals[i].update(animalDatas[i])
    # buy(team_animals[0], shop_animals[0])

func buy(team_animal: TeamAnimal, shop_animal : ShopAnimal) -> bool:
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

func refresh() -> bool:
    if coins < 1:
        return false
    for shop_animal in shop_animals:
        shop_animal.generate()
    coins -= 1
    if selected != null and selected is ShopAnimal:
        selected = null
    return true

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            selected = null
