extends LineEdit

func _process(_delta: float) -> void:
    if not has_focus():
        if text.is_valid_int():
            var val = int(text)
            if val > 0 and val < 999:
                return
        text = "1"

func _input(event: InputEvent):
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
        var evLocal = make_input_local(event)
        if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
            release_focus()
