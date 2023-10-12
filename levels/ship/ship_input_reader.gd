class_name ShipInputReader
extends Node2D

signal main_thruster(value: float)
signal strafe(value: Vector2)
signal rotate(value: float)
signal pointer(value: Vector2)

var _main_thruster: float = 0:
	set(value):
		if value != _main_thruster:
			_main_thruster = value
			main_thruster.emit(_main_thruster)
var _strafe: Vector2 = Vector2.ZERO:
	set(value):
		if value != _strafe:
			_strafe = value
			strafe.emit(_strafe)
var _rotate: float = 0:
	set(value):
		if value != _rotate:
			_rotate = value
			rotate.emit(_rotate)
var _pointer: Vector2 = Vector2.ZERO:
	set(value):
		if value != _pointer:
			_pointer = value
			pointer.emit(_pointer)

func _process(_delta):
	_main_thruster = 1 if Input.is_action_pressed("throttle_main") else 0
	_strafe = Vector2(Input.get_axis("manuever_back", "manuever_forward"), Input.get_axis("manuever_left", "manuever_right"))
	_rotate = Input.get_axis("turn_left", "turn_right")
	_pointer = get_global_mouse_position()
