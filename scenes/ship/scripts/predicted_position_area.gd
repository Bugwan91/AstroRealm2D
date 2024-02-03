class_name PredictedPositionArea
extends Area2D

@export_range(10, 1000) var radius := 240.0:
	set(value):
		radius = value
		_shape.radius = value

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
var _shape := CircleShape2D.new()

func _ready():
	_shape.radius = radius
	_collision_shape.shape = _shape

func update(end: float):
	position = Vector2(end, 0.0)

## Returns escaping thrust direction
func check_potential_collision() -> Vector2:
	if not monitoring: return Vector2.ZERO
	var vec = Vector2.ZERO
	for area in get_overlapping_areas():
		if area is PredictedPositionArea:
			var delta := area.global_position - global_position
			var dist := delta.length() * 0.5
			vec += delta.normalized() * (radius - dist)
	return Vector2.ZERO if vec.length() == 0.0 else vec.normalized()
