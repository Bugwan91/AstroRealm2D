class_name PlayerShipInput
extends ShipInput

func _ready():
	MainState.player_target_updated.connect(_target_updated)

func _process(_delta):
	main_thruster.emit(1 if Input.is_action_pressed("throttle_main") else 0)
	strafe.emit(Vector2(Input.get_axis("manuever_back", "manuever_forward"), Input.get_axis("manuever_left", "manuever_right")))
	target_point.emit(get_global_mouse_position())
	if Input.is_action_pressed("set_target"):
		autopilot_target_point.emit(get_global_mouse_position() + FloatingOrigin.origin)

func _unhandled_input(event):
	if event.is_action_pressed("follow_target"):
		fa_follow.emit(true)
	if event.is_action_pressed("target_reset"):
		MainState.player_target = null
		#reset_target.emit(true)
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
	if event.is_action("fire"):
		fire.emit(event.is_pressed())

func _target_updated(target: ShipRigidBody):
	var player: ShipRigidBody = MainState.player_ship
	if is_instance_valid(player):
		player.flight_assistant.target = target
		player.battle_assistant.target = target
