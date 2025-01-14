class_name ActiveRigidBody
extends RigidBody

var tick_acceleration: Vector2

var _last_velocity: Vector2

## Always call in the end of overriding method
func _physics_process(_delta: float):
	tick_acceleration = (linear_velocity - _last_velocity)
	_last_velocity = linear_velocity
