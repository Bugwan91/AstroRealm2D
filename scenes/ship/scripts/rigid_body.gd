class_name RigidBody
extends RigidBody2D

var _last_velocity: Vector2

var tick_acceleration: Vector2

var speed: float:
	get:
		return linear_velocity.length()

## Always call in the end of overriding method
func _physics_process(delta):
	tick_acceleration = (linear_velocity - _last_velocity)
	_last_velocity = linear_velocity

func delta_v(target_v: Vector2) -> Vector2:
	return target_v - linear_velocity
