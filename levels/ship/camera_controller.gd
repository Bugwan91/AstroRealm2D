extends Camera2D
class_name CameraController

@export var target: RigidBody2D
@export var force: float = 1
@export var inertia: float = 10

var _inverse_inertia: float
var _last_veocity: Vector2 = Vector2.ZERO
var _acceleration: Vector2 = Vector2.ZERO

func _ready():
	_inverse_inertia = 1 / inertia

func _process(_delta):
	var _delta_position = _acceleration.rotated(-target.rotation) * force - position
	position += _delta_position * _inverse_inertia

func _physics_process(_delta):
	_acceleration = _last_veocity - target.linear_velocity
	_last_veocity = target.linear_velocity
