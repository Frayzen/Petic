class_name FightingAnimal
extends Control

@export var render : AnimalRender
@export var damageSpawner : Control
@export var healthSpawner : Control
@export var attackSpawner : Control

var data : AnimalData 
var teamManager: FightingTeamManager

var damageIndicator = preload("res://scene/indicators/damage_indicator.tscn")
var healthIndicator = preload("res://scene/indicators/health_indicator.tscn")
var attackIndicator = preload("res://scene/indicators/attack_indicator.tscn")

func setup(team: FightingTeamManager, animalData : AnimalData, isHost : bool):
	teamManager = team
	data = animalData.duplicate(true)
	data.animal = self
	if not isHost:
		render.orientation.scale.x = -1
	render.setData(data)

func attack(target : FightingAnimal):
	render.animator.queue("attack")
	await delaySec(render.animator.get_animation("attack").get_marker_time("mid_attack") / render.animator.speed_scale)
	target.damage(data.attack, self)

func delaySec(duration : float):
	await get_tree().create_timer(duration).timeout

func delay(coeff : float = 0.1):
	await delaySec(coeff / FightingManager.instance.animationSpeed)

func spawnIndicator(amount : int, scene : PackedScene, spawner : Control):
	var instance : Indicator = scene.instantiate()
	instance.amount = amount
	spawner.add_child(instance)

func glow(color : Color):
	render.modulate = color
	await delay(0.25)
	render.modulate = Color.from_rgba8(255, 255, 255, 255)

func damage(amount : int, source : FightingAnimal):
	var damageEvent = FightEvent.new(FightEvent.Type.DAMAGED, self).setAmount(amount)
	addEvent(damageEvent)
	addEvent(FightEvent.new(FightEvent.Type.BEFORE_DAMAGED, self).setAmount(amount).setParameter(damageEvent).setSource(source))

func addEvent(event : FightEvent):
	if teamManager.isHost:
		FightingManager.instance.eventManager.hostEvents.push_front(event)
	else:
		FightingManager.instance.eventManager.otherEvents.push_front(event)

func applyDamaged(amount : int):
	spawnIndicator(-amount, damageIndicator, damageSpawner)
	data.health -= amount
	render.update()
	await glow(Color.from_rgba8(255, 100, 100, 255))

func buffHealth(amount : int):
	spawnIndicator(amount, healthIndicator, healthSpawner)
	data.health += amount
	render.update()
	await delay(0.5)

func buffAttack(amount : int):
	spawnIndicator(amount, attackIndicator, attackSpawner)
	data.attack += amount
	render.update()
	await delay(0.5)


func die():
	render.animator.queue("death")
	await render.animator.animation_finished
	modulate.a = 0
	teamManager.remove(self)
	var invAnimSpeed = (1 / FightingManager.instance.animationSpeed)
	var duration = 0.4 * invAnimSpeed
	var tween = create_tween()
	tween.tween_property(self, "custom_maximum_size:x", 0.0, duration)
	await tween.finished
	queue_free()
