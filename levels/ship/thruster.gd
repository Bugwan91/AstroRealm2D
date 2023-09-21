extends Node2D

class_name Thruster

signal thrust_changed(id: int, position: Vector2, force: Vector2)

@onready var _flame: Node2D = $Flame
@export var on: bool = true:
	get:
		return on
	set(value):
		on = value
		_throttle = 0

var _power: float = 0
var _id: int = -1

var _throttle: float:
	get:
		return _throttle
	set(value):
		if not on:
			return
		var new_value = clampf(value, 0, 1)
		if _throttle != new_value:
			_throttle = new_value
			_flame.show() if _throttle > 0 else _flame.hide()
			thrust_changed.emit(_id, position, -_throttle * _power * transform.x)

func _ready():
	_throttle = 0
	_flame.hide()

func setup(id: int, power: float):
	_id = id
	_power = power
	return self

func throttle(value: float):
	_throttle = value
