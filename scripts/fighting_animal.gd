class_name FightingAnimal
extends Control

@export var render : AnimalRender

var data : AnimalData 

func setData(animalData : AnimalData, isHost : bool):
    data = animalData
    if not isHost:
        render.orientation.scale.x = 1
    render.setData(data)

func attack():
    render.animator.play("attack")

func damaged(opponent : FightingAnimal):
    print("OPPONENT " + opponent.data.name +" DEALS " + str(opponent.data.attack))
    print("BEF HEALTH " + str(data.health))
    data.health -= opponent.data.attack
    print("NEW HEALTH " + str(data.health))
    render.update()


func endOfAnimationEvent():
    return render.animator.animation_finished

func die():
    print("DEAD")
