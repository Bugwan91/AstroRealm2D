extends Node
class_name FlightController

@export var _body: RigidBody2D
@export var _engine: Thruster
@export var _thrusters: Thrusters



func _physics_process(delta):
	_body.apply_central_force(_engine.force.rotated(_body.rotation))
	_apply_drag()


