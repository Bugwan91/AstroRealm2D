class_name ActiveRigidBody
extends RigidBody

var tick_acceleration: Vector2
var acceleration: Vector2

var _last_velocity: Vector2

## Always call in the end of overriding method
func _physics_process(_delta: float) -> void:
	tick_acceleration = (linear_velocity - _last_velocity)
	# TODO: Mabe it is better to multiply by Engine.ticks or something for perfomance, instead of dividing by delta
	acceleration = tick_acceleration / _delta
	_last_velocity = linear_velocity
