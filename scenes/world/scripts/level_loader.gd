class_name LevelLoader
extends Node

func _ready() -> void:
	WorldGridManager.instance.init_load()
