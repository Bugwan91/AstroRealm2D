class_name CameraController
extends Camera2D

@export var target: ShipRigidBody
@export var inertia: float = 10.0
@export var acceleration_multiplyer: float = 10.0
@export var moves_smoosnes: float = 0.25
@export var zoom_min := 0.5
@export var zoom_max := 4.0
@export var zoom_speed := 0.1

var _inverse_inertia: float
var _last_veocity: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO

var _zoom_min: Vector2
var _zoom_max: Vector2
var _zoom_speed: Vector2
var _target_zoom: Vector2

func _ready():
	_inverse_inertia = 1 / inertia
	_init_zoom()

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_ALT): return
	if event.is_action("zoom_in"):
		_target_zoom += _zoom_speed
	elif event.is_action("zoom_out"):
		_target_zoom -= _zoom_speed
	_target_zoom = _target_zoom.clamp(_zoom_min, _zoom_max)

func _process(_delta):
	position = target.extrapolated_position + _target_position
	zoom = lerp(zoom, _target_zoom, .1)

func _physics_process(_delta):
	var acceleration = (_last_veocity - target.linear_velocity) * (Vector2.ONE * acceleration_multiplyer / zoom)
	_target_position = lerp(_target_position, _look_direction() + acceleration, _inverse_inertia * _delta)
	_last_veocity = target.linear_velocity

func _init_zoom():
	_zoom_min = Vector2(zoom_min, zoom_min)
	_zoom_max = Vector2(zoom_max, zoom_max)
	_zoom_speed = Vector2(zoom_speed, zoom_speed)
	_target_zoom = zoom

func _look_direction() -> Vector2:
	return (get_global_mouse_position() - target.extrapolated_position) * moves_smoosnes
