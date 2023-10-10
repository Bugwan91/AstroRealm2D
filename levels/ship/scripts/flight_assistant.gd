extends Node
class_name ShipFlightAssistant

enum Action {STOP, LOOK_TO}

var ship: RigidBody2D
@export var enabled: bool = false
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: Engines = %Engines
@onready var input_reader: ShipInputReader = %InputReader
@onready var _main_state = get_node("/root/MainState")

var _main_thruster_input: float = 0
var _strafe_input: Vector2 = Vector2.ZERO
var _rotate_input: float = 0

var _linear_velocity: Vector2 = Vector2.ZERO
const LINEAR_THRESHOLD = 0.1
const ANGULAR_THRESHOLD = 0.01

var _linear_control: Vector2 = Vector2.ZERO
var _angular_control: float = 0

var _pointer_position: Vector2 = Vector2.ZERO

var target: RigidBody2D

func _ready():
	ship = owner
	input_reader.main_thruster.connect(_main_thruster_input_changed)
	input_reader.strafe.connect(_strafe_input_changed)
	input_reader.rotate.connect(_rotate_input_changed)
	input_reader.pointer.connect(_pointer_input_changed)

func _physics_process(delta):
	apply_controls(delta)
	thrusters.apply_forces()
	engines.apply_forces()

func apply_controls(delta: float):
	_update_status()
	_update_relative_data()
	_linear_control = _strafe_input
	_angular_control = _rotate_input
	if Input.is_action_pressed("stop"):
		_linear_to_target(delta, _get_target_velocity())
		_angular_to_target(delta)
	if enabled:
		_handle_turn(delta)
	_handle_control()

func _update_relative_data():
	_linear_velocity = ship.linear_velocity

func _handle_control():
	engines.apply_throttle(_main_thruster_input)
	thrusters.apply_strafe(_linear_control)
	thrusters.apply_rotation(_angular_control)

func _update_status():
	if Input.is_action_just_pressed("autopilot"):
		enabled = not enabled
		_main_state.flight_assist = enabled

func _linear_to_target(delta: float, target_velocity: Vector2 = Vector2.ZERO):
	var dv = (target_velocity - _linear_velocity).rotated(-ship.rotation)
	var dv_len = dv.length()
	var dv_n = dv / dv_len
	if dv_len > LINEAR_THRESHOLD:
		var a_max = delta * (thrusters.estimated_strafe_force(dv * 100) / ship.mass)
		_linear_control = 2 * _strafe_input + ((dv_len / a_max) * dv_n).clamp(Vector2(-1, -1), Vector2(1, 1))
	
func _angular_to_target(delta: float, target_velocity: float = 0):
	if _rotate_input != 0:
		return
	var dv = target_velocity - ship.angular_velocity
	if abs(dv) > ANGULAR_THRESHOLD:
		var a_max = delta * abs(thrusters.estimated_torque(dv)) * ship.inverse_inertia
		_angular_control = dv / a_max

func _handle_turn(delta: float):
	if _rotate_input != 0:
		return
	var error = ship.transform.x.angle_to(_pointer_position - ship.position)
	if abs(error) < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		return
	var a = abs(thrusters.estimated_torque(1) * ship.inverse_inertia) * delta * delta
	if a == 0:
		return
	var d = abs(error)
	var n = int((sqrt(a*a + 8*a*d) - a) / (2*a))
	var wt = sign(error) * (d/(n+1) + 0.5*a*n)
	var w = ship.angular_velocity * delta
	_angular_control = (wt - w) / a

func _get_target_velocity() -> Vector2:
	if is_instance_valid(target):
		return target.linear_velocity
	return Vector2.ZERO

func target_changed(value: RigidBody2D):
	target = value

func _main_thruster_input_changed(value: float):
	_main_thruster_input = value

func _strafe_input_changed(value: Vector2):
	_strafe_input = value

func _rotate_input_changed(value: float):
	_rotate_input = value

func _pointer_input_changed(value: Vector2):
	_pointer_position = value
