extends Camera2D
class_name CameraController

@export var target: RigidBody2D
@export_range(0, 1) var drag: float = 0.01
@export_range(0, 1) var force: float = 0.5
var last_veocity: Vector2 = Vector2.ZERO
var _acceleration: Vector2 = Vector2.ZERO

func _process(_delta):
	position += _acceleration.rotated(-target.rotation) * force
	position *= (1 - drag)

func _physics_process(_delta):
	_acceleration = last_veocity - target.linear_velocity
	last_veocity = target.linear_velocity
