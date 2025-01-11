class_name RadarViewport
extends Control

@export var radius := 256.0

# TODO: do I need this array?
var _icons: Array[RadarIcon] = []

func _ready() -> void:
	MainState.radar_manager.radar_view = self

func _physics_process(delta: float) -> void:
	MainState.radar_manager.update_icons()

func add_icon(icon: RadarIcon):
	if not is_instance_valid(icon): return
	if not _icons.has(icon):
		_icons.append(icon)
		add_child(icon)

func remove_icon(icon: RadarIcon):
	if not is_instance_valid(icon): return
	_icons.erase(icon)
	remove_child(icon)

func reset():
	for icon in _icons:
		remove_child(icon)
	_icons.clear()
