@tool
class_name ShipFlightAssistant
extends Node

enum Action {STOP, LOOK_TO}

const LINEAR_THRESHOLD = 0.1
const AUTOPILOT_THRESHOLD = 16
const ANGULAR_THRESHOLD = 0.01

@export var enabled := false
@export var ship: RigidBody2D
@export var input_reader: ShipInputReader
@export var thrusters: Thrusters
@export var main_thrusters: MainThrusters
@export_range(0, 200) var tracking_accuracy := 10.0

@onready var _main_state: MainState = get_node("/root/MainState")

var target: RigidBody2D

var _is_tracking := false
var _is_autopilot := false
var _thrusters_ratio := 0.0
var _main_thruster_input := 0.0
var _strafe_input := Vector2.ZERO
var _rotate_input := 0.0
var _linear_velocity := Vector2.ZERO
var _main_thrusters_control := 0.0
var _linear_control := Vector2.ZERO
var _angular_control := 0.0
var _pointer_position := Vector2.ZERO


func _ready():
	if Engine.is_editor_hint(): return
	ship = owner
	input_reader.main_thruster.connect(_main_thruster_input_changed)
	input_reader.strafe.connect(_strafe_input_changed)
	input_reader.rotate.connect(_rotate_input_changed)
	input_reader.pointer.connect(_pointer_input_changed)


func setup():
	_thrusters_ratio = thrusters.estimated_strafe_force(Vector2.RIGHT) / main_thrusters.estimated_force()


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	apply_controls(delta)
	thrusters.apply_forces()
	main_thrusters.apply_forces()


func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not (is_instance_valid(ship) and ship is RigidBody2D):
		warnings.append("RigidBody missed")
	if not (is_instance_valid(input_reader) and input_reader is ShipInputReader):
		warnings.append("Input source missed")
	if not (is_instance_valid(thrusters) and thrusters is Thrusters):
		warnings.append("Thrusters missed")
	if not (is_instance_valid(main_thrusters) and main_thrusters is MainThrusters):
		warnings.append("Main thrusters missed")
	return warnings


func _unhandled_input(event):
	if event.is_action_pressed("flight_assist"):
		enabled = not enabled
		_main_state.flight_assist = enabled
	if event.is_action_pressed("stop"):
		_is_tracking = not _is_tracking
	if event.is_action_pressed("autopilot"):
		_is_autopilot = not _is_autopilot

func apply_controls(delta: float):
	_update_relative_data()
	_linear_control = _strafe_input
	_angular_control = _rotate_input
	_main_thrusters_control = _main_thruster_input
	if enabled:
		if _is_tracking:
			_linear_to_target(delta, _get_delta_velocity())
			_angular_to_target(delta)
			_handle_turn(delta, _pointer_position)
		elif _is_autopilot:
			_move_to(delta, Vector2(1000, 500))
		else:
			_handle_turn(delta, _pointer_position)
	_handle_control()


func target_changed(value: RigidBody2D):
	target = value


func _update_relative_data():
	_linear_velocity = ship.linear_velocity


func _handle_control():
	thrusters.apply_strafe(_linear_control)
	thrusters.apply_rotation(_angular_control)
	main_thrusters.apply_throttle(_main_thrusters_control)

func _linear_to_target(delta: float, dv: Vector2 = Vector2.ZERO):
	dv = dv.rotated(-ship.rotation)
	var dv_len = dv.length()
	var dv_n = dv / dv_len
	if dv_len > LINEAR_THRESHOLD:
		var a = delta * (thrusters.estimated_strafe_force(dv * 100) / ship.mass)
		var f = (dv_len / a)
		_linear_control = 2 * f * _strafe_input + f * dv_n
		if _linear_control.x > 1:
			_main_thrusters_control = _main_thruster_input + (_linear_control.x - 1) * _thrusters_ratio


func _angular_to_target(delta: float, target_velocity: float = 0):
	if _rotate_input != 0:
		return
	var dv = target_velocity - ship.angular_velocity
	if abs(dv) > ANGULAR_THRESHOLD:
		var a = delta * abs(thrusters.estimated_torque(dv)) * ship.inverse_inertia
		_angular_control = dv / a

func _move_to(delta: float, target_point: Vector2):
	var delta_position = target_point - ship.position
	var velocity_l = ship.linear_velocity.length()
	if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		_angular_to_target(delta, 0)
		return
	_handle_turn(delta, target_point)
	_handle_move(delta, delta_position)

func _handle_turn(delta: float, target_point: Vector2):
	if _rotate_input != 0:
		return
	var error = ship.transform.x.angle_to(target_point - ship.position)
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


func _handle_move(delta: float, delta_position: Vector2):
	var velocity_l = ship.linear_velocity.length()
	if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		return
	var a = thrusters.estimated_strafe_force(delta_position)
	var v = sqrt((2 * a * delta_position.length())/3) * delta_position.normalized()
	_linear_to_target(delta, v - ship.linear_velocity)


func _get_delta_velocity(accurate: bool = false) -> Vector2:
	if is_instance_valid(target):
		var delta = (target.linear_velocity - _linear_velocity)
		if tracking_accuracy <= LINEAR_THRESHOLD:
			return delta
		var delta_l = delta.length()
		if delta_l > tracking_accuracy:
			var d = max(0.0, delta_l - tracking_accuracy if not accurate else 0.0)
			return delta * (d / delta_l)
	return -_linear_velocity


func _main_thruster_input_changed(value: float):
	_main_thruster_input = value


func _strafe_input_changed(value: Vector2):
	_strafe_input = value


func _rotate_input_changed(value: float):
	_rotate_input = value


func _pointer_input_changed(value: Vector2):
	_pointer_position = value
