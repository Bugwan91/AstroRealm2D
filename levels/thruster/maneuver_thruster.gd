extends Thruster
class_name ManeuverThruster

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
	var value = _thrust * (position.x * _force_direction.y - position.y * _force_direction.x) if enabled and _thrust > 0 else 0
	_torque = value if abs(value) > TORQUE_THRESHOLD else 0

func apply_strafe(value: Vector2):
	throttle = value.dot(_force_direction)

func apply_torque(value: float):
	torque_throttle = value

func _update_flame():
	if throttle > 0 or torque_throttle > 0:
		_flame.show()
		_flame.modulate.a = max(throttle, torque_throttle)
		_sound.play()
		_sound.volume_db = -20 - (10 - 10 * max(throttle, torque_throttle))
	else:
		_flame.hide()
		_sound.stop()
