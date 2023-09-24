extends Node2D
class_name Thruster

@onready var _flame: Node2D = $Flame

@export var _thrust := 10.0

@export var enabled := true:
	get:
		return enabled
	set(value):
		throttle = 0
		enabled = value

var throttle := 0.0 :
	get:
		return clamp(throttle, 0, 1)
	set(value):
		if not enabled:
			return
		if throttle != value:
			throttle = value
			_update_flame()
			force.set_strenght(throttle * _thrust)

var force: Force

func _ready():
	_flame.hide()
	force = Force.new(position, transform.x)

func setup(value: float):
	_thrust = value

func _update_flame():
	if throttle > 0:
		_flame.show()
		_flame.modulate.a = throttle
	else:
		_flame.hide()


