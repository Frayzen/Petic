extends AnimalData
class_name Wolf

func before_attack(_target : FightingAnimal):
    animal.buffAttack(1)
    animal.buffHealth(1)
    await animal.render.playAnimation("power_up")

