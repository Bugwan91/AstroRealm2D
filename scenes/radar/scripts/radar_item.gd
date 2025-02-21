class_name RadarItem
extends Area2D

const RADIUS_MIN := 128.0

signal selected(item: RadarItem)
signal unselected(item: RadarItem)

@export var selectable := false
@export var detectable := true
@export var config: RadarItemConfig

var selection_size: float:
	get: return 2.0 * config.radius

var icon: RadarIcon
var selected_icon: RadarIcon
var destruction_handler: Callable

var canvas_position:Vector2:
	get:
		return _parent.extrapolator.canvas_position\
			if _parent is RigidBody\
			else get_global_transform_with_canvas().origin

var _collider: CollisionShape2D
var _parent: Node2D

func _ready() -> void:
	_parent = get_parent()
	monitoring = false
	monitorable = true
	collision_layer = 8
	collision_mask = 0
	if selectable:
		input_event.connect(handle_click)
	if is_instance_valid(config):
		configure(config)

func configure(conf: RadarItemConfig):
	config = conf.duplicate()
	init_shape(config.radius)
	icon = RadarIcon.create(config.icon)
	if is_instance_valid(config.selection_icon):
		selected_icon = RadarIcon.create(config.selection_icon)

func init_shape(radius: float) -> void:
	config.radius = radius
	if is_instance_valid(_collider):
		_collider.shape.radius = maxf(RADIUS_MIN, config.radius)
		return
	_collider = CollisionShape2D.new()
	_collider.shape = CircleShape2D.new()
	_collider.debug_color = Color(Color.BLUE, 0.0)
	_collider.shape.radius = maxf(RADIUS_MIN, config.radius)
	add_child(_collider)

func handle_click(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# HACK: It's better to untilize new world partitioning system to get nearest radar item.
	# Currently it's hard to click on object moving fast
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		selected.emit(self)

func reset() -> void:
	if RadarManager.instance.is_selected(self):
		unselected.emit(self)

func _on_destroy() -> void:
	icon.queue_free()
	if is_instance_valid(destruction_handler):
		destruction_handler.call(self)
	if is_instance_valid(selected_icon):
		selected_icon.queue_free()
