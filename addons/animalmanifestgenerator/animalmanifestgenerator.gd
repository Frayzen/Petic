@tool
extends EditorPlugin

func _generate_manifest():
    var dir = DirAccess.open("res://animals")
    if dir == null:
        return
    var manifest = []
    for file in dir.get_files():
        if file.ends_with(".tres"):
            manifest.append("res://animals/" + file)

    var file = FileAccess.open("res://animals_manifest.json", FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(manifest))


func _enable_plugin() -> void:
    pass


func _disable_plugin() -> void:
    pass


func _build() -> bool:
    _generate_manifest()
    return true

func _enter_tree() -> void:
    _generate_manifest()
    pass


func _exit_tree() -> void:
    pass
