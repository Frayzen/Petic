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
    
    # Store texture path instead of the texture itself
    if sprite:
        dict["sprite_path"] = sprite.resource_path
    
    return dict

# Deserialize from Dictionary
static func from_dict(dict: Dictionary):
    animalRegistery.getAnimal(dict.get("name"))

    var data = AnimalData.new()
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
    
    return data

# Original methods
func on_attack(target) -> void:
    pass

func on_damage(amount: int) -> void:
    pass

func on_bought() -> void:
    pass

func on_dead(attacker) -> void:
    pass
