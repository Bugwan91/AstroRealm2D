class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01
const STOP_THRESHOLD := 1.0
const DRAG := 0.5 # Not needs yet, but should thi be a global constant?
const STRAFE_LOW_SPEED_BONUS := 2.0

signal dodging(bool)

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model
		_closee_navigator.radius = ship.radius

var flight_model: ShipFlightModelData
var input_reader: ShipInput:
	set(value):
		if is_instance_valid(value):
			input_reader = value
			inputs = input_reader.data
var inputs: ShipInputData

var _closee_navigator: CloseNavigator

var _dodging := false:
	set(value):
		_dodging = value
		dodging.emit(_dodging)
var _dodge_acceleration := false
var _dodge_time := 0.0
var _dodge_vector := Vector2(1.0, 0.0)

func setup(spaceship: Spaceship):
	_closee_navigator = %CloseNavigator
	ship = spaceship
	flight_model.init()

func integrate_forces(state: PhysicsDirectBodyState2D):
	if not is_instance_valid(inputs): return
	_dodge(state)
	inputs.strafe += _closee_navigator.update_course(
		state.step,
		state.transform.origin,
		state.linear_velocity).rotated(-ship.rotation) * 2.0
	_stop(state)
	_strafe(state)
	_rotate(state)
	_boost(state)
	_drag(state)

func _stop(state: PhysicsDirectBodyState2D):
	if not inputs.stop or inputs.dodge: return
	var stop_vector := -ship.linear_velocity.normalized()
	var step_distance := flight_model.strafe * (1.0 + _strafe_bonus(state)) * state.step
	if ship.speed < step_distance:
		ship.linear_velocity = Vector2.ZERO
	else:
		# CAUTION Probably it's not sync safe, as inputs.strafe also updates in ShipInput
		# But probably it doesn't mater as long as strafe input doesn't changing every frame
		inputs.strafe += 2.0 * (stop_vector).rotated(-ship.rotation)

func _dodge(state: PhysicsDirectBodyState2D):
	if inputs.dodge and not _dodging:
		_dodging = true
		_dodge_acceleration = true
		inputs.dodge = false
		_dodge_time = 0.0
		if not inputs.strafe.is_zero_approx():
			_dodge_vector = inputs.strafe.rotated(ship.rotation)
	if _dodging:
		if _dodge_acceleration:
			_dodge_time += state.step
			state.apply_central_force(_dodge_vector * flight_model.dodge)
			if _dodge_time > flight_model.dodge_duration:
				inputs.dodge = false
				_dodge_time = 0.0
				_dodge_acceleration = false
		else:
			state.apply_central_force(-_dodge_vector * flight_model.dodge_stop)
			_dodge_time += state.step
			if _dodge_time > flight_model.dodge_stop_duration:
				_dodging = false
				_dodge_time = 0.0
	else:
		_dodge_vector = state.transform.x

func _strafe(state: PhysicsDirectBodyState2D):
	if inputs.strafe.is_zero_approx(): return
	var str_input := inputs.strafe.rotated(ship.rotation) # Ralative
	#var str_input := inputs.strafe.rotated(-0.5*PI) # Absolute
	str_input += str_input * _strafe_bonus(state)
	state.apply_central_force(str_input * flight_model.strafe)

func _strafe_bonus(state: PhysicsDirectBodyState2D) -> float:
	var s := state.linear_velocity.length()
	var d := minf(s / flight_model.speed, 1.0)
	return pow((1.0 - d), 2.0) * STRAFE_LOW_SPEED_BONUS

func _rotate(state: PhysicsDirectBodyState2D):
	var d := state.transform.x.angle_to(input_reader.update_target_point() - state.transform.origin)
	if abs(d) < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		ship.angular_velocity = 0.0
		return
	var a := flight_model.turn * state.step
	var vt := 0.5 * (sqrt(a * (a + 8.0 * absf(d))) - a) * signf(d) / state.step
	# TODO: reimplemet this with apply_torque()
	ship.angular_velocity = vt

func _boost(state: PhysicsDirectBodyState2D):
	if not inputs.boost: return
	var boost := inputs.boost * flight_model.boost * state.transform.x
	state.apply_central_force(boost)

func _drag(state: PhysicsDirectBodyState2D):
	if _dodge_acceleration: return
	var extra_speed := state.linear_velocity.length_squared() - flight_model.speed_sq
	if extra_speed < 0.0: return
	var stop_force := sqrt(extra_speed) * DRAG * -state.linear_velocity.normalized()
	state.apply_central_force(stop_force)
