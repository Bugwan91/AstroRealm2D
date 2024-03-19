class_name FloatingOriginRigidBody
extends RigidBody2D

var absolute_velocity: Vector2
var acceleration: Vector2
var origin := false

var _last_velocity: Vector2

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if origin:
		_update_as_origin(state)
	else:
		_update_as_regular(state)
	absolute_velocity = linear_velocity - FloatingOrigin.velocity
	_last_velocity = FloatingOrigin.velocity

func _update_as_origin(state: PhysicsDirectBodyState2D):
	# TODO fix precision issues for large speeds
	acceleration = FloatingOrigin.velocity - _last_velocity
	FloatingOrigin.last_physic_time = Time.get_ticks_usec() * 0.000001

func _update_as_regular(state: PhysicsDirectBodyState2D):
	FloatingOrigin.update_state(state)
	acceleration = state.linear_velocity - _last_velocity
