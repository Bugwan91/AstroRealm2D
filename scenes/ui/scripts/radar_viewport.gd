class_name RadarViewport
extends Control

const DEF_RADIUS := 200.0

@export_range(0.01, 1.0) var update_interval := 0.1
@export var _container: Control
var radius := 200.0

var _current_delta := 0.0
var _scale := 1.0

func _ready() -> void:
	radius = custom_minimum_size.x * 0.5
	_scale = radius / DEF_RADIUS
	RadarManager.instance.radar_view = self
	visible = RadarManager.instance.is_active()

func _physics_process(delta: float) -> void:
	_current_delta += delta
	if _current_delta > update_interval:
		RadarManager.instance.update_icons()
		_current_delta = 0.0

func add_icon(icon: RadarIcon) -> void:
	if not is_instance_valid(icon): return
	if icon.get_parent() != _container:
		icon.tree_exiting.connect(_on_icon_destroy.bind(icon))
		_container.add_child(icon)

func remove_icon(icon: RadarIcon) -> void:
	if not is_instance_valid(icon): return
	# FIXME: Condition "p_child->data.parent != this" is true.
	if icon.get_parent() == _container:
		icon.tree_exiting.disconnect(_on_icon_destroy.bind(icon))
		_container.remove_child(icon)

func reset() -> void:
	for icon in _container.get_children():
		_container.remove_child(icon)

func _on_icon_destroy(icon: RadarIcon):
	icon.tree_exiting.disconnect(_on_icon_destroy.bind(icon))
