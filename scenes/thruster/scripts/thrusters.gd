class_name Thrusters
extends Node2D

var _thrusters: Array[ManeuverThruster] = []


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


func apply_forces():
	owner.add_force(_force().rotated(owner.rotation))
	owner.add_torque(_torque())


func _force() -> Vector2:
	var force = Vector2.ZERO
	for thruster in _thrusters:
		force += thruster.force
	return force


func _torque() -> float:
	var torque = 0.0
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
