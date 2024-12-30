class_name RigidBody
extends RigidBody2D

var _last_velocity: Vector2

var acceleration: Vector2:
	get:
		return linear_velocity - _last_velocity

var speed: float:
	get:
		return linear_velocity.length()

func _physics_process(delta):
	# TODO: not sure that if this works fine
	# at least this should be called very last
	_last_velocity = linear_velocity
