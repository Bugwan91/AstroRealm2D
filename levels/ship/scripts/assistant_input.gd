extends ShipDirectInput

class_name ShipAssistantInput

var _direction: Vector2 = Vector2.RIGHT:
	get:
		return _direction
	set(value):
		if value != _direction:
			_direction = value

var _stop: bool = false:
	get:
		return _stop
	set(value):
		if value != _stop:
			_stop = value

var _cursor_position: Vector2 = Vector2.ZERO

func _process(delta):
	if not enabled:
		return
	#_main = 1 if Input.is_action_pressed("main_engine") else 0
	#_forward = 1 if Input.is_action_pressed("throtle_forward") else 0
	#_back = 1 if Input.is_action_pressed("throtle_back") else 0
	#_back = 1 if Input.is_action_pressed("throtle_back") else 0
	#_left = 1 if Input.is_action_pressed("throtle_left") else 0
	#_right = 1 if Input.is_action_pressed("throtle_right") else 0
	#_turn_left = 1 if Input.is_action_pressed("turn_left") else 0
	#_turn_right = 1 if Input.is_action_pressed("turn_right") else 0
	#_stop = Input.is_action_pressed("stop")

func _input(event):
	if event is InputEventMouseMotion:
		_cursor_position = (event.position - 0.5 * get_viewport().get_visible_rect().size)
