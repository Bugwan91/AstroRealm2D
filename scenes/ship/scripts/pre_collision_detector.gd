class_name ShipPreCollisionDetector
extends Area2D

var potential_collision_vector: Vector2

var _bodies: Array[RigidBody2D]

func _on_body_entered(body: RigidBody2D):
	if body == owner: return
	_bodies.append(body)
	_update_potential_collision()

func _on_body_exited(body: RigidBody2D):
	_bodies.erase(body)
	_update_potential_collision()

func _update_potential_collision():
	var vec = Vector2.ZERO
	for body in _bodies:
		vec += body.position - owner.position
	potential_collision_vector = Vector2.ZERO if vec.length() == 0.0 else vec.normalized()
