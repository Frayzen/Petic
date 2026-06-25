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

var eventManager : EventManager

func getAllAnimals() -> Array[FightingAnimal]:
    return hostTeam.animals + otherTeam.animals

func _ready() -> void:
    eventManager = EventManager.new(self)
    winIndicator.visible = false
    loseIndicator.visible = false
    waitingIndicator.visible = false

    instance = self
    await transitionner.complete
    fight()

func isHostWin():
    return otherTeam.animals.is_empty() and not hostTeam.animals.is_empty()

func isOtherWin():
    return not otherTeam.animals.is_empty() and hostTeam.animals.is_empty()

func isDraw():
    return otherTeam.animals.is_empty() and hostTeam.animals.is_empty()

func isFinished():
    return hostTeam.animals.is_empty() or otherTeam.animals.is_empty()

func updateAnimationSpeed(newValue : float):
    animationSpeed = newValue
    for animal in getAllAnimals():
        animal.render.animator.speed_scale = animationSpeed

func test(x):
    print(x)

func _finishedFight() -> void:
    NetworkHandler.finished_fight()
    await get_tree().create_timer(1).timeout
    if not transitionner.transitionning:
        waitingIndicator.visible = true

const postFightAnimationTime = 1.0
func fight():
    await eventManager.process()
    var tween = create_tween()
    
    tween.tween_property(mainScreen, "modulate", Color.from_rgba8(50,50,50,255), postFightAnimationTime)
    var indicator = drawIndicator
    if isHostWin():
        indicator = winIndicator
    elif isOtherWin():
        indicator = loseIndicator
    indicator.scale = Vector2.ZERO
    indicator.visible = true
    tween.tween_property(indicator, "scale", Vector2.ONE, postFightAnimationTime)
    tween.tween_callback(_finishedFight).set_delay(postFightAnimationTime * 2)
