extends Node2D
class_name ShipInputReader

var input_data: ShipInputData = ShipInputData.new()

func _process(_delta):
	input_data.main = 1 if Input.is_action_pressed("throttle_main") else 0
	input_data.forward = 1 if Input.is_action_pressed("manuever_forward") else 0
	input_data.back = 1 if Input.is_action_pressed("manuever_back") else 0
	input_data.left = 1 if Input.is_action_pressed("manuever_left") else 0
	input_data.right = 1 if Input.is_action_pressed("manuever_right") else 0
	input_data.turn_left = 1 if Input.is_action_pressed("turn_left") else 0
	input_data.turn_right = 1 if Input.is_action_pressed("turn_right") else 0

func _input(event):
	if event is InputEventMouseMotion:
		input_data.target = get_global_mouse_position()
