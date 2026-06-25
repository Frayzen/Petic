class_name FightEvent

enum Type { BEFORE_ATTACK, ATTACK };


var type : Type
var animal : FightingAnimal

# optional
var dependsOn : FightEvent
var target : FightingAnimal

func _init(pType : Type, pAnimal : FightingAnimal) -> void:
    type = pType
    animal = pAnimal

func setTarget(pTarget : FightingAnimal) -> FightEvent:
    target = pTarget
    return self

func setAnimal(pAnimal : FightingAnimal) -> FightEvent:
    animal = pAnimal
    return self

func setDepend(other : FightEvent):
    dependsOn = other
