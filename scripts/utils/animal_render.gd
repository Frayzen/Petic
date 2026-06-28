class_name AnimalRender
extends Control

@export var animator : AnimationPlayer
@export var animalSprite : TextureRect
@export var healthLabel : Label
@export var attackLabel : Label
@export var levelLabel : Label
@export var selectedTexture : TextureRect
@export var attackTexture : TextureRect
@export var healthTexture : TextureRect
@export var levelTexture : TextureRect
@export var stars : HBoxContainer
@export var orientation : Control
@export var tooltip : Tooltip
@export var frozenIcon : TextureRect

var empty_star = preload("res://scene/stars/empty_star.tscn")
var full_star = preload("res://scene/stars/full_star.tscn")

var data : AnimalData = null
var empty : bool = true
var selected : bool = false
var previousSelected : bool = false


func _process(_delta: float) -> void:
	if previousSelected != selected:
		selectedTexture.visible = selected
		tooltip.visible = selected
	previousSelected = selected

func hideLevels():
	levelTexture.hide()
	stars.hide()

func hideInfos():
	healthTexture.hide()
	attackTexture.hide()
	selectedTexture.hide()

func setData(update_data : AnimalData):
	data = update_data
	if update_data == null:
		empty = true
		visible = false
		return
	tooltip.update(data)
	empty = false
	animalSprite.texture = update_data.sprite
	visible = true
	healthLabel.text = str(data.health)
	attackLabel.text = str(data.attack)
	selectedTexture.visible = selected
	updateXp()

func update():
	setData(data)

func updateXp():
	for n in stars.get_children():
		stars.remove_child(n)
		n.queue_free()
	for i in range(data.lvl + 1):
		if data.xp <= i:
			stars.add_child(empty_star.instantiate())
		else:
			stars.add_child(full_star.instantiate())
	levelLabel.text = str(data.lvl)

func playAnimation(animationName : String):
	animator.play(animationName)
	await animator.animation_finished

func endOfAnim():
	if not animator.is_playing():
		await get_tree().create_timer(0.1).timeout
		return
	var time = animator.current_animation_length / animator.speed_scale
	await get_tree().create_timer(time).timeout
