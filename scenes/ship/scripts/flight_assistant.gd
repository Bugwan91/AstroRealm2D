class_name ShipFlightAssistant
extends Node

const LINEAR_THRESHOLD = 1.0
const AUTOPILOT_THRESHOLD = 16
const ANGULAR_THRESHOLD = 0.02

@export var enabled := false
@export var autopilot_pointer_view: AssistantPointer

@onready var collision_detector: CollisionDetector = %CollisionDetector

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model
var flight_model: ShipFlightModelData
var inputs: ShipInputData

var target: Spaceship

var is_autopilot_should_stop := true

var _velocity_error: float = 0.0

var _anti_collision_control: Vector2

var _state: PhysicsDirectBodyState2D

func _ready():
	collision_detector.predicted_collision.connect(_update_potential_collision)

func setup(spaceship: Spaceship):
	ship = spaceship

func connect_inputs(input_reader: ShipInput):
	inputs = input_reader.data

func process(state: PhysicsDirectBodyState2D):
	if not enabled: return
	_state = state
	_update_autopilot_pointer_view()
	#_update_error()
	override_controls()
	#_avoid_colission()
	#_update_thrusters()
	_state = null

func _update_potential_collision(direction: Vector2):
	_anti_collision_control = direction

func _avoid_colission():
	# TODO check
	if not collision_detector.enabled: return
	if _anti_collision_control.is_zero_approx(): return
	#DebugDraw2d.line_vector(ship.position, _anti_collision_control.rotated(ship.rotation) * 200.0, Color.RED, 12.0, 0.2)
	inputs.control.strafe = _anti_collision_control.clamp(Vector2(-1,-1), Vector2(1,1))
	#DebugDraw2d.line_vector(ship.position, _linear_control.rotated(ship.rotation) * 200.0, Color.PURPLE, 12.0, 0.2)
	_anti_collision_control = Vector2.ZERO

func _update_autopilot_pointer_view():
	if not is_instance_valid(autopilot_pointer_view): return
	if inputs.is_autopilot:
		var point = inputs.autopilot_target - FloatingOrigin.origin
		autopilot_pointer_view.update(point, ship.canvas_position)
	else:
		autopilot_pointer_view.disable()

func override_controls():
	pass
	#if is_autopilot:
		#move_to(_autopilot_target_position - FloatingOrigin.origin, autopilot_speed, is_autopilot_stop)
	#if is_follow:
		#follow_target(follow_distance)


#func follow_target(distance: float = 0.0):
	#if not is_instance_valid(target):
		#match_velocity(_get_delta_velocity())
		#return
	#var dv := _get_delta_velocity()
	#if distance == 0:
		#match_velocity(dv)
		#return
	#var dp := target.position - _state_position
	#var dp_target := dp - dp.normalized() * distance
	#var needed_velocity = _get_stop_velocity(dp_target, -dv, target.acceleration, 0)
	#match_velocity(needed_velocity)


#func match_velocity(dv: Vector2 = Vector2.ZERO, main_forced: bool = true):
	#_linear_control.x = _main_thrusters_control if _main_thrusters_control > 0 else _linear_control.x
	#var dv_len := dv.length()
	#if dv_len > LINEAR_THRESHOLD * 0.1:
		#dv = dv.rotated(-_state_rotation)
		#var dv_n := dv / dv_len
		#var a := _state.step * (_thrusters.estimated_strafe_force(dv_n) * _state.inverse_mass)
		#if a == 0:
			#return
		#var f := (dv_len / a)
		#_linear_control = 2 * max(1, f) * _linear_control + f * dv_n
		#if _linear_control.x - 1 > LINEAR_THRESHOLD\
				#and (main_forced or _linear_control.x / abs(_linear_control.y) > 0.5):
			#_main_thrusters_control = (_linear_control.x - 1) * _thrusters_ratio


#func match_rotation(target_velocity: float = 0):
	#if _angular_control != 0:
		#return
	#var dv := target_velocity - _state.angular_velocity
	#if abs(dv) > ANGULAR_THRESHOLD:
		#var a: float = _state.step * abs(_thrusters.estimated_torque(dv)) * _state.inverse_inertia
		#_angular_control = dv / a


#func move_to(target_point: Vector2, max_speed: float = 0.0, stop: bool = true):
	#var delta_position := target_point - _state_position
	#if not stop:
		#turn_to(target_point)
		#var dv: = delta_position.normalized() * max_speed - _state_absolute_velocity
		#match_velocity(dv, false)
		#return
	#var velocity_l := _state_absolute_velocity.length()
	#if delta_position.length() < AUTOPILOT_THRESHOLD and velocity_l < LINEAR_THRESHOLD:
		#match_rotation(0)
		#return
	#turn_to(target_point)
	#match_velocity(_get_stop_velocity(delta_position, _state_absolute_velocity, Vector2.ZERO, max_speed), false)


#func _update_error():
	##TODO: Refactor this. Possible division by 0 error
	#if is_instance_valid(target):
		#_last_velocity = target.absolute_velocity
		#


#func _get_stop_velocity(direction: Vector2, v_delta: Vector2, a_target: Vector2 = Vector2.ZERO, max_speed: float = 0.0) -> Vector2:
	#var speed = v_delta.project(direction).length()
	#var distance = direction.length()
	#var dir_n = direction.normalized()
	#if distance < AUTOPILOT_THRESHOLD and speed < LINEAR_THRESHOLD:
		#return Vector2.ZERO
	#var a_self: float = _thrusters.estimated_strafe_force(direction)
	#var a_total: Vector2 = a_target + a_self * dir_n
	#var a_sum: float = a_total.project(direction).length()
	#if a_sum < LINEAR_THRESHOLD:
		#return MainState.MAX_SPEED * dir_n
	#var v := sqrt(a_sum * distance * 0.66666666666) # 2/3
	#return v * dir_n - v_delta


func _get_delta_velocity() -> Vector2:
	if is_instance_valid(target):
		return target.linear_velocity - _state.linear_velocity
	else:
		return -ship.absolute_velocity
