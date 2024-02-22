class_name PlayerShipInput
extends ShipInput

const DISTANCE_STEP := 100.0
const SPEED_STEP := 100.0

func _ready():
	MainState.player_target_updated.connect(_target_updated)

func _process(_delta):
	pass
	data.boost = 1 if Input.is_action_pressed("throttle_main") else 0
	data.strafe = Vector2(Input.get_axis("manuever_back", "manuever_forward"), Input.get_axis("manuever_left", "manuever_right"))
	data.target_point = get_global_mouse_position()
	if Input.is_action_pressed("set_target"):
		data.autopilot_target = get_global_mouse_position() + FloatingOrigin.origin

func _unhandled_input(event):
	if event.is_action_pressed("follow_target"):
		data.is_follow = not data.is_follow
	if event.is_action_pressed("target_reset"):
		data.target = null
	if event.is_action_pressed("autopilot"):
		data.is_autopilot = not data.is_autopilot
	if event.is_action_pressed("distance_up"):
		data.follow_distance += DISTANCE_STEP
	if event.is_action_pressed("distance_down"):
		data.follow_distance -= DISTANCE_STEP
	if event.is_action_pressed("autopilot_speed_up"):
		data.autopilot_speed += SPEED_STEP
	if event.is_action_pressed("autopilot_speed_down"):
		data.autopilot_speed -= SPEED_STEP
	if event.is_action("fire"):
		data.fire = not data.fire
	if event.is_action_pressed("auto_aim"):
		data.auto_aim = not data.auto_aim

#TODO: InputReader shouldn't know about flight assistant
# inverse this dependency
func _target_updated(target: Spaceship):
	var player: Spaceship = MainState.player_ship
	if is_instance_valid(player):
		player.flight_assistant.target = target
		player.battle_assistant.target = target
