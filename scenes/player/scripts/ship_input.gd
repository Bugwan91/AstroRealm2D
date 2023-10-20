class_name PlayerShipInput
extends ShipInput

func _process(_delta):
	main_thruster.emit(1 if Input.is_action_pressed("throttle_main") else 0)
	strafe.emit(Vector2(Input.get_axis("manuever_back", "manuever_forward"), Input.get_axis("manuever_left", "manuever_right")))
	rotate.emit(Input.get_axis("turn_left", "turn_right"))
	pointer.emit(get_global_mouse_position())
	if Input.is_action_pressed("set_target"):
		autopilot_target_point.emit(get_global_mouse_position())

func _unhandled_input(event):
	if event.is_action_pressed("flight_assist"):
		flight_assistant.emit(true)
	if event.is_action_pressed("follow_target"):
		fa_follow.emit(true)
	if event.is_action_pressed("target_reset"):
		reset_target.emit(true)
	if event.is_action_pressed("autopilot"):
		fa_autopilot.emit(true)
	if event.is_action_pressed("distance_up"):
		follow_distance.emit(1.0)
	if event.is_action_pressed("distance_down"):
		follow_distance.emit(-1.0)
	if event.is_action_pressed("autopilot_speed_up"):
		autopilot_speed.emit(1.0)
	if event.is_action_pressed("autopilot_speed_down"):
		autopilot_speed.emit(-1.0)
	if event.is_action_pressed("auto_aim"):
		auto_aim.emit(true)
	if event.is_action_pressed("fire"):
		fire.emit(true)
	if event.is_action_released("fire"):
		fire.emit(false)
