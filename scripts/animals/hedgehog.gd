class_name Hedgehog
extends AnimalData

func before_die() -> void:
    FightingManager.instance.processAll(func(target : FightingAnimal, _isHost : bool): target.damage(2))


