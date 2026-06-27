class_name Rabbit
extends AnimalData

func before_attack(target : FightingAnimal):
    var tmp = target.data.health
    target.data.health = target.data.attack
    target.data.attack = tmp
    target.render.update()
    await target.render.playAnimation("turn")
