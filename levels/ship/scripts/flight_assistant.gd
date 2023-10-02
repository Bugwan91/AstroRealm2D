extends Node
class_name ShipFlightAssistant

enum Action {STOP, LOOK_TO}

@export var enabled: bool = true
@onready var thrusters: Thrusters = %Thrusters
@onready var main_engine: Thruster = %MainEngine
@onready var input_reader: ShipInputReader = %InputReader
@onready var body = %rigidbody

var _is_stop: bool = false

var _main_thruster_input: float = 0
var _strafe_input: Vector2 = Vector2.ZERO
var _rotate_input: float = 0

var _relative_linear_velocity: Vector2 = Vector2.ZERO
var _target_linear_velocity: Vector2 = Vector2.ZERO

var _linear_control: Vector2 = Vector2.ZERO
var _angular_control: float = 0

var _pointer_position: Vector2 = Vector2.ZERO
var _delta_direction: float = 0

func _ready():
	input_reader.main_thruster.connect(_main_thruster_input_changed)
	input_reader.strafe.connect(_strafe_input_changed)
	input_reader.rotate.connect(_rotate_input_changed)
	input_reader.pointer.connect(_pointer_input_changed)

func _process(_delta):
	_update_status()
	_linear_control = _strafe_input
	if enabled:
		_update_relative_data()
		_handle_stop()
		_handle_turn()
	_handle_control()

func _update_relative_data():
	_relative_linear_velocity = body.linear_velocity.rotated(-body.rotation)

func _handle_control():
	main_engine.throttle = _main_thruster_input
	thrusters.apply_strafe(_linear_control)
	thrusters.apply_rotation(_angular_control)

func _update_status():
	if Input.is_action_just_pressed("autopilot"):
		enabled = not enabled

func _handle_stop(target_velocity: Vector2 = Vector2.ZERO):
	if Input.is_action_pressed("stop"):
		_target_linear_velocity = target_velocity
		_linear_control = 2 * _strafe_input + _linear_velocity_delta()

func _handle_turn():
	_delta_direction = body.transform.x.angle_to(_pointer_position - body.position)
	if abs(_rotate_input) > 0.001:
		_angular_control = _rotate_input
	else:
		_angular_control = 2 * _delta_direction - body.angular_velocity
	#DebugDraw2d.line_vector(body.position, body.transform.x * 200, Color.WEB_GRAY)
	#DebugDraw2d.line_vector(body.position, (body.transform.x * 200).rotated(_delta_direction), Color.GREEN)
	#DebugDraw2d.line_vector(body.position, (body.transform.x * 200).rotated(body.angular_velocity), Color.RED)
	#DebugDraw2d.line_vector(body.position, (body.transform.x * 200).rotated(_angular_control), Color.PURPLE)

func _linear_velocity_delta() -> Vector2:
	return _target_linear_velocity - _relative_linear_velocity.clamp(Vector2(-1,-1), Vector2(1,1))

func torque_max() -> float:
	return abs(thrusters.torque_sum_pos)

func _main_thruster_input_changed(value: float):
	_main_thruster_input = value

func _strafe_input_changed(value: Vector2):
	_strafe_input = value

func _rotate_input_changed(value: float):
	_rotate_input = value

func _pointer_input_changed(value: Vector2):
	_pointer_position = value
