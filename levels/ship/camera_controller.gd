extends Camera2D
class_name CameraController

@export var target: RigidBody2D
@export var force: float = 1
@export var inertia: float = 10
@export var zoom_min := 0.5
@export var zoom_max := 4.0
@export var zoom_speed := 0.1

var _inverse_inertia: float
var _last_veocity: Vector2 = Vector2.ZERO
var _acceleration: Vector2 = Vector2.ZERO

var _zoom_min: Vector2
var _zoom_max: Vector2
var _zoom_speed: Vector2
var _target_zoom: Vector2

func _ready():
	_inverse_inertia = 1 / inertia
	_init_zoom()

func _unhandled_input(event):
	if event.is_action("zoom_in"):
		_target_zoom += _zoom_speed
	elif event.is_action("zoom_out"):
		_target_zoom -= _zoom_speed
	_target_zoom = _target_zoom.clamp(_zoom_min, _zoom_max)

func _process(_delta):
	var _delta_position = _acceleration.rotated(-target.rotation) * force - position
	position += _delta_position * _inverse_inertia
	zoom = lerp(zoom, _target_zoom, .1)

func _physics_process(_delta):
	_acceleration = _last_veocity - target.linear_velocity
	_last_veocity = target.linear_velocity

func _init_zoom():
	_zoom_min = Vector2(zoom_min, zoom_min)
	_zoom_max = Vector2(zoom_max, zoom_max)
	_zoom_speed = Vector2(zoom_speed, zoom_speed)
	_target_zoom = zoom
