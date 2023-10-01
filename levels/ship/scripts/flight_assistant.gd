extends Node
class_name ShipFlightAssistant

enum Action {STOP, LOOK_TO}

@export var enabled: bool = false
@onready var thrusters: Thrusters = %Thrusters
@onready var main_engine: Thruster = %MainEngine
@onready var input_reader: ShipInputReader = %InputReader
@onready var body = %rigidbody

var _is_stop: bool = false

var _target_linear_velocity: Vector2 = Vector2.ZERO
var _target_angular_velocity: float = 0
var _target_direction: float = 0

var _main_thruster_input: float = 0
var _strafe_input: Vector2 = Vector2.ZERO
var _rotate_input: float = 0

func _ready():
	input_reader.main_thruster.connect(_main_thruster_input_changed)
	input_reader.strafe.connect(_strafe_input_changed)
	input_reader.rotate.connect(_rotate_input_changed)

func _process(_delta):
	if Input.is_action_just_pressed("autopilot"):
		enabled = not enabled
	if not enabled:
		_direct_control()
		return
	_is_stop = Input.is_action_pressed("stop")

func _direct_control():
	main_engine.throttle = _main_thruster_input
	thrusters.apply_strafe(_strafe_input)
	thrusters.apply_rotation(_rotate_input)

func _stop():
	pass

func _linear_velocity_delta() -> Vector2:
	return _target_linear_velocity - body.linear_velocity

func _angulat_velocity_delta() -> float:
	return _target_angular_velocity - body.angular_velocity

func _main_thruster_input_changed(value: float):
	_main_thruster_input = value

func _strafe_input_changed(value: Vector2):
	_strafe_input = value

func _rotate_input_changed(value: float):
	_rotate_input = value
