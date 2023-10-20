class_name MainThrusters
extends Node2D

@export var _body: RigidBody2D
@export var _velocity_limit := 500.0
var _thrusters: Array[Thruster] = []


func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not (is_instance_valid(_body) and _body is RigidBody2D):
		warnings.append("Needs RigidBody2D to apply forces")
	return warnings


func setup(thrust: float, max_speed: float):
	_velocity_limit = max_speed
	for thruster in get_children() as Array[Thruster]:
		thruster.setup(thrust)
		_thrusters.append(thruster)


func apply_throttle(value: float):
	for thruster in _thrusters:
		thruster.throttle = value


func apply_forces():
	_body.apply_central_force(_force().rotated(_body.rotation))
	_apply_drag()


func _apply_drag():
	var delta = _body.linear_velocity.length() - _velocity_limit
	if delta > 0:
		_body.apply_central_force(-delta * _body.linear_velocity.normalized())


func estimated_force() -> float:
	var force := 0.0
	for thruster in _thrusters:
		force += thruster._thrust
	return force


func _force() -> Vector2:
	var force = Vector2.ZERO
	for thruster in _thrusters:
		force += thruster.force
	return force
