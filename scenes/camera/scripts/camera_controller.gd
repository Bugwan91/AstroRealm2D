class_name CameraController
extends Camera2D

@export var inertia := 1.0
@export var acceleration_multiplyer := 5.0
@export var zoom_min := 0.5
@export var zoom_max := 4.0
@export var zoom_speed := 0.1

var target: ShipRigidBody
var _last_veocity: Vector2
var _required_acceleration_position: Vector2
var _required_look_position: Vector2
var _hit_position: Vector2
var _zoom_min: Vector2
var _zoom_max: Vector2
var _zoom_speed: Vector2
var _target_zoom: Vector2
var _inverse_inertia: float

func _ready():
	MainState.player_ship_updated.connect(_on_update_player_ship)
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
	if not is_instance_valid(target): return
	_required_look_position = lerp(_required_look_position, _get_look_position(), 2 * delta)
	_hit_position = lerp(_hit_position, Vector2.ZERO, 0.1)
	position = target.extrapolator.smooth_position + _required_acceleration_position + _required_look_position + _hit_position
	zoom = lerp(zoom, _target_zoom, 5 * delta)
	MainState.add_debug_info("Camera zoom", zoom.x)

func _physics_process(delta):
	if not is_instance_valid(target): return
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

func _on_update_player_ship(player_ship: ShipRigidBody):
	target = player_ship
	if not target: return
	target.got_hit.connect(_shake_on_hit)

func _shake_on_hit(hit: Vector2):
	_hit_position = -hit
