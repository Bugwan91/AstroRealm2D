extends Node2D
class_name Thrusters

var _thrusters: Array[ManeuverThruster] = []
var force: Vector2 = Vector2.ZERO : get = _get_force
var torque: float = 0 : get = _get_torque

func setup(thrust: float):
	for thruster in get_children() as Array[ManeuverThruster]:
		thruster.setup(thrust)
		_thrusters.append(thruster)

func apply_strafe(value: Vector2):
	for thruster in _thrusters:
		thruster.apply_strafe(value)

func apply_rotation(value: float):
	for thruster in _thrusters:
		thruster.apply_torque(value)

func _get_force() -> Vector2:
	force = Vector2.ZERO
	for thruster in _thrusters:
		force += thruster.force
	return force

func _get_torque() -> float:
	torque = 0.0
	for thruster in _thrusters:
		torque += thruster.torque
	return torque

func estimated_strafe_force(direction: Vector2) -> float:
	var _estimated_force := 0.0
	for thruster in _thrusters:
		_estimated_force += thruster.estimated_force(direction)
	return _estimated_force

func estimated_torque(direction: float) -> float:
	var _estimated_torque := 0.0
	for thruster in _thrusters:
		_estimated_torque += thruster.estimated_torque(direction)
	return _estimated_torque
