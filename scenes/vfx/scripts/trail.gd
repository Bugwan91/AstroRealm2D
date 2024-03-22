class_name TrailEffect
extends Line2D

@export var color := Color.WHITE:
	set(value):
		color = value
		modulate = color
@export_range(0, 5.0) var lifetime := 1.0

@onready var _parent: FloatingOriginBody = get_parent()

var _life := 0.0
var _points: PackedVector2Array
var _offset: Vector2

func _ready():
	process_priority = 999
	modulate = color
	_points = points
	_offset = position
	position = Vector2.ZERO

func _process(delta):
	_life += delta
	global_rotation = 0.0
	for index in range(0, points.size()):
		_points[index] -= _parent.shift
	_points.insert(0, _offset.rotated(_parent.rotation))
	if _life > lifetime:
		_points.remove_at(_points.size() - 1)
	points = _points
