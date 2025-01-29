class_name CameraController
extends Camera2D

signal zoomed(zoom: float)

@export var zoom_min := 0.1
@export var zoom_max := 2.0
@export var zoom_speed := 0.05

var shift := Vector2.ZERO

var target: Spaceship
var _required_look_position: Vector2
var _hit_position: Vector2
var _zoom_min: Vector2
var _zoom_max: Vector2
var _zoom_speed: Vector2
var _target_zoom: Vector2

func _ready() -> void:
	MainState.camera_controller = self
	MainState.player_ship_updated.connect(_on_update_player_ship)
	_init_zoom()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ALT): return
	if event.is_action("zoom_in"):
		_target_zoom += _target_zoom * _zoom_speed
	elif event.is_action("zoom_out"):
		_target_zoom -= _target_zoom * _zoom_speed
	_target_zoom = _target_zoom.clamp(_zoom_min, _zoom_max)

func update(delta: float) -> Vector2:
	if not is_instance_valid(target): return Vector2.ZERO
	if _target_zoom != zoom:
		zoom = lerp(zoom, _target_zoom, 5.0 * delta)
		zoomed.emit(zoom.x)
	_required_look_position = lerp(_required_look_position, _get_look_position(), 2.0 * delta)
	var new_position := target.extrapolator.smooth_position + _required_look_position
	shift = new_position - position
	position = new_position
	MainState.camera_shift = shift
	return shift

func _init_zoom() -> void:
	_zoom_min = Vector2(zoom_min, zoom_min)
	_zoom_max = Vector2(zoom_max, zoom_max)
	_zoom_speed = Vector2(zoom_speed, zoom_speed)
	_target_zoom = zoom

func _get_look_position() -> Vector2:
	var screen := Vector2(get_viewport().size) / zoom
	# TODO: check what is wrong with this deadzone
	var deadzone := screen * 0.4 # 0.5 * 0.8 => half_screen * (1 - margins)
	var delta := get_global_mouse_position() - target.position
	return delta.clamp(-deadzone, deadzone) / 2

func _on_update_player_ship(player_ship: Spaceship) -> void:
	target = player_ship
	if not target: return

# TODO: Not unig this so far, probably should be deleting at all after playtesting
func _shake_on_hit(hit: Vector2) -> void:
	_hit_position = -hit * 0.5 / zoom # TODO: Clamp for huge impulses
