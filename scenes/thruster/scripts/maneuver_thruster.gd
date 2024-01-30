class_name ManeuverThruster
extends Thruster

const TORQUE_MULT := 0.01

var _torque: float = 0
var torque_throttle: float = 0 : set = _set_torque_throttle
var torque: float = 0

const TORQUE_THRESHOLD = 0.01
const THRESHOLD = 0.001

func _set_enabled(value):
	super(value)
	_calculate_torgue()

func _set_torque_throttle(value):
	if not enabled:
		return
	if sign(value) != sign(_torque):
		value = 0
	value = clamp(abs(value), 0, 1)
	if torque_throttle != value:
		torque_throttle = value
		_flame.run(max(throttle, torque_throttle))
		torque = torque_throttle * _torque

func setup(value: float):
	super(value)
	_calculate_torgue()
	_flame.setup_sound(-20, 2)
	_flame.show_flame = false
	_flame.show_zoom = 0.5

func _calculate_torgue():
	var value = TORQUE_MULT * _thrust * (position.x * _force_direction.y - position.y * _force_direction.x) if enabled and _thrust > 0 else 0.0
	_torque = value if abs(value) > TORQUE_THRESHOLD else 0.0

func apply_strafe(value: Vector2):
	throttle = value.dot(_force_direction)

func apply_torque(value: float):
	torque_throttle = value

func estimated_force(strafe_direction: Vector2) -> float:
	return clamp(strafe_direction.dot(_force_direction), 0, 1) * _thrust

func estimated_torque(direction: float) -> float:
	return _torque if (_torque > 0 and direction > 0) or (_torque < 0 and direction < 0) else 0.0
