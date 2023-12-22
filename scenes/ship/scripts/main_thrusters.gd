class_name MainThrusters
extends Node2D

@export var _body: RigidBody2D
@export var thruster_scene: PackedScene

var _velocity_limit: float = 1000.0
var _thrusters: Array[Thruster] = []


func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not (is_instance_valid(_body) and _body is RigidBody2D):
		warnings.append("Needs RigidBody2D to apply forces")
	return warnings


func setup(positions: PackedVector2Array, thrust: float, max_speed: float):
	_velocity_limit = max_speed
	for point in positions:
		var thruster: Thruster = thruster_scene.instantiate()
		thruster.position = point
		add_child(thruster)
		thruster.setup(thrust)
		_thrusters.append(thruster)


func apply_throttle(value: float):
	for thruster in _thrusters:
		thruster.throttle = value


func apply_forces():
	_body.add_force(_force().rotated(_body.rotation))


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
