class_name CloseNavigator
extends Node

const DELTA := 0.01
const MAX_TIME_TO_APPROACH := 3.0
const DIST_THRESHOLD := 180.0

var input_data: ShipInputData

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
	var items := MainState.world_grid.get_nearby(_position, 4)
	var t_min := MAX_TIME_TO_APPROACH
	_course = Vector2.ZERO
	for item in items:
		if item is RigidBody:
			var r := item.global_position - _position
			var v: Vector2= item.linear_velocity - _velocity
			var t: float = - (r.dot(v)) / (v.length_squared() + 0.0001)
			if t > 0 and t < t_min:
				var d := r + v * t
				var dist := d.length()
				if dist < DIST_THRESHOLD:
					t_min = t
					_course = -d.normalized()
					DebugDraw2d.line_vector(
						_position,
						_velocity * t_min,
						item._debug_color, 2, DELTA)
					DebugDraw2d.line_vector(
						item.global_position,
						item.linear_velocity * t_min,
						item._debug_color, 2, DELTA)
					var ints := 1.0 - dist / DIST_THRESHOLD
					DebugDraw2d.circle_filled(
						_position + _velocity * t_min,
						dist, 16, Color(item._debug_color, ints), DELTA)
					DebugDraw2d.line_vector(
						_position + _velocity * t_min,
						-d.normalized() * v.length(),
						item._debug_color, 4, DELTA)
					DebugDraw2d.circle(item.global_position, 64.0, 16, item._debug_color, 2, DELTA)
