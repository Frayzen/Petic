class_name FightEvent

enum Type { BEFORE_ATTACK, ATTACK, BEFORE_FIGHT, BEFORE_DIE, DIE, BEFORE_DAMAGED, DAMAGED,
    # UNIMPLEMENTED
    BEFORE_TURN, BEFORE_FRIEND_ATTACK, BEFORE_FRIEND_DAMAGED, BEFORE_FRIEND_DIES
};

func _to_string() -> String:
    return Type.keys()[type]

var type : Type
var animal : FightingAnimal

# optional
var dependsOn : FightEvent
var target : FightingAnimal
var source : FightingAnimal

var amount : int
var parameter

func _init(pType : Type, pAnimal : FightingAnimal) -> void:
    type = pType
    animal = pAnimal

func setTarget(pTarget : FightingAnimal) -> FightEvent:
    target = pTarget
    return self

func setAnimal(pAnimal : FightingAnimal) -> FightEvent:
    animal = pAnimal
    return self

func setDepend(other : FightEvent) -> FightEvent:
    dependsOn = other
    return self

func setAmount(pAmount : int) -> FightEvent:
    amount = pAmount
    return self

func setParameter(pParameter) -> FightEvent:
    parameter = pParameter
    return self

func setSource(pSource) -> FightEvent:
    source = pSource
    return self

