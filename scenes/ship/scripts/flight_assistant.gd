class_name ShipFlightAssistant
extends Node

enum Action {STOP, LOOK_TO}

const LINEAR_THRESHOLD = 0.1
const AUTOPILOT_THRESHOLD = 16
const ANGULAR_THRESHOLD = 0.01

@export var enabled := false
@export var _thrusters: Thrusters
@export var _main_thrusters: MainThrusters

@onready var position_pointer: BattleAssistantPointer = %PositionPointer
@onready var _ship: ShipRigidBody = owner
@onready var _main_state: MainState = get_node("/root/MainState")

var target_body: RigidBody2D
var autopilot_speed := 500.0
var follow_distance := 500.0
var direction := Vector2.ZERO
var ignore_direction_update := false

var _is_follow := false
var _follow_error := 0.0
var _is_autopilot := false

var _thrusters_ratio := 0.0

var _main_thruster_input := 0
var _main_thrusters_control := 0.0
var _strafe_input := Vector2.ZERO
var _linear_control := Vector2.ZERO
var _rotation_input := 0.0
var _angular_control := 0.0
var _target_position := Vector2.ZERO


func _ready():
	_ship = owner
	_main_state.fa_tracking_distance = follow_distance
	_main_state.fa_autopilot_speed = autopilot_speed


func setup(precision: float):
	_thrusters_ratio = _thrusters.estimated_strafe_force(Vector2.RIGHT) / _main_thrusters.estimated_force()
	_follow_error = precision


func _process(_delta):
	position_pointer.position = _ship.position
	if enabled and _is_autopilot:
		position_pointer.update(_target_position - _ship.position)
	else:
		position_pointer.disable()


func _physics_process(delta):
	override_controls(delta)
	_update_thrusters()
	_thrusters.apply_forces()
	_main_thrusters.apply_forces()


func connect_inputs(inputs: ShipInput):
	inputs.main_thruster.connect(_main_thruster_input_changed)
	inputs.strafe.connect(_strafe_input_changed)
	inputs.rotate.connect(_rotate_input_changed)
	inputs.pointer.connect(_pointer_input_changed)
	inputs.flight_assistant.connect(_flight_assistant_toggled)
	inputs.fa_follow.connect(_target_follow_toggled)
	inputs.reset_target.connect(_reset_target)
	inputs.follow_distance.connect(_follow_distance_changed)
	inputs.fa_autopilot.connect(_autopilot_toggled)
	inputs.autopilot_speed.connect(_autopilot_speed_changed)
	inputs.autopilot_target_point.connect(_autopilot_point_changed)


func override_controls(delta: float):
	_main_thrusters_control = _main_thruster_input
	_linear_control = _strafe_input
	_angular_control = _rotation_input
	if not enabled: return
	if _is_autopilot:
		move_to(delta, _target_position, autopilot_speed)
	else:
		turn_to(delta, direction)
	if _is_follow:
		follow_target(delta, follow_distance)


func follow_target(delta: float, distance: float = 0.0):
	if not is_instance_valid(target_body):
		match_velocity(delta, _get_delta_velocity())
		return
	var dv := _get_delta_velocity(_follow_error)
	if distance == 0:
		match_velocity(delta, dv)
		return
	var dp := target_body.position - _ship.position
	var dp_target := dp - dp.normalized() * distance
	var vs = _get_stop_velocity(dp_target, -dv, 0, _follow_error)
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


func move_to(delta: float, target_point: Vector2, max_speed: float = 0.0, stop: bool = true):
	var delta_position := target_point - _ship.position
	if not stop:
		turn_to(delta, target_point)
		var dv: = delta_position.normalized() * max_speed - _ship.linear_velocity
		match_velocity(delta, dv, false)
		return
	var velocity_l := _ship.linear_velocity.length()
	if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		match_rotation(delta, 0)
		return
	turn_to(delta, target_point)
	match_velocity(\
		delta,\
		_get_stop_velocity(delta_position, _ship.linear_velocity, max_speed),\
		false)


func turn_to(delta: float, target_point: Vector2):
	# TODO: Rethink and rework this algorythm.
	# I don't like it and don't fully understand it.
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


func _get_stop_velocity(position: Vector2, velocity: Vector2, max_speed: float = 0.0, error: float =  0.0) -> Vector2:
	var current_speed = velocity.length()
	if position.length() < AUTOPILOT_THRESHOLD and current_speed < LINEAR_THRESHOLD:
		return Vector2.ZERO
	var a := _thrusters.estimated_strafe_force(position)
	var v := sqrt((2 * a * position.length())/3)
	v = v if max_speed == 0 else min(max_speed, v)
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
	if ignore_direction_update: return
	direction = value
	
func _flight_assistant_toggled(value: bool):
	if not value: return
	enabled = not enabled
	_main_state.fa_enabled = enabled
	_main_state.fa_tracking = enabled and _is_follow
	_main_state.fa_autopilot = enabled and _is_autopilot
	
func _target_follow_toggled(value: bool):
	if not value: return
	_is_follow = not _is_follow
	if _is_follow:
		_is_autopilot = false
	_main_state.fa_tracking = enabled and _is_follow
	_main_state.fa_autopilot = enabled and _is_autopilot

func _reset_target(value: bool):
	if value: target_body = null

func _follow_distance_changed(value: float):
	if enabled and _is_follow:
		follow_distance += 10 * value
	_main_state.fa_tracking_distance = follow_distance

func _autopilot_toggled(value: bool):
	if not value: return
	_is_autopilot = not _is_autopilot
	if _is_autopilot:
		_is_follow = false
	_main_state.fa_tracking = enabled and _is_follow
	_main_state.fa_autopilot = enabled and _is_autopilot

func _autopilot_speed_changed(value: float):
	if enabled and _is_autopilot:
		autopilot_speed += 10 * value
	_main_state.fa_autopilot_speed = autopilot_speed

func _autopilot_point_changed(value: Vector2):
	if enabled and _is_autopilot:
		_target_position = value
