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
		render.orientation.scale.x = 1
	render.setData(data)

func attack(target : FightingAnimal, counter : Counter):
	render.animator.queue("attack")
	await delaySec(render.animator.get_animation("attack").get_marker_time("mid_attack") / render.animator.speed_scale)
	target.damaged(data.attack)
	await render.animator.animation_finished
	await checkDeath()
	counter.submit()

func delaySec(duration : float):
	await get_tree().create_timer(duration).timeout

func delay(coeff : float = 0.1):
	await delaySec(coeff * FightingManager.instance.animationSpeed)

func spawnIndicator(amount : int, scene : PackedScene, spawner : Control):
	var instance : Indicator = scene.instantiate()
	instance.amount = amount
	spawner.add_child(instance)

func glow(color : Color):
	render.modulate = color
	await delay()
	render.modulate = Color.from_rgba8(255, 255, 255, 255)

func damaged(amount : int):
	spawnIndicator(-amount, damageIndicator, damageSpawner)
	await glow(Color.from_rgba8(255, 100, 100, 255))
	data.health -= amount
	render.update()

func buffHealth(amount : int):
	spawnIndicator(amount, healthIndicator, healthSpawner)
	await delay(0.5)
	data.health += amount

func buffAttack(amount : int):
	spawnIndicator(amount, attackIndicator, attackSpawner)
	await delay(0.5)
	data.health += amount


func checkDeath():
	if data.health <= 0:
		render.animator.queue("death")
		await render.animator.animation_finished
		modulate.a = 0
		await die()

func die():
	await teamManager.remove(self)
	var invAnimSpeed = (1 / FightingManager.instance.animationSpeed)
	var duration = 0.4 * invAnimSpeed
	var tween = create_tween()
	tween.tween_property(self, "custom_maximum_size:x", 0.0, duration)
	await tween.finished
	queue_free()
