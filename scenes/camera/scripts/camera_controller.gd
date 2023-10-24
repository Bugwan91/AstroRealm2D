class_name CameraController
extends Camera2D

@export var target: ShipRigidBody
@export var inertia := 1.0
@export var acceleration_multiplyer := 5.0
@export var zoom_min := 0.5
@export var zoom_max := 4.0
@export var zoom_speed := 0.1

@onready var _main_state: MainState = get_node("/root/MainState")

var _last_veocity: Vector2 = Vector2.ZERO
var _required_acceleration_position: Vector2 = Vector2.ZERO
var _required_look_position: Vector2 = Vector2.ZERO
var _zoom_min: Vector2
var _zoom_max: Vector2
var _zoom_speed: Vector2
var _target_zoom: Vector2
var _inverse_inertia: float

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

func _process(delta):
	var new_look = _get_look_position()
	var look_delta = new_look - _required_look_position
	_required_look_position = lerp(_required_look_position, new_look, 2 * delta)
	position = target.extrapolator.smooth_position + _required_acceleration_position + _required_look_position
	zoom = lerp(zoom, _target_zoom, 5 * delta)
	MainState.add_debug_info("Zoom", zoom.x)

func _physics_process(delta):
	var acceleration = (_last_veocity - target.real_velocity) * (Vector2.ONE * acceleration_multiplyer / zoom)
	_required_acceleration_position = lerp(_required_acceleration_position, acceleration, _inverse_inertia * delta)
	_last_veocity = target.real_velocity

func _init_zoom():
	_zoom_min = Vector2(zoom_min, zoom_min)
	_zoom_max = Vector2(zoom_max, zoom_max)
	_zoom_speed = Vector2(zoom_speed, zoom_speed)
	_target_zoom = zoom

func _get_look_position() -> Vector2:
	var screen = Vector2(get_viewport().size) / zoom
	var deadzone = screen * 0.4 # 0.5 * 0.8 => half_screen * (1 - margins)
	var delta = get_global_mouse_position() - target.extrapolator.smooth_position
	return delta.clamp(-deadzone, deadzone) / 2
