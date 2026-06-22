class_name FightingManager
extends Control

var animationSpeed : float = 0.2

static var instance: FightingManager

@export var hostTeam : FightingTeamManager
@export var otherTeam : FightingTeamManager

@export var mainScreen : TextureRect

@export var winIndicator : TextureRect
@export var loseIndicator : TextureRect
@export var drawIndicator : TextureRect
@export var waitingIndicator : TextureRect

func getAllAnimals() -> Array[FightingAnimal]:
	return hostTeam.animals + otherTeam.animals

func _ready() -> void:
	winIndicator.visible = false
	loseIndicator.visible = false
	waitingIndicator.visible = false

	instance = self
	await transitionner.complete
	fight()

func updateAnimationSpeed(newValue : float):
	animationSpeed = newValue
	for animal in getAllAnimals():
		animal.render.animator.speed_scale = animationSpeed

func test(x):
	print(x)

func mutualAttack(first : FightingAnimal, second : FightingAnimal):
	var counter = Counter.new(2)
	first.data.call_before_attack(first, counter)
	second.data.call_before_attack(second, counter)
	await counter.completed
	counter = Counter.new(2)
	first.attack(otherTeam.front(), counter)
	second.attack(hostTeam.front(), counter)
	await counter.completed

func _finishedFight() -> void:
	NetworkHandler.finished_fight()
	await get_tree().create_timer(1).timeout
	if not transitionner.transitionning:
		waitingIndicator.visible = true

const postFightAnimationTime = 1.0
func fight():
	while not hostTeam.animals.is_empty() and not otherTeam.animals.is_empty():
		await mutualAttack(hostTeam.front(), otherTeam.front())
	var tween = create_tween()
	
	tween.tween_property(mainScreen, "modulate", Color.from_rgba8(50,50,50,255), postFightAnimationTime)
	if hostTeam.animals.is_empty():
		loseIndicator.scale = Vector2.ZERO
		loseIndicator.visible = true
		tween.tween_property(loseIndicator, "scale", Vector2.ONE, postFightAnimationTime)
	else:
		winIndicator.scale = Vector2.ZERO
		winIndicator.visible = true
		tween.tween_property(winIndicator, "scale", Vector2.ONE, postFightAnimationTime)
	tween.tween_callback(_finishedFight).set_delay(postFightAnimationTime * 2)
