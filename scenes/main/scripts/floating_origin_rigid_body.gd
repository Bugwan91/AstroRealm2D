class_name FloatingOriginRigidBody
extends RigidBody2D

func _integrate_forces(state):
	FloatingOrigin.update_state(state)
