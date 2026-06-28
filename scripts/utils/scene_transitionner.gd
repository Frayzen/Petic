extends Control

var transitionScene = preload("res://scene/scene_transitionner.tscn")
var _transition_instance: CanvasLayer = null

const transitionDuration : float = 1

signal complete

var transitionning : bool = false

func transition(nextScene: String, callBackLoaded = null) -> void:
    if _transition_instance:
        return
    transitionning = true
    get_viewport().set_input_as_handled()

    _transition_instance = transitionScene.instantiate()
    get_tree().root.add_child(_transition_instance)

    # Wait one frame so the node is fully ready in the tree
    await get_tree().process_frame

    var overlay: ColorRect = _transition_instance.get_node("ColorRect")

    # Force start from transparent, regardless of scene defaults
    overlay.modulate.a = 0.0

    var tween = get_tree().create_tween()
    tween.tween_property(overlay, "modulate:a", 1.0, transitionDuration / 2)
    await tween.finished

    get_tree().change_scene_to_file(nextScene)

    # Wait one frame after scene change too
    await get_tree().process_frame
    if callBackLoaded != null:
        callBackLoaded.call()

    tween = get_tree().create_tween()
    tween.tween_property(overlay, "modulate:a", 0.0, transitionDuration / 2)
    await tween.finished

    _transition_instance.queue_free()
    _transition_instance = null
    transitionning = false
    complete.emit()
