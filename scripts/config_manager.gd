class_name ConfigManager
extends Node

var config := ConfigFile.new()
const cfgPath = "user://settings.cfg"

func _init() -> void:
    config.load(cfgPath)

func load(key : String, default : String) -> String:
    return config.get_value("Setting", key, default)

func save(key : String, value : String):
    config.set_value("Setting", key, value)
    config.save(cfgPath)

