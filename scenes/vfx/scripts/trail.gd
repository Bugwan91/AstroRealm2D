class_name TrailEffect
extends Line2D

@export var color := Color.WHITE:
	set(value):
		color = value
		modulate = color

@export_range(0, 5.0) var lifetime := 1.0

# CAUTION: Not implemented
@export_range(0, 20) var skip_tiks := 5

@export var velocity: Vector2:
	set(value):
		velocity = value
		_update_is_global()

@onready var _parent: Node2D = get_parent()

@onready var _last_position := position

var _is_global: bool
var _life := 0.0
var _points: PackedVector2Array
var _offset := Vector2.ZERO

func _ready():
	process_priority = 999
	modulate = color
	_points = points
	_last_position = _parent.position + _relative_position()
	_update_is_global()

func _physics_process(delta):
	_life += delta
	global_rotation = 0.0
	var shift: Vector2
	if _is_global:
		var current_position := _parent.position + _relative_position()
		shift = current_position - _last_position
		_last_position = current_position
	else:
		shift = velocity * delta
	for index in range(0, points.size()):
		_points[index] -= shift
	_points.insert(0, Vector2.ZERO)
	if _life > lifetime:
		_points.remove_at(_points.size() - 1)
	points = _points

func _relative_position() -> Vector2:
	return position.rotated(_parent.rotation)

func _update_is_global():
	_is_global = is_zero_approx(velocity.length_squared())
