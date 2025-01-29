class_name PlayerShipInput
extends ShipInput

const DISTANCE_STEP := 100.0
const SPEED_STEP := 100.0

var _camera_shift: Vector2

func _ready() -> void:
	process_priority = -999
	RadarManager.instance.selected.connect(_target_updated)

func _process(_delta: float) -> void:
	_camera_shift = CameraController.instance.update(_delta)
	update_target_point()
	data.strafe = Vector2(Input.get_axis("manuever_back", "manuever_forward"), Input.get_axis("manuever_left", "manuever_right"))
	# CAUTION: Doesn't work. Controls is hardcoded is SelectionArea
	if Input.is_action_pressed("set_target"):
		data.autopilot_target = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_target_point()
	if event.is_action_pressed("dodge"):
		data.dodge = true
	if event.is_action_pressed("stop"):
		data.stop = true
	if event.is_action_released("stop"):
		data.stop = false
	if event.is_action_pressed("boost"):
		data.boost = true
	if event.is_action_released("boost"):
		data.boost = false
	if event.is_action_pressed("target_reset"):
		RadarManager.instance.reselect(null)
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

func _target_updated(target: RadarItem) -> void:
	data.target = target

func update_target_point() -> Vector2:
	data.target_point = get_global_mouse_position() + _camera_shift
	return data.target_point
