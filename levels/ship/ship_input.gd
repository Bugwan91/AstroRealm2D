extends Node

class_name ShiInput

signal main_changed(value: float)
signal forward_changed(value: float)
signal back_changed(value: float)
signal left_changed(value: float)
signal right_changed(value: float)
signal turn_left_changed(value: float)
signal turn_right_changed(value: float)
signal direction_changed(value: Vector2)

var _main: float = 0:
	get:
		return _main
	set(value):
		if value != _main:
			_main = value
			main_changed.emit(value)

var _forward: float = 0:
	get:
		return _forward
	set(value):
		if value != _forward:
			_forward = value
			forward_changed.emit(value)

var _back: float = 0:
	get:
		return _back
	set(value):
		if value != _back:
			_back = value
			back_changed.emit(value)

var _left: float = 0:
	get:
		return _left
	set(value):
		if value != _left:
			_left = value
			left_changed.emit(value)

var _right: float = 0:
	get:
		return _right
	set(value):
		if value != _right:
			_right = value
			right_changed.emit(value)

var _turn_left: float = 0:
	get:
		return _turn_left
	set(value):
		if value != _turn_left:
			_turn_left = value
			turn_left_changed.emit(value)

var _turn_right: float = 0:
	get:
		return _turn_right
	set(value):
		if value != _turn_right:
			_turn_right = value
			turn_right_changed.emit(value)

func _process(delta):
	_main = 1 if Input.is_action_pressed("main_engine") else 0
	_forward = 1 if Input.is_action_pressed("throtle_forward") else 0
	_back = 1 if Input.is_action_pressed("throtle_back") else 0
	_back = 1 if Input.is_action_pressed("throtle_back") else 0
	_left = 1 if Input.is_action_pressed("throtle_left") else 0
	_right = 1 if Input.is_action_pressed("throtle_right") else 0
	_turn_left = 1 if Input.is_action_pressed("turn_left") else 0
	_turn_right = 1 if Input.is_action_pressed("turn_right") else 0
