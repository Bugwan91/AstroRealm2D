class_name RadarViewport
extends Control

const DEF_RADIUS := 200.0

@export_range(0.01, 1.0) var update_interval := 0.1
var radius := 200.0

var _icons: Array[RadarIcon] = []
var _current_delta := 0.0
var _scale := 1.0

func _ready() -> void:
	radius = custom_minimum_size.x * 0.5
	_scale = radius / DEF_RADIUS
	MainState.radar_manager.radar_view = self

func _physics_process(delta: float) -> void:
	_current_delta += delta
	if _current_delta > update_interval:
		MainState.radar_manager.update_icons()
		_current_delta = 0.0

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
