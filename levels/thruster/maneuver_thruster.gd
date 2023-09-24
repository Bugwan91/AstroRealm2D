extends Thruster
class_name ManeuverThruster

enum TYPE { STRAFE, ROTATE }

var _strafe_calibrator: float = 1
var _strafe_throttle: float = 0:
	get:
		return _strafe_throttle * _strafe_calibrator
	set(value):
		_strafe_throttle = value
		throttle = _strafe_throttle + _rotation_throttle

var _rotation_calibrator: float = 1
var _rotation_throttle: float = 0:
	get:
		return _rotation_throttle * _rotation_calibrator
	set(value):
		_rotation_throttle = value
		throttle = _strafe_throttle + _rotation_throttle

var torque: float = 0

func setup(value: float):
	super(value)
	_calculate_torgue()

func _calculate_torgue():
	var forward = transform.x
	torque = _thrust * (position.x * forward.y - position.y * forward.x) if enabled and _thrust > 0 else 0

func apply_throttle(type: TYPE, value: float):
	match type:
		TYPE.STRAFE:
			_strafe_throttle = value
		TYPE.ROTATE:
			_rotation_throttle = value
