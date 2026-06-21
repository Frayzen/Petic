extends AnimalData
class_name Wolf

func on_attack(target) -> void:
    print(name + " bites ferociously!")
    target.take_damage(attack * 2)
