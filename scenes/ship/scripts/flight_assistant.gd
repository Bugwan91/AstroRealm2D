class_name ShipFlightAssistant
extends Node

enum Action {STOP, LOOK_TO}

const LINEAR_THRESHOLD = 0.1
const AUTOPILOT_THRESHOLD = 16
const ANGULAR_THRESHOLD = 0.01

@export var avoid_collisions: bool = true

@onready var _thrusters: Thrusters = %Thrusters
@onready var _main_thrusters: MainThrusters = %MainThrusters

@export var autopilot_pointer_view: AssistantPointer

@onready var _pre_collision_detector: ShipPreCollisionDetector = %PreCollisionDetector

var target: ShipRigidBody: set = _set_target
var autopilot_speed := 10000.0
var follow_distance := 1000.0
var direction := Vector2.ZERO
var ignore_direction_update := false
var is_turn_enabled := true
var is_follow := false
var follow_accuracy := 0.5
var follow_accuracy_damp := 0.1
var is_autopilot := false
var is_autopilot_stop := true

var enabled := false
var _state: PhysicsDirectBodyState2D
var _state_position: Vector2
var _state_rotation: float
var _state_absolute_velocity: Vector2
var _thrusters_ratio: float
var _main_thruster_input: int
var _main_thrusters_control: float
var _strafe_input: Vector2
var _linear_control: Vector2
var _rotation_input: float
var _angular_control: float
var _autopilot_target_position: Vector2
var _velocity_error: float
var _last_velocity: Vector2

func _ready():
	MainState.fa_tracking_distance = follow_distance
	MainState.fa_autopilot_speed = autopilot_speed

func setup():
	_thrusters_ratio = _thrusters.estimated_strafe_force(Vector2.RIGHT) / _main_thrusters.estimated_force()

func process(state: PhysicsDirectBodyState2D):
	if enabled:
		_state = state
		_state_position = _state.transform.origin
		_state_rotation = _state.transform.x.angle()
		_state_absolute_velocity = _state.linear_velocity + FloatingOrigin.velocity
		_update_autopilot_pointer_view()
		_update_error()
		override_controls()
		_avoid_colission()
		_update_thrusters()
	_apply_forces()

func _avoid_colission():
	if not avoid_collisions: return
	_linear_control = _linear_control.clamp(Vector2(-1,-1), Vector2(1,1))\
		- 2.0 * _pre_collision_detector.potential_collision_vector.rotated(-owner.rotation)

func _update_autopilot_pointer_view():
	if not is_instance_valid(autopilot_pointer_view): return
	if is_autopilot:
		var point = _autopilot_target_position - owner.extrapolator.global_position - FloatingOrigin.origin
		autopilot_pointer_view.update(point, owner.extrapolator.canvas_position)
	else:
		autopilot_pointer_view.disable()


func connect_inputs(inputs: ShipInput):
	inputs.main_thruster.connect(_main_thruster_input_changed)
	inputs.strafe.connect(_strafe_input_changed)
	inputs.rotate.connect(_rotate_input_changed)
	inputs.target_point.connect(_point_input_changed)
	inputs.fa_follow.connect(_target_follow_toggled)
	inputs.reset_target.connect(_reset_target)
	inputs.follow_distance.connect(_follow_distance_changed)
	inputs.fa_autopilot.connect(_autopilot_toggled)
	inputs.autopilot_speed.connect(_autopilot_speed_changed)
	inputs.autopilot_target_point.connect(_autopilot_point_changed)
	enabled = true

func override_controls():
	_main_thrusters_control = _main_thruster_input
	_linear_control = _strafe_input
	_angular_control = _rotation_input
	if is_autopilot:
		move_to(_autopilot_target_position - FloatingOrigin.origin, autopilot_speed, is_autopilot_stop)
	elif is_turn_enabled:
		turn_to(direction)
	if is_follow:
		follow_target(follow_distance)


func follow_target(distance: float = 0.0):
	if not is_instance_valid(target):
		match_velocity(_get_delta_velocity())
		return
	var dv := _get_delta_velocity()
	if distance == 0:
		match_velocity(dv)
		return
	var dp := target.position - _state_position
	var dp_target := dp - dp.normalized() * distance
	var vs = _get_stop_velocity(dp_target, -dv, 0)
	match_velocity(vs * (1.0 - _velocity_error))


func match_velocity(dv: Vector2 = Vector2.ZERO, main_forced: bool = true):
	_linear_control.x = _main_thrusters_control if _main_thrusters_control > 0 else _linear_control.x
	var dv_len := dv.length()
	if dv_len > LINEAR_THRESHOLD * 0.1:
		dv = dv.rotated(-_state_rotation)
		var dv_n := dv / dv_len
		var a := _state.step * (_thrusters.estimated_strafe_force(dv_n) * _state.inverse_mass)
		if a == 0:
			return
		var f := (dv_len / a)
		_linear_control = 2 * max(1, f) * _linear_control + f * dv_n
		# TODO: (Low Priority)
		# For better assistant precision,
		# update this with using effect of damping after speed cap
		if _linear_control.x - 1 > LINEAR_THRESHOLD\
				and (main_forced or _linear_control.x / abs(_linear_control.y) > 0.5):
			_main_thrusters_control = (_linear_control.x - 1) * _thrusters_ratio


func match_rotation(target_velocity: float = 0):
	if _angular_control != 0:
		return
	var dv := target_velocity - _state.angular_velocity
	if abs(dv) > ANGULAR_THRESHOLD:
		var a: float = _state.step * abs(_thrusters.estimated_torque(dv)) * _state.inverse_inertia
		_angular_control = dv / a


func move_to(target_point: Vector2, max_speed: float = 0.0, stop: bool = true):
	var delta_position := target_point - _state_position
	if not stop:
		turn_to(target_point)
		var dv: = delta_position.normalized() * max_speed - _state_absolute_velocity
		match_velocity(dv, false)
		return
	var velocity_l := _state_absolute_velocity.length()
	if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		match_rotation(0)
		return
	turn_to(target_point)
	match_velocity(_get_stop_velocity(delta_position, _state_absolute_velocity, max_speed), false)


func turn_to(target_point: Vector2):
	if _angular_control != 0:
		return
	var error := _state.transform.x.angle_to(target_point - _state_position)
	if abs(error) < ANGULAR_THRESHOLD and abs(_state.angular_velocity) < ANGULAR_THRESHOLD:
		return
	var a: float = abs(_thrusters.estimated_torque(1) * _state.inverse_inertia) * _state.step * _state.step
	if a == 0:
		return
	var d: float = abs(error)
	var n := int((sqrt(a*(a + 8*d)) - a) / (2*a))
	var wt: float = sign(error) * (d/(n+1) + 0.5*a*n)
	var w := _state.angular_velocity * _state.step
	_angular_control = (wt - w) / a

func _apply_forces():
	_thrusters.apply_forces()
	_main_thrusters.apply_forces()

func _update_error():
	#TODO: Refactor this. Possible division by 0 error
	if is_instance_valid(target):
		_last_velocity = target.absolute_velocity
		


func _get_stop_velocity(position: Vector2, velocity: Vector2, max_speed: float = 0.0) -> Vector2:
	var current_speed = velocity.length()
	if position.length() < AUTOPILOT_THRESHOLD and current_speed < LINEAR_THRESHOLD:
		return Vector2.ZERO
	var a := _thrusters.estimated_strafe_force(position)
	var v := sqrt((2 * a * position.length())/3)
	v = v if max_speed == 0 else min(max_speed, v)
	return v * position.normalized() - velocity


func _get_delta_velocity() -> Vector2:
	if is_instance_valid(target):
		return target.linear_velocity - _state.linear_velocity
	else:
		return -_state_absolute_velocity


func _update_thrusters():
	_thrusters.apply_strafe(_linear_control)
	_thrusters.apply_rotation(_angular_control)
	_main_thrusters.apply_throttle(_main_thrusters_control)

func _set_target(value: ShipRigidBody):
	target = value
	_velocity_error = 1.0 - follow_accuracy

func _main_thruster_input_changed(value: float):
	_main_thruster_input = value

func _strafe_input_changed(value: Vector2):
	_strafe_input = value

func _rotate_input_changed(value: float):
	_rotation_input = value

func _point_input_changed(value: Vector2):
	if ignore_direction_update: return #TODO: remove tis
	direction = value
	
func _target_follow_toggled(value: bool):
	if not value: return
	is_follow = not is_follow
	if is_follow:
		is_autopilot = false
	MainState.fa_tracking = is_follow
	MainState.fa_autopilot = is_autopilot

func _reset_target(value: bool):
	if value: target = null

func _follow_distance_changed(value: float):
	if is_follow:
		follow_distance += 10 * value
	MainState.fa_tracking_distance = follow_distance

func _autopilot_toggled(value: bool):
	if not value: return
	is_autopilot = not is_autopilot
	if is_autopilot:
		is_follow = false
	MainState.fa_tracking = is_follow
	MainState.fa_autopilot = is_autopilot

func _autopilot_speed_changed(value: float):
	if is_autopilot:
		autopilot_speed += 10 * value
	MainState.fa_autopilot_speed = autopilot_speed

func _autopilot_point_changed(value: Vector2):
	if is_autopilot:
		_autopilot_target_position = value
