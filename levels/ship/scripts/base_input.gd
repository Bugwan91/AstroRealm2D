extends Node

class_name ShipBaseInput

@export var enabled := true

var _burst: float = 0:
	get:
		return _burst
	set(value):
		if value != _burst:
			_burst = value
			_action(Thrusters.ACTION.MAIN, value)

var _forward: float = 0:
	get:
		return _forward
	set(value):
		if value != _forward:
			_forward = value
			_action(Thrusters.ACTION.FORWARD, value)

var _back: float = 0:
	get:
		return _back
	set(value):
		if value != _back:
			_back = value
			_action(Thrusters.ACTION.BACK, value)

var _left: float = 0:
	get:
		return _left
	set(value):
		if value != _left:
			_left = value
			_action(Thrusters.ACTION.LEFT, value)

var _right: float = 0:
	get:
		return _right
	set(value):
		if value != _right:
			_right = value
			_action(Thrusters.ACTION.RIGHT, value)

var _turn_left: float = 0:
	get:
		return _turn_left
	set(value):
		if value != _turn_left:
			_turn_left = value
			_action(Thrusters.ACTION.TURN_LEFT, value)

var _turn_right: float = 0:
	get:
		return _turn_right
	set(value):
		if value != _turn_right:
			_turn_right = value
			_action(Thrusters.ACTION.TURN_RIGHT, value)

func _process(delta):
	if not enabled:
		return
	_burst = 1 if Input.is_action_pressed("main_engine") else 0
	_forward = 1 if Input.is_action_pressed("throtle_forward") else 0
	_back = 1 if Input.is_action_pressed("throtle_back") else 0
	_back = 1 if Input.is_action_pressed("throtle_back") else 0
	_left = 1 if Input.is_action_pressed("throtle_left") else 0
	_right = 1 if Input.is_action_pressed("throtle_right") else 0
	_turn_left = 1 if Input.is_action_pressed("turn_left") else 0
	_turn_right = 1 if Input.is_action_pressed("turn_right") else 0

func _action(type: int, value):
	pass
