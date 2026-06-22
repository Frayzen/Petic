class_name FightingAnimal
extends Control

@export var render : AnimalRender
@export var damageSpawner : Control

var data : AnimalData 
var attackTarget : FightingAnimal
var teamManager: FightingTeamManager

var damageIndicator = preload("res://scene/damage_indicator.tscn")

signal endOfAttack

func _ready() -> void:
	render.damage_dealt.connect(attackComplete)

func setup(team: FightingTeamManager, animalData : AnimalData, isHost : bool):
	teamManager = team
	data = animalData
	if not isHost:
		render.orientation.scale.x = 1
	render.setData(data)

func attack(target : FightingAnimal):
	attackTarget = target
	render.animator.queue("attack")
	await render.animator.animation_finished
	await checkDeath()
	endOfAttack.emit()

func damaged(amount : int):
	var damageIndicatorInstance : DamageIndicator = damageIndicator.instantiate()
	damageIndicatorInstance.damageAmount = amount
	damageSpawner.add_child(damageIndicatorInstance)
	data.health -= amount
	render.modulate = Color.from_rgba8(255, 100, 100, 255)
	await get_tree().create_timer(0.1 * FightingManager.animationSpeed).timeout
	render.modulate = Color.from_rgba8(255, 255, 255, 255)
	render.update()

func checkDeath():
	if data.health <= 0:
		render.animator.queue("death")
		await render.animator.animation_finished
		modulate.a = 0
		await die()

func die():
	await teamManager.remove(self)
	var invAnimSpeed = (1 / FightingManager.animationSpeed)
	var delay = 0.4 * invAnimSpeed
	var tween = create_tween()
	tween.tween_property(self, "custom_maximum_size:x", 0.0, delay)
	await tween.finished
	queue_free()

func attackComplete():
	attackTarget.damaged(data.attack)
