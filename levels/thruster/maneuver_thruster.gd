class_name ManeuverThruster
extends Thruster

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
	if (value > 0 and _torque < 0) or (value < 0 and _torque > 0):
		value = 0
	value = clamp(abs(value), 0, 1)
	if torque_throttle != value:
		torque_throttle = value
		_update_flame()
		torque = torque_throttle * _torque

func setup(value: float):
	super(value)
	_calculate_torgue()

func _calculate_torgue():
	var value = _thrust * (position.x * _force_direction.y - position.y * _force_direction.x) if enabled and _thrust > 0 else 0.0
	_torque = value if abs(value) > TORQUE_THRESHOLD else 0.0

func apply_strafe(value: Vector2):
	throttle = value.dot(_force_direction)

func apply_torque(value: float):
	torque_throttle = value

func estimated_force(strafe_direction: Vector2) -> float:
	return clamp(strafe_direction.dot(_force_direction), 0, 1) * _thrust

func estimated_torque(direction: float) -> float:
	return _torque if (_torque > 0 and direction > 0) or (_torque < 0 and direction < 0) else 0.0

func _update_flame():
	if throttle > 0 or torque_throttle > 0:
		_flame.show()
		var value = max(throttle, torque_throttle)
		_flame.modulate.a = value
		# TODO: Rework thrusters sound
		_sound.volume_db = -20 - (40 - 40 * value)
		if not _sound.playing:
			_sound.play()
		if value < 0.1: #Threshold
			_sound.stop()
	else:
		_flame.hide()
		_sound.stop()
