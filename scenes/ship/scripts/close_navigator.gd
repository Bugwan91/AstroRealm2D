class_name CloseNavigator
extends Node

const DELTA := 0.05
const MAX_TIME_TO_APPROACH := 3.0

@export var input_data: ShipInputData
@export var radius := 64.0

var _total_delta := 0.0
var _delta := 0.0
var _position := Vector2.ZERO
var _velocity := Vector2.ZERO
var _course := Vector2.ZERO

func update_course(delta: float, position: Vector2, velocity: Vector2) -> Vector2:
	_total_delta += delta
	if _total_delta > DELTA:
		_delta = delta
		_position = position
		_velocity = velocity
		_update_avoidance_course()
		_total_delta = 0.0
	return _course

func _update_avoidance_course():
	var items := MainState.world_grid.get_nearby(_position)
	var t_min := MAX_TIME_TO_APPROACH
	_course = Vector2.ZERO
	for item in items:
		if item is RigidBody:
			var b := item as RigidBody
			var r := b.global_position - _position
			var v := b.linear_velocity - _velocity
			var t := - (r.dot(v)) / (v.length_squared() + 0.0001)
			if t > 0 and t < t_min:
				var d := r + v * t
				var dist := d.length()
				if dist < b.radius + radius:
					t_min = t
					var ints := dist / (b.radius + radius)
					_course = _course * ints - d.normalized()
					DebugDraw2d.line_vector(
						_position,
						_velocity * t_min,
						b._debug_color, 2, DELTA)
					DebugDraw2d.line_vector(
						b.global_position,
						b.linear_velocity * t_min,
						b._debug_color, 2, DELTA)
					DebugDraw2d.circle_filled(
						_position + _velocity * t_min,
						dist, 16, Color(b._debug_color, 1.0 - ints), DELTA)
					DebugDraw2d.line_vector(
						_position + _velocity * t_min,
						_course * v.length(),
						b._debug_color, 4, DELTA)
					DebugDraw2d.circle(b.global_position, b.radius, 16, b._debug_color, 2, DELTA)
