class_name RadarItem
extends Area2D

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

var _collider: CollisionShape2D

func _ready():
	monitoring = false
	monitorable = true
	collision_layer = 8
	collision_mask = 0
	init_shape(config.radius)
	icon = RadarIcon.create(config.icon)
	if is_instance_valid(config.selection_icon):
		selected_icon = RadarIcon.create(config.selection_icon)
	if selectable:
		input_event.connect(handle_click)

func handle_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		selected.emit(self)

func get_canvas_position() -> Vector2:
	return get_global_transform_with_canvas().origin

func init_shape(radius: float):
	config = config.duplicate()
	config.radius = radius
	if is_instance_valid(_collider):
		_collider.shape.radius = config.radius
		return
	_collider = CollisionShape2D.new()
	_collider.shape = CircleShape2D.new()
	_collider.debug_color = Color(Color.BLUE, 0.0)
	_collider.shape.radius = config.radius
	add_child(_collider)

func _on_destroy():
	if is_instance_valid(destruction_handler):
		destruction_handler.call(self)

func connect_on_destroy():
	tree_exiting.connect(_on_destroy)

func disconnect_on_destroy():
	tree_exiting.disconnect(_on_destroy)
