extends AnimalData
class_name Bear

func before_fight():
    animal.buffHealth(attack)
    await animal.render.playAnimation("power_up")
