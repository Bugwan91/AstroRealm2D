class_name ShipFlightAssistant
extends Node

enum Action {STOP, LOOK_TO}

const LINEAR_THRESHOLD = 0.1
const AUTOPILOT_THRESHOLD = 16
const ANGULAR_THRESHOLD = 0.01

@export var enabled := false
@export var _input_reader: ShipInputReader
@export var _thrusters: Thrusters
@export var _main_thrusters: MainThrusters

@onready var position_pointer: BattleAssistantPointer = %PositionPointer
@onready var _ship: ShipRigidBody = owner
@onready var _main_state: MainState = get_node("/root/MainState")

var target_body: RigidBody2D
var autopilot_speed := 0.0
var tracking_distance := 300.0

var _is_tracking := false
var _tracking_error := 0.0
var _is_autopilot := false

var _thrusters_ratio := 0.0

var _main_thruster_input := 0
var _main_thrusters_control := 0.0
var _strafe_input := Vector2.ZERO
var _linear_control := Vector2.ZERO
var _rotation_input := 0.0
var _angular_control := 0.0
var _pointer_position := Vector2.ZERO
var _target_position := Vector2.ZERO


func _ready():
	_ship = owner
	_input_reader.main_thruster.connect(_main_thruster_input_changed)
	_input_reader.strafe.connect(_strafe_input_changed)
	_input_reader.rotate.connect(_rotate_input_changed)
	_input_reader.pointer.connect(_pointer_input_changed)
	_main_state.fa_tracking_distance = tracking_distance
	_main_state.fa_autopilot_speed = autopilot_speed


func setup(error: float):
	_thrusters_ratio = _thrusters.estimated_strafe_force(Vector2.RIGHT) / _main_thrusters.estimated_force()
	_tracking_error = error


func _process(_delta):
	position_pointer.position = _ship.position
	if enabled and _is_autopilot:
		position_pointer.update(_target_position - _ship.position)
	else:
		position_pointer.disable()
	if Input.is_action_pressed("set_target") and _is_autopilot:
		_target_position = _pointer_position


func _physics_process(delta):
	override_controls(delta)
	_update_thrusters()
	_thrusters.apply_forces()
	_main_thrusters.apply_forces()


func _unhandled_input(event):
	if event.is_action_pressed("flight_assist"):
		enabled = not enabled
	if enabled and event.is_action_pressed("stop"):
		_is_tracking = not _is_tracking
		if _is_tracking:
			_is_autopilot = false
	if enabled and event.is_action_pressed("autopilot"):
		_is_autopilot = not _is_autopilot
		if _is_autopilot:
			_is_tracking = false
	_main_state.fa_enabled = enabled
	_main_state.fa_tracking = enabled and _is_tracking
	_main_state.fa_autopilot = enabled and _is_autopilot
	
	if enabled and _is_tracking:
		if event.is_action_pressed("distance_up"):
			tracking_distance += 50
		if event.is_action_pressed("distance_down"):
			tracking_distance = max(0, tracking_distance - 50)
		_main_state.fa_tracking_distance = tracking_distance
	
	if enabled and _is_autopilot:
		if event.is_action_pressed("autopilot_speed_up"):
			autopilot_speed += 50
		if event.is_action_pressed("autopilot_speed_down"):
			autopilot_speed = max(0, autopilot_speed - 50)
		_main_state.fa_autopilot_speed = autopilot_speed

func override_controls(delta: float):
	_main_thrusters_control = _main_thruster_input
	_linear_control = _strafe_input
	_angular_control = _rotation_input
	if enabled:
		if _is_autopilot:
			move_to(delta, _target_position, autopilot_speed)
		else:
			turn_to(delta, _pointer_position)
			if _is_tracking:
				if is_instance_valid(target_body):
					follow_target(delta, tracking_distance)
				else:
					match_velocity(delta, _get_delta_velocity())


func follow_target(delta: float, distance: float = 0.0):
	var dv := _get_delta_velocity(_tracking_error)
	if distance == 0:
		match_velocity(delta, dv)
		return
	var dp := target_body.position - _ship.position
	var dp_target := dp - dp.normalized() * distance
	var vs = _get_stop_velocity(dp_target, -dv, 0, _tracking_error)
	match_velocity(delta, vs)


func match_velocity(delta: float, dv: Vector2 = Vector2.ZERO, main_forced: bool = true):
	_linear_control.x = _main_thrusters_control if _main_thrusters_control > 0 else _linear_control.x
	var dv_len := dv.length()
	if dv_len == 0:
		return
	dv = dv.rotated(-_ship.rotation)
	var dv_n := dv / dv_len
	if dv_len > LINEAR_THRESHOLD:
		var a := delta * (_thrusters.estimated_strafe_force(dv * 100) / _ship.mass)
		var f := (dv_len / a)
		_linear_control = 2 * max(1, f) * _linear_control + f * dv_n
		# TODO: update with using effect of damping after speed cap
		if _linear_control.x - 1 > LINEAR_THRESHOLD\
				and (main_forced or _linear_control.x / abs(_linear_control.y) > 0.5):
			_main_thrusters_control = (_linear_control.x - 1) * _thrusters_ratio


func match_rotation(delta: float, target_velocity: float = 0):
	if _angular_control != 0:
		return
	var dv := target_velocity - _ship.angular_velocity
	if abs(dv) > ANGULAR_THRESHOLD:
		var a: float = delta * abs(_thrusters.estimated_torque(dv)) * _ship.inverse_inertia
		_angular_control = dv / a


func move_to(delta: float, target_point: Vector2, max_speed: float = 0.0):
	var delta_position := target_point - _ship.position
	var velocity_l := _ship.linear_velocity.length()
	if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		match_rotation(delta, 0)
		return
	turn_to(delta, target_point)
	slide_to(delta, delta_position, max_speed)


func turn_to(delta: float, target_point: Vector2):
	if _angular_control != 0:
		return
	var error := _ship.transform.x.angle_to(target_point - _ship.position)
	if abs(error) < ANGULAR_THRESHOLD and abs(_ship.angular_velocity) < ANGULAR_THRESHOLD:
		return
	var a: float = abs(_thrusters.estimated_torque(1) * _ship.inverse_inertia) * delta * delta
	if a == 0:
		return
	var d: float = abs(error)
	var n := int((sqrt(a*a + 8*a*d) - a) / (2*a))
	var wt: float = sign(error) * (d/(n+1) + 0.5*a*n)
	var w := _ship.angular_velocity * delta
	_angular_control = (wt - w) / a


func slide_to(delta: float, delta_position: Vector2, max_speed: float = 0.0):
	match_velocity(delta, _get_stop_velocity(delta_position, _ship.linear_velocity, max_speed), false)


func _get_stop_velocity(position: Vector2, velocity: Vector2, max_speed: float = 0.0, error: float =  0.0) -> Vector2:
	var current_speed = velocity.length()
	if position.length() < AUTOPILOT_THRESHOLD and current_speed < LINEAR_THRESHOLD:
		return Vector2.ZERO
	var a := _thrusters.estimated_strafe_force(position)
	var v := sqrt((2 * a * position.length())/3)
	if max_speed != 0:
		v = min(max_speed, v)
	return _velocity_with_error(v * position.normalized() - velocity, error)


func _get_delta_velocity(error: float = 0.0) -> Vector2:
	var target_velocity: Vector2
	if is_instance_valid(target_body):
		target_velocity = target_body.linear_velocity
	else:
		target_velocity = -_ship.linear_velocity
	return _velocity_with_error(target_velocity - _ship.linear_velocity, error)


func _velocity_with_error(velocity: Vector2, error: float = 0.0) -> Vector2:
	var lenght := velocity.length()
	if lenght > LINEAR_THRESHOLD and lenght > error:
		return velocity * (max(0.0, lenght - error) / lenght)
	return Vector2.ZERO


func _update_thrusters():
	_thrusters.apply_strafe(_linear_control)
	_thrusters.apply_rotation(_angular_control)
	_main_thrusters.apply_throttle(_main_thrusters_control)

func _main_thruster_input_changed(value: float):
	_main_thruster_input = value

func _strafe_input_changed(value: Vector2):
	_strafe_input = value

func _rotate_input_changed(value: float):
	_rotation_input = value

func _pointer_input_changed(value: Vector2):
	_pointer_position = value
