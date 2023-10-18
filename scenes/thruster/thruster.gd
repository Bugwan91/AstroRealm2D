class_name Thruster
extends Node2D

@onready var _flame: Node2D = $Flame
@export var _sound: AudioStreamPlayer2D
@export var _thrust := 10.0
@export var enabled := true : set = _set_enabled

var throttle := 0.0 : set = _set_throttle

var _force_direction: Vector2
var force: Vector2 = Vector2.ZERO

func _set_enabled(value):
	throttle = 0
	enabled = value

func _set_throttle(value):
	if not enabled:
		return
	value = clamp(value, 0, 1)
	if throttle != value:
		throttle = value
		_update_flame()
		force = throttle * _thrust * _force_direction

func _ready():
	_flame.hide()
	_force_direction = transform.x.normalized()

func _process(_delta):
	pass

func setup(value: float):
	_thrust = value

func _update_flame():
	if throttle > 0:
		_flame.show()
		_flame.modulate.a = throttle
	else:
		_flame.hide()
	_update_sound(throttle)

func _update_sound(value: float):
	_sound.volume_db = -30 - (40 - 40 * value)
	if not _sound.playing:
		_sound.play()
	if value < 0.01:
		_sound.stop()