extends Resource
class_name AnimalData

@export var sprite: Texture2D
@export var name: String
@export var baseHealth: int
@export var baseAttack: int

@export var health : int
@export var attack : int
@export var xp : int = 0
@export var lvl : int = 1

var animal : FightingAnimal = null

func serializeState(_dict : Dictionary):
	pass

func deserializeState(_dict : Dictionary):
	pass

# Serialize to Dictionary (for network/save)
func to_dict() -> Dictionary:
	var dict = {
		"name": name,
		"baseHealth": baseHealth,
		"baseAttack": baseAttack,
		"health": health,
		"attack": attack,
		"xp": xp,
		"lvl": lvl
	}
	
	if sprite:
		dict["sprite_path"] = sprite.resource_path

	serializeState(dict)

	return dict

# Deserialize from Dictionary
static func from_dict(dict: Dictionary):
	var data = animalRegistery.getAnimal(dict.get("name"))

	data.name = dict.get("name", "Unknown")
	data.baseHealth = dict.get("baseHealth", 10)
	data.baseAttack = dict.get("baseAttack", 5)
	data.health = dict.get("health", data.baseHealth)
	data.attack = dict.get("attack", data.baseAttack)
	data.xp = dict.get("xp", 0)
	data.lvl = dict.get("lvl", 1)
	
	# Load texture if path exists
	if dict.has("sprite_path"):
		data.sprite = load(dict["sprite_path"])

	data.deserializeState(dict)
	
	return data

func before_attack(_target : FightingAnimal):
	pass

func call_before_attack(target : FightingAnimal, counter : Counter):
	await before_attack(target)
	counter.submit()

func on_damage(_amount: int, _attacker : FightingAnimal):
	pass

func on_bought() -> void:
	pass

func on_dead(_attacker) -> void:
	pass
