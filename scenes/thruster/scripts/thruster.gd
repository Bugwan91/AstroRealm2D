class_name Thruster
extends Node2D

@export var _thrust := 10.0
@export var enabled := true : set = _set_enabled

@onready var _flame: ThrusterFlame = %Flame

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
		_flame.run(throttle)
		force = throttle * _thrust * _force_direction

func _ready():
	_force_direction = transform.x.normalized()
	_flame.setup_sound(0, 1)

func setup(value: float):
	_thrust = value
