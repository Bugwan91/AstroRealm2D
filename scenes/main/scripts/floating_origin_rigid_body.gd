class_name FloatingOriginRigidBody
extends RigidBody2D

var absolute_velocity: Vector2
var acceleration: Vector2
var _last_velocity: Vector2

func _integrate_forces(state: PhysicsDirectBodyState2D):
	acceleration = state.linear_velocity - _last_velocity
	FloatingOrigin.update_state(state)
	absolute_velocity = linear_velocity + FloatingOrigin.velocity
	_last_velocity = state.linear_velocity
